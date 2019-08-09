%% Load data
runList = rc.findRuns('single_NeuralDynamics-20190517-M1');
numRuns = numel(runList);

%% Iterate over runs

cost_valids = zeros(numRuns, 1);
for runIdx = 1:numRuns
    run = runList(runIdx);
    fl = run.loadFitLog();
    
    cost_valids(runIdx) = fl.total_valid_lve;
end

%% Sort
[sorted_cost_valids, idxes] = sort(cost_valids);

bestIdxes = idxes(1:8);
runList(bestIdxes).paramsStrings
