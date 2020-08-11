%% initialising 
clear all; clc; 

%path
addpath(genpath('hctsa'));  %hctsa toolbox
addpath('Functions','Data and mat files','Plots and Figures');  %usable functions, data files and figures


%specify channel/dataset for catch22 analysis
this_channel = 'fp1-fp2_proc';

%% computing catch22
computeThisData(this_channel);

%% Plotting feature op heatmap
plotThisData(this_channel,30);


 














