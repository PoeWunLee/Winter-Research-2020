%% initialisaiton
%path
addpath('Functions','Data and mat files','Plots and Figures');  %usable functions, data files and figures

%array of channel names comparison, (e.g. ["fp1","fp1_proc"])
%note: cannot compare long and short, since number of features/time must be
%the same for comparison!
compare_these = input('Enter comparison datasets'); 

%% compare two data matrix in same figure
Fig = figure;
t = tiledlayout(length(compare_these),1);

for i=1:length(compare_these)
   nexttile;
   plotDataMat(compare_these(i),30);
end

%save figures
saveas(Fig,sprintf('Plots and Figures\\feat op plots\\compare_%s_%s.png',compare_these(1),compare_these(2)));
saveas(Fig,sprintf('Plots and Figures\\feat op plots\\compare_%s_%s.fig',compare_these(1),compare_these(2)));


%% compute and visualise correlation matrix
R = genCorr(compare_these);
