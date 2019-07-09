%% Load data
runList = rc.findRuns('single_dataset001');
run = runList(1);
pm = run.loadPosteriorMeans();
conditionId = run.loadInputInfo().conditionId;

channel_to_plot = 1;
rates = squeeze(pm.rates(channel_to_plot, :, :));

%% Plot smoothed rates by condition index
[unique_groups, ~, group_idx] = unique(conditionId);
cmap = jet(numel(unique_groups));

figure; hold on;
for idx = 1:numel(unique_groups)
    plot(pm.time, rates(:,conditionId == unique_groups(idx)),...
         'Color', cmap(idx,:))
end

hold off;

xlabel('Time (ms)')
ylabel('r1');

%% Plot raw spiking rates
spikes = squeeze(run.loadInputInfo().counts(channel_to_plot,:,:));
time = run.loadInputInfo().seq_timeVector;

figure; hold on;
imshow(spikes.')

hold off;

xlabel('Time (ms)')
ylabel('spike count (1ms bin)');
colorbar;