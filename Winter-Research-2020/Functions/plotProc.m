function plotProc(thisData,thisDataFilt,thisDataSleep,thisDataFiltSleep,startTime,stopTime,thisChannel,sRate)

%description
%periphery function to be called by initINPFile.m to plot 
%1) time course and
%2) PSD vs freq 
%plots to observe effect of bandpass filter on time series data

%input 
%same as initINPFile

%output
%figures saved in <FilterPlots> folder

%check thisChannel if is subtracted
if length(thisChannel) > 1
    thisChannel = sprintf('%s-%s',thisChannel(1),thisChannel(2));
end

%% figure 1: raw TS of filtered and unfiltered
t_array = linspace(startTime,stopTime,length(thisDataSleep)); 

figure;
plot(t_array,thisDataSleep,'b');
xlabel('Time (hr)');
ylabel('Voltage (uV)');
title(sprintf('Time Course %s',thisChannel));

hold on;
plot(t_array,thisDataFiltSleep,'r');
legend('Raw','Bandpass filtered');

%save figure
saveas(gcf,sprintf('Plots and Figures\\FilterPlots\\Time_Course_%s.png',thisChannel));

fprintf('Time Series figure saved \n');

%% figure 2: plot PSD vs freq
%raw PSD calcs
N = length(thisData);
Y = fft(thisData);
Y = Y(1:N/2+1);
psdY = (1/(sRate*N)) * abs(Y).^2;
psdY(2:end-1) = 2*psdY(2:end-1);
f = 0:sRate/N:sRate/2;

%filtered PSD calcs
Y_filt = fft(thisDataFilt);
Y_filt = Y_filt(1:N/2+1);
psdY_filt = (1/(sRate*N)) * abs(Y_filt).^2;
psdY_filt(2:end-1) = 2*psdY_filt(2:end-1);

%plotting PSD vs Freq
figure;
thisPlot = plot(f,abs(psdY),'b',f,abs(psdY_filt),'r');

%plot settings
set(thisPlot(1),'linewidth',2);
set(thisPlot(2),'linewidth',1);
set(gca,'YScale','log');
xlabel('Freq (Hz)');
ylabel('PSD (Power/Freq)');
title(sprintf('PSD of %s',thisChannel));
legend('Raw','Bandpass filtered');
xlim([0 256/2]);

%save figures
saveas(gcf,sprintf('Plots and Figures\\FilterPlots\\PSD_%s.png',thisChannel));

fprintf('PSD vs Freq figure saved \n');
end