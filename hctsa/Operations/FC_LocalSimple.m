function out = FC_LocalSimple(y,forecastMeth,trainLength)
% FC_LocalSimple    Simple local time-series forecasting.
%
% Simple predictors using the past trainLength values of the time series to
% predict its next value.
%
%---INPUTS:
% y, the input time series
%
% forecastMeth, the forecasting method:
%          (i) 'mean': local mean prediction using the past trainLength time-series
%                       values,
%          (ii) 'median': local median prediction using the past trainLength
%                         time-series values
%          (iii) 'lfit': local linear prediction using the past trainLength
%                         time-series values.
%
% trainLength, the number of time-series values to use to forecast the next value
%
%---OUTPUTS: the mean error, stationarity of residuals, Gaussianity of
% residuals, and their autocorrelation structure.

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

% ------------------------------------------------------------------------------
% Check inputs
% ------------------------------------------------------------------------------
% Forecasting method, forecastMeth
if nargin < 2 || isempty(forecastMeth)
    forecastMeth = 'mean';
end
% Number of samples to train with, trainLength
if nargin < 2 || isempty(trainLength)
    trainLength = 3;
end

N = length(y); % Time-series length

% ------------------------------------------------------------------------------
% Do the local prediction
% ------------------------------------------------------------------------------
if strcmp(trainLength,'ac')
    % Make it first zero-crossing of ACF:
    lp = CO_FirstCrossing(y,'ac',0,'discrete');
else
    lp = trainLength; % the length of the subsegment preceeding to use to predict the subsequent value
end
evalr = lp+1:N; % range over which to evaluate the forecast
if length(evalr)==0
    warning('Time series too short for forecasting');
    out = NaN;
    return
end
res = zeros(length(evalr),1); % residuals

switch forecastMeth
    case 'mean'
        for i = 1:length(evalr)
            res(i) = mean(y(evalr(i)-lp:evalr(i)-1)) - y(evalr(i)); % prediction-value
        end
    case 'median'
        for i = 1:length(evalr)
            res(i) = median(y(evalr(i)-lp:evalr(i)-1)) - y(evalr(i)); % prediction-value
        end
    case 'lfit'
        for i = 1:length(evalr)
            % Fit linear
            warning('off','MATLAB:polyfit:PolyNotUnique'); % Disable (potentially important ;)) warning
            p = polyfit((1:lp)',y(evalr(i)-lp:evalr(i)-1),1);
            warning('on','MATLAB:polyfit:PolyNotUnique'); % Re-enable warning
            res(i) = polyval(p,lp+1) - y(evalr(i)); % prediction - value
        end
    otherwise
        error('Unknown forecasting method ''%s''',forecastMeth);
end

% out=res;
% plot(res);

% ------------------------------------------------------------------------------
% Output statistics on the residuals, res
% ------------------------------------------------------------------------------

% Mean residual (mean error/bias):
out.meanerr = mean(res);

% Spread of residuals:
out.stderr = std(res);
out.meanabserr = mean(abs(res));

% Stationarity of residuals:
out.sws = SY_SlidingWindow(res,'std','std',5,1);
out.swm = SY_SlidingWindow(res,'mean','std',5,1);

% Normality of residuals:
tmp = DN_SimpleFit(res,'gauss1',0);
if ~isstruct(tmp) && isnan(tmp) % fitting failed
    out.gofr2 = NaN;
else
    out.gofr2 = tmp.r2; % r-squared
end

% Autocorrelation structure of the residuals:
out.ac1 = CO_AutoCorr(res,1,'Fourier');
out.ac2 = CO_AutoCorr(res,2,'Fourier');
out.taures = CO_FirstCrossing(res,'ac',0,'continuous');
out.tauresrat = CO_FirstCrossing(res,'ac',0,'continuous')/CO_FirstCrossing(y,'ac',0,'continuous');

end
