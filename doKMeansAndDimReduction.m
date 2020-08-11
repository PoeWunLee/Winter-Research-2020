%% initialising
clear all; clc; 

%path
addpath('Functions');

%% specify dataset to be loaded with some parameters required
thisChannel = input('Which channel?','s');

%perplexity values for 20 mins and 9 hour data
if isempty(strfind(thisChannel,'short')) == 1
    thisPerplex = [1,50,100,200,300,540];
else
    thisPerplex = [1,5,10,20,30,40];
end

clusNum = input('How many clusters?');
epoch_size = input('What is the epoch size?');

%loading the dataset TS_DataMat from HCTSA_<channel>_N.mat file 
load(sprintf('Data and mat files\\hctsa_mat_files\\HCTSA_%s_N.mat',thisChannel),'TS_DataMat');

%% k-means clustering with tSNE and PCA, both 2D and 3D

group2D = tSNEkMeans(TS_DataMat,thisChannel,clusNum,thisPerplex,epoch_size); %2D tSNE, without trajectory
[group3D,explained] = clusterWith3DTraject(TS_DataMat,thisChannel,clusNum,thisPerplex(3),epoch_size); %3D tSNE and PCA, with trajectory

