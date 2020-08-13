function out = CO_Embed2_Dist(y,tau)
% CO_Embed2_Dist    Analyzes distances in a 2-dim embedding space of a time series.
%
% Returns statistics on the sequence of successive Euclidean distances between
% points in a two-dimensional time-delay embedding space with a given
% time-delay, tau.
%
% Outputs include the autocorrelation of distances, the mean distance, the
% spread of distances, and statistics from an exponential fit to the
% distribution of distances.
%
%---INPUTS:
% y, a z-scored column vector representing the input time series.
% tau, the time delay.

% ------------------------------------------------------------------------------
% Copyright (C) 2020, Ben D. Fulcher <ben.d.fulcher@gmail.com>,
% <http://www.benfulcher.com>
%
% If you use this code for your research, please cite the following two papers:
%
% (1) B.D. Fulcher and N.S. Jones, "hctsa: A Computational Framework for Automated
% Time-Series Phenotyping Using Massive Feature Extraction, Cell Systems 5: 527 (2017).
% DOI: 10.1016/j.cels.2017.10.001
%
% (2) B.D. Fulcher, M.A. Little, N.S. Jones, "Highly comparative time-series
% analysis: the empirical structure of time series and their methods",
% J. Roy. Soc. Interface 10(83) 20130048 (2013).
% DOI: 10.1098/rsif.2013.0048
%
% This function is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program. If not, see <http://www.gnu.org/licenses/>.
% ------------------------------------------------------------------------------

doPlot = false; % whether to plot results
N = length(y); % time-series length

% ------------------------------------------------------------------------------
%% Check inputs:
% ------------------------------------------------------------------------------
if nargin < 2 || isempty(tau)
    tau = 'tau'; % set to the first minimum of autocorrelation function
end
if strcmp(tau,'tau'),
    tau = CO_FirstCrossing(y,'ac',0,'discrete');
    if tau > N/10
        tau = floor(N/10);
    end
end
% Make sure the time series is a column vector
if size(y,2) > size(y,1);
    y = y';
end

% ------------------------------------------------------------------------------
% 2-dimensional time-delay embedding:
% ------------------------------------------------------------------------------
m = [y(1:end-tau), y(1+tau:end)];

% ------------------------------------------------------------------------------
% Plot the embedding:
% ------------------------------------------------------------------------------
if doPlot
    figure('color','w'); box('on'); hold on
    plot(m(:,1),m(:,2),'.');
    plot(m(1:min(200,end),1),m(1:min(200,end),2),'k');
end

% ------------------------------------------------------------------------------
% Calculate Euclidean distances between successive points in this space, d:
% ------------------------------------------------------------------------------

% d = diff(m(:,1)).^2 + diff(m(:,2)).^2; % sum of squared differences
d = sqrt(diff(m(:,1)).^2 + diff(m(:,2)).^2); % Euclidean distance

% Outputs statistics obtained from ordered set of distances between successive
% points in the recurrence space:
acf = CO_AutoCorr(d,[],'Fourier');
out.d_ac1 = acf(2); %CO_AutoCorr(d,1,'Fourier'); % Autocorrelation at lag 1
out.d_ac2 = acf(3); %CO_AutoCorr(d,2,'Fourier'); % Autocorrelation at lag 2
out.d_ac3 = acf(4); %CO_AutoCorr(d,3,'Fourier'); % Autocorrelation at lag 3

out.d_mean = mean(d); % Mean distance
out.d_median = median(d); % Median distance
out.d_std = std(d); % Standard deviation of distances
out.d_iqr = iqr(d); % Interquartile range of distances
out.d_max = max(d); % Maximum distance
out.d_min = min(d); % Minimum distance
out.d_cv = mean(d)/std(d); % Coefficient of variation of distances

% ------------------------------------------------------------------------------
% Empirical distance distribution often fits Exponential distribution quite well
% Fit to all values (often some extreme outliers, but oh well)
l = expfit(d);
nlogL = explike(l,d);
out.d_expfit_nlogL = nlogL;

% Sum of abs differences between exp fit and observed:
% Use a histogram with automatic binning
[N,binEdges] = histcounts(d,'BinMethod','auto','Normalization','probability');
binCentres = mean([binEdges(1:end-1); binEdges(2:end)]);
expf = exppdf(binCentres,l); % exponential fit in each bin
out.d_expfit_meandiff = mean(abs(N - expf)); % mean absolute error of fit

end
