function out = SY_LocalDistributions(y,numSegs,eachOrPar,numPoints)
% SY_LocalDistributions  Compares the distribution in consecutive time-series segments
%
% Returns the sum of differences between each kernel-smoothed distributions
%
%---INPUTS:
%
% y, the input time series
%
% numSegs, the number of segments to break the time series into
%
% eachOrPar, (i) 'par': compares each local distribution to the parent (full time
%                       series) distribution
%            (ii) 'each': compare each local distribution to all other local
%                         distributions
%
% numPoints, number of points to compute the distribution across (in each local
%          segments) [200 by default]
%
% The operation behaves in one of two modes: each compares the distribution in
% each segment to that in every other segment, and par compares each
% distribution to the so-called 'parent' distribution, that of the full signal.
%
%---OUTPUTS: measures of the sum of absolute deviations between distributions
% across the different pairwise comparisons.

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

% Plot outputs?
doPlot = false;

% ------------------------------------------------------------------------------
% Check inputs:
% ------------------------------------------------------------------------------
if nargin < 2 || isempty(numSegs) % number of segments
    numSegs = 5;
end
if nargin < 3 || isempty(eachOrPar)
    eachOrPar = 'par'; % compare each subsection to full (parent) distribution
end
if nargin < 4 || isempty(numPoints)
    % number of points to compute the distribution across
    numPoints = 200; % 200 by default
end

% ------------------------------------------------------------------------------
% Preliminaries
% ------------------------------------------------------------------------------
N = length(y); % Length of the time series (number of samples)
lseg = floor(N/numSegs);
dns = zeros(numPoints,numSegs);
r = linspace(min(y),max(y),numPoints); % Make range of ksdensity uniform across all subsegments

% ------------------------------------------------------------------------------
% Compute the kernel-smoothed distribution in all numSegs segments of the time series
% ------------------------------------------------------------------------------
for i = 1:numSegs
    dns(:,i) = ksdensity(y((i-1)*lseg+1:i*lseg),r,'function','pdf');
end

if doPlot
    figure('color','w')
    plot(dns,'k')
end

% ------------------------------------------------------------------------------
% Compare the local distributions
% ------------------------------------------------------------------------------
switch eachOrPar
    case {'par','parent'}
        % Compares each subdistribtuion to the parent (full signal) distribution
        pardn = ksdensity(y,r,'function','pdf');
        divs = zeros(numSegs,1);
        for i = 1:numSegs
            divs(i) = sum(abs(dns(:,i)-pardn')); % each is just divergence to parent
        end
        if doPlot
            hold on; plot(pardn,'r','LineWidth',2); hold off
        end
    case 'each'
        % Compares each subdistribtuion to the parent (full signal) distribution
        if numSegs == 2 % output is just an integer: only two distributions to compare
            out = sum(abs(dns(:,1)-dns(:,2)));
            return
        end

        % numSegs > 2: need to compare a number of different distributions against each other
        diffmat = NaN * ones(numSegs); % store pairwise differences
                                    % start as NaN to easily get upper triangle later
        for i = 1:numSegs
            for j = 1:numSegs
                if j > i
                    diffmat(i,j) = sum(abs(dns(:,i)-dns(:,j))); % store sum of absolute differences
                end
            end
        end
        
        divs = diffmat(~isnan(diffmat)); % (the upper triangle of diffmat)
                                         % set of divergences in all pairs of segments of the time series
        % divs = diffmat(diffmat > 0); % a set of non-zero divergences in all pairs of segments of the time series
        % if isempty(divs);
        %     fprintf(1,'That''s strange -- no changes in distribution??! This must be a really strange time series.\n');
        %     out = NaN; return
        % end
    otherwise
        error('Unknown method ''%s'', should be ''each'' or ''par''',eachOrPar);
end

%-------------------------------------------------------------------------------
% Return basic statistics on differences in distributions in different
% segments of the time series
out.meandiv = mean(divs);
out.mediandiv = median(divs);
out.mindiv = min(divs);
out.maxdiv = max(divs);
out.stddiv = std(divs);

end
