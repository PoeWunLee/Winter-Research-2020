function group = tSNEkMeans(thisDataMat,thisChannel,clusNum,thisPerplex,epoch_size)
%description
%applies kmeans and tSNE (2 principal components) for 6 perplexity values
%on catch22 features for clustering and visualisation

%input
%thisDataMat = TS_DataMat loaded from catch22, table
%thisChannel = name of the study/channel to investigate, string
%clusNum = number of clusters, specified when applying kmeans, int
%thisPerplex = specify perplexity values for tSNE plotting, array
%epoch_size = size in seconds of each epoch (e.g. 30s or 10s), int

%output
%group = cluster grouping of each epoch, array

%% apply k-means clustering
opts = statset('Display','final');
group = kmeans(thisDataMat,clusNum,'Distance','cityblock',...
    'Replicates',10,'Options',opts,'MaxIter',200);


%evaluating performance of clustering, plot silhouette graph
%figure 1: silhouette graph
figure;
silhouette(thisDataMat,group,'Euclidean');
title(sprintf('Silhouette'));
set(gcf,'Position',get(0,'Screensize'));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots\\sil_%s_%.0f.fig',thisChannel,clusNum));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots\\sil_%s_%.0f.png',thisChannel,clusNum));

%% figure : plotting tSNE for all perplexities
numRow = 2;
numCol = ceil(length(thisPerplex)/2);

figure;
%each perplexity is a subplot
for i=1:length(thisPerplex)
    subplot(numRow,numCol,i);
    Y = tsne(thisDataMat,'Algorithm','barneshut','Perplexity',thisPerplex(i));
    gscatter(Y(:,1),Y(:,2),group);
    xlabel('tSNE1')
    ylabel('tSNE2')
    title(sprintf('Perplexity = %.0f',thisPerplex(i)));
end

%saving figures
set(gcf,'Position',get(0,'Screensize'));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots\\tSNE_%s_clus%.0f.fig',thisChannel,clusNum));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots\\tSNE_%s_clus%.0f.png',thisChannel,clusNum));


end
