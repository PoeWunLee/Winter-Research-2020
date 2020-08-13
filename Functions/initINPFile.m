function initINPFile(thisChannel,shortFlag,procFlag,epochShortFlag)

%description
%initialise channel data from <channel>_data.mat file into INP file
%INP files are a requirement for catch22/hctsa analysis to work
%this function also allows several options 

%input: thisChannel = string variable or string array. If array, the
%                     dataset from first element will subtract the second 
%       shortFlag = 0 for full sleep length
%                   1 for 20 mins
%       procFlag = 0 for no bandpasss filter
%                  1 for bandpass filter ([0.2 40] Hz)
%       epochShortFlag = 0 for 30s epoch
%                        1 for 10s epoch

%output: INP file saved for hctsa/catch22 in <INP_Files> folder
                       

hdr=ft_read_header('EEG and ECG data\\Data_0001_1.edf'); %read metadata (sampling rate, channel label, etc)

%% variable handling according to flags
% load this channel data

%if more than one channel inputed, subtraction of first and second datasets
if length(thisChannel) > 1
    temp = load(sprintf('Data and mat files\\channel_TS_data\\%s_data.mat',thisChannel(1))).thisChannelData;
    thisData = temp - load(sprintf('Data and mat files\\channel_TS_data\\%s_data.mat',thisChannel(2))).thisChannelData;
else
    thisData = load(sprintf('Data and mat files\\channel_TS_data\\%s_data.mat',thisChannel)).thisChannelData;
end

scale = 1200/(3600*hdr.nSamples); %scaling factor: data points to time points and vice versa

%index out 'sleep' region
if shortFlag == 1;
    startTime = 13;
    stopTime = 13+1/3;
else
    startTime = 12;
    stopTime = 21;
end

%index out sleep region
thisDataSleep = thisData(1,(startTime./scale:(stopTime./scale)-1));

%if bandpass filter is applied, additional filtered variable
if procFlag == 1
    thisDataFilt = bandpass(thisData,[0.2,40],hdr.Fs);
    thisDataFiltSleep = thisDataFilt(1,(startTime./scale:(stopTime./scale)-1));
end

%epoch num and size
if epochShortFlag == 1
    epoch_size = 10/(scale*3600);
else
    epoch_size = 30/(scale*3600);
end

epoch_num = length(thisDataSleep)/epoch_size;
fprintf('Variable handling done \n');

%% plotting time course of filtered and unfiltered if bandpass filtered
    
if procFlag ==1
    plotProc(thisData,thisDataFilt,thisDataSleep,thisDataFiltSleep,startTime,stopTime,thisChannel,hdr.Fs);
end

%% convert to required formats to INP file for catch22

%1st matrix: timeSeriesData
%convert to cell format
%if filtered, use filtered TS data. Else, use unfiltered data
if procFlag == 1
    timeSeriesData = mat2cell(reshape(thisDataFiltSleep,epoch_num,epoch_size),ones(1,epoch_num)); %reshape to epochs
else
    timeSeriesData = mat2cell(reshape(thisDataSleep,epoch_num,epoch_size),ones(1,epoch_num)); %reshape to epochs
end
 
%2nd and 3rd matrices: labels and keywords
%create labels and keywords
labels = cell(epoch_num,1);
keywords = cell(epoch_num,1);

for i=1:epoch_num
    labels{i,1} = sprintf('sleep_%.1fmin', (i-1)*0.5);
end

%initialise keywords
keys = ['1';'2';'3';'4'];

for j=1:length(keys)
    index1 = (j-1)*epoch_num/length(keys) +1;
    index2 = (j)*epoch_num/length(keys);
    keywords(index1:index2,1) = {keys(j)};
end

fprintf('Keys and labels initialised \n');
%% save to INP file

%if more than one channel inputed, subtraction
if length(thisChannel) > 1
    thisName = sprintf('%s-%s',thisChannel(1),thisChannel(2));
else
    thisName = thisChannel;
end

%if short
if shortFlag ==1
    thisName = sprintf('%s_short',thisName)
end

%if pre-processed/filtered
if procFlag == 1
    thisName = sprintf('%s_proc',thisName)
end

%save INP file
save(sprintf('Data and mat files\\INP_Files\\INP_test_sleep_%s.mat',thisName),'timeSeriesData','labels','keywords');
fprintf('INP file saved');

end










