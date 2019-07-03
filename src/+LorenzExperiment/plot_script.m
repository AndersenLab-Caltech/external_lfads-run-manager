%% Load data
run = rc.findRuns('single_dataset001', 1);
pm = run.loadPosteriorMeans();
conditionId = run.loadInputInfo().conditionId;

channel_to_plot = 1;
rates1 = squeeze(pm.rates(channel_to_plot, :, :));

%% Plot smoothed rates by condition index
[unique_groups, ~, group_idx] = unique(conditionId);
cmap = jet(numel(unique_groups));

figure; hold on;
for idx = 1:numel(unique_groups)
    plot(pm.time, rates1(:,conditionId == unique_groups(idx)),...
         'Color', cmap(idx,:))
end

hold off;

xlabel('Time (ms)')
ylabel('r1');