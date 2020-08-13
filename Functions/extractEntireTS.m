function extractEntireTS(numEDFFiles,thisChannel)
%description:
%extract time series data for one channel in EDf file format over 32 hours
%save plot and data of entire time series for 32 hours 

%input
%numEDFFiles = number of EDF files provided to read
%note: these EDF files are named numerically (e.g.Data_0001_1.edf), int
%thisChannel = EEG/ECG channel to be analysed (e.g. 'Fp1'), string 

%output
%<channel>_data.mat file in channel_TS_data folder
%TS_<channel>.png files in Raw TS Plots folder

tic;
%% reading data from edf files
%read header for metadata (sampling rate,channel label etc)
hdr=ft_read_header('Data and mat files\\EEG and ECG data\\Data_0001_1.edf'); 

%get index for this channel from hdr
thisInd = find(contains(hdr.label,thisChannel));

%initialise array 
thisChannelData = zeros(1,numEDFFiles*hdr.nSamples);

%read data from all edf files
for i=1:numEDFFiles
    if i<10
        data=ft_read_data(sprintf('Data and mat files\\EEG and ECG data\\Data_000%s_1.edf',int2str(i))); %read data
    else
        data=ft_read_data(sprintf('Data and mat files\\EEG and ECG data\\Data_00%s_1.edf',int2str(i))); 
    end
    
    thisChannelData(1,(1:hdr.nSamples)+(i-1)*hdr.nSamples) = data(thisInd,:);
   
    fprintf('edf File %s extracted\n',int2str(i));
end

fprintf('All edf Files read. Saving all files...\n');
%% save data as .mat file for thisChannel
save(sprintf('Data and mat files\\channel_TS_data\\%s_data.mat',lower(thisChannel)),'thisChannelData');
fprintf('All mat files saved. Plotting time series...\n');

%% plot and save time series for specific channel
Fig = figure;
plot((1:hdr.nSamples*numEDFFiles)./(3600.*(hdr.Fs)),thisChannelData); %plot timecourse

%labels,title etc
xlabel('Time (hr)');
ylabel('Voltage (um)');
xlim([0 inf]);
title(sprintf('%s channel',thisChannel));
grid on;

%save figures
set(gcf,'Position',get(0,'Screensize'));
saveas(gcf,sprintf('Plots and Figures\\Raw TS plots\\TS_%s.png',thisChannel));

fprintf('Figure saved.\n');
toc;
end