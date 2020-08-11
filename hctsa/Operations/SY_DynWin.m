function out = SY_DynWin(y,maxNumSegments)
% SY_DynWin  How stationarity estimates depend on the number of time-series subsegments
%
% Specifically, variation in a range of local measures are implemented: mean,
% standard deviation, skewness, kurtosis, ApEn(1,0.2), SampEn(1,0.2), AC(1),
% AC(2), and the first zero-crossing of the autocorrelation function.
%
% The standard deviation of local estimates of these quantities across the time
% series are calculated as an estimate of the stationarity in this quantity as a
% function of the number of splits, n_{seg}, of the time series.
%
%---INPUTS:
%
% y, the input time series.
%
% maxNumSegments, the maximum number of segments to consider. Sweeps from 2 to
%                   maxNumSegments.
%
%
%---OUTPUTS:
%
% The standard deviation of this set of 'stationarity' estimates
% across these window sizes.

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

if nargin < 2 || isempty(maxNumSegments)
    maxNumSegments = 10;
end

nsegr = (2:1:maxNumSegments); % range of nseg to sweep across
nmov = 1; % controls window overlap

numFeatures = 11; % number of features
fs = zeros(length(nsegr),numFeatures); % standard deviation of feature values over windows
taug = CO_FirstCrossing(y,'ac',0,'discrete'); % global tau

for i = 1:length(nsegr)
    nseg = nsegr(i);
    wlen = floor(length(y)/nseg); % window length
    inc = floor(wlen/nmov); % increment to move at each step
    % If increment rounded down to zero, prop it up
    if inc == 0
        inc = 1;
    end

    numSteps = (floor((length(y)-wlen)/inc)+1);
    qs = zeros(numSteps,numFeatures);

    for j = 1:numSteps
        ySub = y((j-1)*inc+1:(j-1)*inc+wlen);
        taul = CO_FirstCrossing(ySub,'ac',0,'discrete');

        % qs.mean(j) = mean(ySub); % mean
        % qs.std(j) = std(ySub); % standard deviation
        % qs.skew(j) = skewness(ySub); % skewness
        % qs.kurt(j) = kurtosis(ySub); % kurtosis
        % qs.apen(j) = EN_ApEn(ySub,1,0.2); % ApEn_1
        % qs.sampen(j) = EN_sampenc(ySub,1,0.2); % SampEn_1
        % qs.ac1(j) = CO_AutoCorr(ySub,1); % AC1
        % qs.ac2(j) = CO_AutoCorr(ySub,2); % AC2
        % qs.tauglob(j) = CO_AutoCorr(ySub,taug); % AC_glob_tau
        % qs.tauloc(j) = CO_AutoCorr(ySub,taul); % AC_loc_tau
        % qs.taul(j) = taul;

        qs(j,1) = mean(ySub); % mean
        qs(j,2) = std(ySub); % standard deviation
        qs(j,3) = skewness(ySub); % skewness
        qs(j,4) = kurtosis(ySub); % kurtosis
        % qs(j,5) = EN_ApEn(ySub,1,0.2); % ApEn_1_02
        sampenStruct = EN_SampEn(ySub,2,0.15);
        qs(j,5) = sampenStruct.quadSampEn1; % SampEn_1_015
        qs(j,6) = sampenStruct.quadSampEn2; % SampEn_2_015
        qs(j,7) = CO_AutoCorr(ySub,1,'Fourier'); % AC1
        qs(j,8) = CO_AutoCorr(ySub,2,'Fourier'); % AC2
        % (Sometimes taug or taul can be longer than ySub; then these will output NaNs:)
        qs(j,9) = CO_AutoCorr(ySub,taug,'Fourier'); % AC_glob_tau
        qs(j,10) = CO_AutoCorr(ySub,taul,'Fourier'); % AC_loc_tau
        qs(j,11) = taul;
    end

    % plot(qs,'o-');
    % input('what do you think?')

    % fs(i,1:numFeatures) = structfun(@(x)std(x),qs,'UniformOutput',1);
    % fs(i) = structfun(@(x)std(x),qs,'UniformOutput',0);
    fs(i,1:numFeatures) = std(qs);
end

% fs contains std of quantities at all different 'scales' (segment lengths)

fs = std(fs); % how much does the 'std stationarity' vary over different scales?

% ------------------------------------------------------------------------------
% Outputs:
% ------------------------------------------------------------------------------
out.stdmean = fs(1);
out.stdstd = fs(2);
out.stdskew = fs(3);
out.stdkurt = fs(4);
out.stdsampen1_015 = fs(5);
out.stdsampen2_015 = fs(6);
out.stdac1 = fs(7);
out.stdac2 = fs(8);
out.stdactaug = fs(9);
out.stdactaul = fs(10);
out.stdtaul = fs(11);

end
