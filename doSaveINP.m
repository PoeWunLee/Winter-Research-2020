%% initialising
clear all; clc;
tic;

%path
addpath('fieldtrip-20200607');
ft_defaults; %setup fieldtrip
addpath('Functions','Data and mat files','Plots and Figures');  %usable functions, data files and figures

%% specify flags, see initINPFile function for description of each
thisChannel = ["fp1","fp2"]; %use double quotation marks, needs to be string array
shortFlag = 0;
procFlag = 1;
epochShortFlag = 0;

%% initialise INP files
initINPFile(thisChannel,shortFlag,procFlag,epochShortFlag)