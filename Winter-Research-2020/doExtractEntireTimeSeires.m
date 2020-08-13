%% initialising
clear all; clc; 

%path
addpath('fieldtrip-20200607'); %add fieldtrip to path
ft_defaults; %set up fieldtrip
addpath('Functions','Data and mat files','Plots and Figures');  %usable functions, data files and figures

%% specifying file specs
hdr=ft_read_header('Data and mat files\\EEG and ECG data\Data_0001_1.edf'); %read metadata (sampling rate, channel label, etc)
numEDFFiles = 96;

%% extract channel data
extractEntireTS(numEDFFiles,'Fp1');
extractEntireTS(numEDFFiles,'Fp2');


