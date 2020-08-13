function R = genCorr(this_channel)
%description
%generate a correlation matrix for two sets of features

%input
%this_channel = two datasets to generate correlations, array
%(e.g. ["fp1","fp1_proc"])

%output
%R = correlation matrix.
%note: rows = this_channel(1), columns = this_channel(2)

%% initialising
catch22ID = [1:1:22]'; %all catch22 IDs
dataMat = cell(1,2);   %data matrix for each
opMat = cell(1,2);     %operation matrices

%loading data
for i=1:2
    thisFile = sprintf('Data and mat files\\hctsa_mat_files\\HCTSA_%s.mat',this_channel(i));
    thisFileNorm = sprintf('Data and mat files\\hctsa_mat_files\\HCTSA_%s_N.mat',this_channel(i));
    thisstruct = load(thisFileNorm);
    thisOperationMat = thisstruct.Operations;
    thisOperationID = table2array(thisOperationMat(:,1));
    dataMat{i} = thisstruct.TS_DataMat;
    opMat{i} = thisOperationID;
end

%% obtain common operations
%find common features/operations between two datasets
[existID,idx1,idx2] = intersect(opMat{1},opMat{2});

%index out data that correspond to common features/operations
dataMat1 = dataMat{1}(:,idx1);
dataMat2 = dataMat{2}(:,idx2);

%get names of intersecting operations
thisOperationTable = thisOperationMat(idx2,1:2);

%compute correlation
R = corr(dataMat1,dataMat2,'Type','Pearson');

%% plot correlation matrix
Figh = figure('Position',get(0,'ScreenSize'));

%plot as heat map
h = heatmap(abs(R),'XLabel',this_channel(2),'YLabel',this_channel(1),...
                'XDisplayLabels',existID, 'YDisplayLabels',existID,'Colormap',jet,'CellLabelColor', 'none');
h.Title = sprintf('Absolute Pearson correlation between %s and %s',this_channel(1),this_channel(2));

%save figure
saveas(Figh,sprintf('Plots and Figures\\feat op plots\\correlation_features_%s_%s.png',this_channel(1),this_channel(2)));
saveas(Figh,sprintf('Plots and Figures\\feat op plots\\correlation_features_%s_%s.fig',this_channel(1),this_channel(2)));

%plotting diagonal as line graph
%obtianing diagonal elements
ind = logical(eye(size(R)));
thisDiag = R(ind);

FigLine = figure('Position',get(0,'ScreenSize'));

%plot bar graph
bar(existID,abs(thisDiag));
hold on;

%plot line graph
plot(existID,abs(thisDiag));

%settings
xlim([0.5 22.5]);
xticks(1:1:22);
xlabel('Operation ID');
ylabel('Absolute Pearson Coefficient');
title(sprintf('Feature correlation between %s and %s',this_channel(1),this_channel(2)));
hold on;
grid on;

%save figure
saveas(FigLine,sprintf('Plots and Figures\\feat op plots\\feature_correlaiton_line_%s_%s.png',this_channel(1),this_channel(2)));
saveas(FigLine,sprintf('Plots and Figures\\feat op plots\\feature_correlation_line_%s_%s.fig',this_channel(1),this_channel(2)));


end