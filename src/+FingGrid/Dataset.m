classdef Dataset < LFADS.Dataset
    methods
        function ds = Dataset(collection, relPath)
            ds = ds@LFADS.Dataset(collection, relPath);
        end

        function data = loadData(ds)
            % load this dataset's data file from .path
            data = load(ds.path);
        end

        function loadInfo(ds, reload)
            % Load this Dataset's metadata if not already loaded

            if nargin < 2
                reload = false;
            end
            if ds.infoLoaded && ~reload, return; end

            % extract the metadata loaded from the data file
            data = ds.loadData();
            ds.subject = data.TaskInfo.subject;
            ds.task = data.TaskInfo.Task;
            ds.taskLabel = data.TaskInfo.TaskLabel;
            ds.phase = data.TaskInfo.Phase;
            ds.saveTags = 1;
            ds.datenum  = datenum(data.trial_datetime);
            ds.nChannels = size(data.spikes, 2);
            ds.nTrials = size(data.spikes, 1);

            ds.infoLoaded = true;
        end

    end
    
    properties
        % Additional metdata
        phase char = '';
        task char = '';
        taskLabel char = '';
    end
end
