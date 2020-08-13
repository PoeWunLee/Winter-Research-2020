function [group,explained] = clusterWith3DTraject(thisDataMat,thisChannel,clusNum,thisPerplex,epoch_size)

%description
%applies kmeans to a TS_DataMat table from HCTSA_<channel>_N.mat file from
%<hctsa_mat_files>, then utilises PCA and tSNE for dimension reduction in 3
%dimensions. The figure for each dimension reduciton technique is
%accompanied with the plot of clusters over epochs

%inputs
%thisDataMat = TS_DataMat loaded from a HCTSA_<channel>_N.mat file,table
%thisChannel = dataset to be clustered (e.g. fp1, fp1_proc), string
%clusNum = number of clusters for k-means, int
%thisPerplex = perplexity used for tSNE, int
%epoch_size = size of epoch of this dataset (e.g. 30s or 10s), int

%outputs:
%group = group labels for each epoch, array of int
%explained = variability explained by each principal component of PCA, double

%% apply kmeans in 3D
opts = statset('Display','final');
group = kmeans(thisDataMat,clusNum,'Distance','cityblock',...
    'Replicates',10,'Options',opts,'MaxIter',200);


%% figure 1: silhouette graph
%evaluate kmeans performance with silhouette graph
figure;
silhouette(thisDataMat,group,'Euclidean');
title(sprintf('Silhouette'));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots3D\\sil_%s_%.0f.fig',thisChannel,clusNum));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots3D\\sil_%s_%.0f.png',thisChannel,clusNum));


%% figure 2: plotting tSNE for given perplexities

%apply tSNE with specified perplexity
Fig = figure;
h1 = subplot(1,2,1);
h1.Position = [0.13,0.15,0.55,0.815];
Y = tsne(thisDataMat,'Algorithm','exact','Perplexity',thisPerplex,'NumDimensions',3);

%plot scatter
plotEachCluster(group,Y,clusNum);
hold on;

%plot trajectory
plotTraject(Y);  %self defined function to plot trajectory
hold on;

%titles and labels
set(groot, 'defaultFigureUnits', 'centimeters', 'defaultFigurePosition', [0 0 8.86 7.8]);
xlabel('tSNE1');
ylabel('tSNE2');
zlabel('tSNE3');
title(sprintf('%s t-SNE 3D, Perplexity = %.0f',thisChannel,thisPerplex));

%plot time course by epoch to the side
h2 = subplot(1,2,2);
h2.Position = [0.7,0.11,0.25,0.6];

%color settings
colorArray = get(gca,'ColorOrder');%get default marker colors 
colorArray = colorArray(1:clusNum,:); %assign color to each cluster
colormap(colorArray); 
imagesc(group');
colorbar;

%settings
yticks([]);
xlabel('Epochs (30s)');
title('Cluster over time course');

%save fig
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots3D\\tSNE3D_%s_clus%.0f_perplex%.0f.fig',thisChannel,clusNum,thisPerplex));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots3D\\tSNE3D_%s_clus%.0f_perplex%.0f.png',thisChannel,clusNum,thisPerplex));


%% figure 3: plotting PCA
%apply PCA to dataset
Fig3 = figure;
h3 = subplot(1,2,1);
h3_pos = h3.Position;
h3.Position = [0.13,0.15,0.55,0.815];
[coeff,score,latent,tsquared,explained,mu] = pca(thisDataMat);

%plot scatter
plotEachCluster(group,score,clusNum);
hold on;

%plot trajectory
plotTraject(score);
hold on;

%titles and labels
set(groot, 'defaultFigureUnits', 'centimeters', 'defaultFigurePosition', [0 0 8.86 7.8]);
xlabel(sprintf('PC1, (%.0f)',explained(1)));
ylabel(sprintf('PC2, (%.0f)',explained(2)));
zlabel(sprintf('PC3, (%.0f)',explained(3)));
title(sprintf('%s PCA',thisChannel));

%plot time course by epoch to the side
h3 = subplot(1,2,2);
h3_pos = h3.Position;
h3.Position = [0.7,0.11,0.25,0.6];
 
%color settings
colorArray = get(gca,'ColorOrder');%get default marker colors 
colorArray = colorArray(1:clusNum,:);%assign color to each cluster
colormap(colorArray);
imagesc(group');
colorbar;

%settings
yticks([]);
xlabel('Epochs (30s)');
title('Cluster over time course');
    
%save fig
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots3D\\PCA3D_%s_clus%.0f.fig',thisChannel,clusNum));
saveas(gcf,sprintf('Plots and Figures\\kMeanstSNEPlots3D\\PCA3D_%s_clus%.0f.png',thisChannel,clusNum));

end