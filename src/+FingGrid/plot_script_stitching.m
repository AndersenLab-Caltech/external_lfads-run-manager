%% Load data
runList = rc.findRuns('all');
run = runList(1); % Only 1 param set for multisession run
pmList = run.loadPosteriorMeans();
ds_index = 4; % Which dataset to plot from the many
pm = pmList(ds_index);

inputInfoList = run.loadInputInfo();
conditionId = inputInfoList(ds_index).conditionId;

channel_to_plot = 21;
rates = squeeze(pm.rates(channel_to_plot, :, :));

%% Plot smoothed rates by condition index
[unique_groups, ~, group_idx] = unique(conditionId);
cmap = jet(numel(unique_groups));
line_groups = []; % Show legend of lines by conditionId

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
spikes = squeeze(inputInfoList(ds_index).counts(channel_to_plot,:,:));
time = inputInfoList(ds_index).seq_timeVector;

figure; title('spike raster')
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
