%% Run LFADS on a single FingGrid dataset
baseDir = '~/FingGrid';

%% Locate and specify the datasets
datasetPath = fullfile(baseDir, 'datasets');
dc = FingGrid.DatasetCollection(datasetPath);
dc.name = 'FingGrid';

% add individual datasets
Dates = {...
    '20190313',...
    '20190314',...
    '20190319',...
    '20190402',...
    '20190405',...
    '20190409',...
    '20190412',...
    '20190419'...
};

for dateIdx = 1:numel(Dates)
  date = Dates{dateIdx};
  FingGrid.Dataset(dc, sprintf('FingGrid-%s.mat', date));
end

% load metadata from the datasets to populate the dataset collection
dc.loadInfo;

% print information loaded from each dataset
disp(dc.getDatasetInfoTable())

%% Build RunCollection
ds_index = 4;

% Run a single model for each of the datasets
runRoot = fullfile(baseDir, 'runs');
sessionName = strjoin(Dates(ds_index), '_');
rc = FingGrid.RunCollection(runRoot, sessionName, dc);

% replace this with the date this script was authored as YYYYMMDD
% This ensures that updates to lfads-run-manager will remain compatible 
% with older runs already on disk
rc.version = 20190703;

%% Set some hyperparameters

par = FingGrid.RunParams;
par.name = 'first_attempt'; % name is completely optional and not hashed, for your convenience
par.spikeBinMs = 2; % rebin the data at 2 ms
par.c_co_dim = 0; % no controller --> no inputs to generator
par.c_batch_size = 150; % must be < 1/5 of the min trial count for trainToTestRatio == 4
par.c_factors_dim = 8; % and manually set it for multisession stitched models
par.c_gen_dim = 64; % number of units in generator RNN
par.c_ic_enc_dim = 64; % number of units in encoder RNN
par.c_learning_rate_stop = 1e-3; % we can stop training early for the demo

% add a single set of parameters to this run collection. Additional
% parameters can be added. LFADS.RunParams is a value class, unlike the other objects
% which are handle classes, so you can modify par freely.
rc.addParams(par);

%% Create the RunSpecs

% Define a RunSpec, which indicates which datasets get included, as well as
% what name to call this run spec
runSpecName = dc.datasets(ds_index).getSingleRunName(); % generates a simple run name from this datasets name
runSpec = FingGrid.RunSpec(runSpecName, dc, ds_index);

% add this RunSpec to the RunCollection
rc.addRunSpec(runSpec);

% adding a return here allows you to call this script to recreate all of
% the objects here for subsequent analysis after the actual LFADS models
% have been trained. The code below will setup the LFADS training runs on
% disk the first time around, and should be run once manually.
return;

%% Prepare LFADS input and shell scripts

% generate all of the data files LFADS needs to run everything
rc.prepareForLFADS();

% write a python script that will train all of the LFADS runs using a
% load-balancer against the available CPUs and GPUs
% you should set display to a valid x display
% Other options are available
rc.writeShellScriptRunQueue('display', 0, 'virtualenv', 'tensorflow-gpu-py2');
