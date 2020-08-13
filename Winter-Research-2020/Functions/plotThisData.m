function plotThisData(this_channel,epoch_size)

%description
%1st subplot as data matrix of features from catch22 vs epoch as heatmap
%2nd subplot as time series data of the channel/dataset

%input
%this_channel = channel/dataset name, string
%epoch_size = size of epoch in seconds (e.g. 30s, 10s), int

%output
%saves figure into <feat op plots> folder as png and fig

tic;
%load data from hctsa mat files
thisFile = sprintf('Data and mat files\\hctsa_mat_files\\HCTSA_%s.mat',this_channel);
thisFileNorm = sprintf('Data and mat files\\hctsa_mat_files\\HCTSA_%s_N.mat',this_channel);
loadstruct = load(thisFileNorm);

%% plot data matrix above
%unclustered
Figh = figure('Position',get(0,'ScreenSize'));
tiledlayout(2,1);

ax1 = nexttile;

%plot heatmap
colormap(jet);
imagesc(loadstruct.TS_DataMat');
colorbar;

%determines if 20 mins data (short) (e.g. fp1 returns [], fp1_short returns number)
isItShort = strfind(this_channel,'short');

%settings for 20 mins dataset
if  isempty(isItShort) == 0
    interval = 60/epoch_size;
    tickArray = string([1:1:20]);
    label = 'Time (min)';
%settings for 9 hour dataset
else
    interval = 3600/epoch_size;
    tickArray = string([12:1:21]);
    label = 'Time (hr)';
end

%settings for plot
xticks([1:interval:length(loadstruct.TS_DataMat), length(loadstruct.TS_DataMat)]);
xticklabels(tickArray);
xlabel(label);

%load operation to annotate catch22 IDs on feature map
thisOperations = loadstruct.Operations;
yticks([1:1:height(thisOperations)]);
yticklabels(table2array(thisOperations(:,1)));
ylabel('catch22 Operation ID');
title(sprintf('Feature-Operation Data Matrix %s',this_channel));

%% plotting time course below
%load data
ax2 = nexttile;
load(sprintf('Data and mat files\\INP_Files\\INP_test_sleep_%s.mat',this_channel),'timeSeriesData');

%reshaping for time course plot
sleepTSData = cell2table(timeSeriesData);
sleepTSData = reshape(table2array(sleepTSData),1,[]);

%adjust time axis according to 20mins/9 hour dataset
if isempty(isItShort) == 0
    t_array = linspace(1,20,length(sleepTSData));
else
    t_array = linspace(12,21,length(sleepTSData));
end

%plotting time series below
plot(t_array,sleepTSData);
hold on;
xlabel(label);
xlim([t_array(1) t_array(end)])
ylabel('Voltage (uV)');
title(sprintf('Time series plot %s',this_channel));

%save figures
saveas(Figh,sprintf('Plots and Figures\\feat op plots\\feat_op_TS_%s.png',this_channel));
saveas(Figh,sprintf('Plots and Figures\\feat op plots\\feat_op_TS_%s.fig',this_channel));

toc;

end