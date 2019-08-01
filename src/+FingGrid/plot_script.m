%% Load data
runList = rc.findRuns('single_FingGrid-20190402-M1');
run = runList(2);
pm = run.loadPosteriorMeans();
conditionId = run.loadInputInfo().conditionId;

channel_to_plot = 21;
rates = squeeze(pm.rates(channel_to_plot, :, :));

%% Plot smoothed rates by condition index
[unique_groups, ~, group_idx] = unique(conditionId);
cmap = jet(numel(unique_groups));
line_groups = [];

figure; hold on;
for idx = 1:numel(unique_groups)
    fighandle = plot(pm.time, rates(:,conditionId == unique_groups(idx)),...
         'Color', cmap(idx,:));
     line_groups(idx) = fighandle(1);
end

hold off;

xlabel('Time (ms)')
ylabel('r1');
% TODO: I thought I took out null case?
legend(line_groups, {'T','I','M','R','P','N'})

%% Plot raw spiking rates
spikes = squeeze(run.loadInputInfo().counts(channel_to_plot,:,:));
time = run.loadInputInfo().seq_timeVector;

figure;
num_conds = numel(unique_groups);
for idx = 1:num_conds
    subaxis(num_conds, 1, idx,...
        'sh', 0.03, 'sv', 0.01, 'padding', 0, 'margin', 0);
    imshow(spikes(:,conditionId == unique_groups(idx)).')
%     title(sprintf('cond: %d', idx));
end

xlabel('Time (ms)')
% ylabel('spike count (1ms bin)');
% colorbar;
