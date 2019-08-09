%% Run LFADS on a multiple NeuralDynamics datasets
baseDir = '~/LFADS_runs/NeuralDynamics';

%% Locate and specify the datasets
datasetPath = fullfile(baseDir, 'datasets');
dc = NeuralDynamics.DatasetCollection(datasetPath);
dc.name = 'NeuralDynamics';

brainRegion = 'M1';

% add individual datasets
Dates = {...
    '20190412',...
    '20190517',...
    '20190528',...
};

for dateIdx = 1:numel(Dates)
  date = Dates{dateIdx};
  NeuralDynamics.Dataset(dc, sprintf('NeuralDynamics-%s-%s.mat', date, brainRegion));
end

% load metadata from the datasets to populate the dataset collection
dc.loadInfo;

% print information loaded from each dataset
dc.getDatasetInfoTable()

%% Set some hyperparameters

par = NeuralDynamics.RunParams;
par.name = sprintf('multisession_%s', brainRegion); % name is completely optional and not hashed, for your convenience
par.spikeBinMs = 20; % rebin the data at 5 ms
par.c_co_dim = 0; % no controller --> no inputs to generator
par.c_batch_size = 16; % must be < 1/5 of the min trial count for trainToTestRatio == 4
par.c_factors_dim = 32; % and manually set it for multisession stitched models
par.c_gen_dim = 32; % number of units in generator RNN
par.c_ic_enc_dim = 64; % number of units in encoder RNN
par.c_learning_rate_stop = 1e-3; % we can stop training early for the demo

par.c_ic_dim = 32;
par.c_l2_gen_scale = 200;
par.c_kl_ic_weight = 1.0;
par.c_kl_start_step = 1000;
par.c_l2_start_step = 1000;

par.c_kl_increase_steps = 2000;
par.c_l2_increase_steps = 2000;

% Sweep some hyperparameters
parSet = par.generateSweep('c_factors_dim', [20, 32, 64],...
                           'c_ic_dim', [16, 32],...
                           'c_ic_enc_dim', [32, 64]);

%% Running a multi-dataset stitching run
runRoot = fullfile(baseDir, 'runs');
sessionName = strjoin(Dates, '_');
rc = NeuralDynamics.RunCollection(runRoot, sessionName, dc);

% replace this with the date this script was authored as YYYYMMDD
% This ensures that updates to lfads-run-manager won't invalidate older
% runs already on disk and provides for backwards compatibility
rc.version = 20190703;

% Add a RunSpec using all datasets which LFADS will then "stitch" into a
% shared dynamical model
rc.addRunSpec(NeuralDynamics.RunSpec('all', dc, 1:dc.nDatasets));

% add a single set of parameters to this run collection. Additional
% parameters can be added. LFADS.RunParams is a value class, unlike the other objects
% which are handle classes, so you can modify par freely.
rc.addParams(parSet);

% adding a return here allows you to call this script to recreate all of
% the objects here for subsequent analysis after the actual LFADS models
% have been trained. The code below will setup the LFADS training runs on
% disk the first time around, and should be run once manually.
return;

%% Generating accompanying single-dataset models

% Add RunSpecs to train individual models for each
% dataset as well to facilitate comparison.
for iR = 1:dc.nDatasets
    runSpec = NeuralDynamics.RunSpec(dc.datasets(iR).getSingleRunName(), dc, iR);
    rc.addRunSpec(runSpec);
end

%% Verifying the alignment matrices

run = rc.findRuns('all', 1);
run.doMultisessionAlignment();
nFactorsPlot = 3;
conditionsToPlot = [1 2 3];

tool = run.multisessionAlignmentTool;
tool.plotAlignmentReconstruction(nFactorsPlot, conditionsToPlot);

%% Prepare LFADS input and shell scripts

% generate all of the data files LFADS needs to run everything
rc.prepareForLFADS();

% write a python script that will train all of the LFADS runs using a
% load-balancer against the available CPUs and GPUs
% you should set display to a valid x display
% Other options are available

rc.writeShellScriptRunQueue('display', 0, 'virtualenv', 'tensorflow-gpu-py2');

    %% Looking at the alignment matrices used

runStitched = rc.findRuns('all', 1); % 'all' looks up the RunSpec by name, 1 refers to the first (and here, the only) RunParams

alignTool = runStitched.multisessionAlignmentTool;
if isempty(alignTool)
    runStitched.doMultisessionAlignment();
    alignTool = runStitched.multisessionAlignmentTool;
end

alignTool.plotAlignmentReconstruction();

% You want the colored traces to resemble the black "global" trace. The
% black traces are the PC scores using data from all the datasets. The
% colored traces are the best linear reconstruction of the black traces
% from each individual dataset alone. The projection which achieves this
% best reconstruction is used as the initial seed for the readin matrices
% for LFADS, which can be trainable or fixed depending on
% par.do_train_readin.

%% Run LFADS

% You should now run at the command line
% source activate tensorflow   # if you're using a virtual machine
% python ~/lorenz_example/runs/exampleRun_dataset1/run_lfadsqueue.py

% And then wait until training and posterior sampling are finished
