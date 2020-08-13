function numFolds = HowManyFolds(groupLabels,numClasses)
% Set the number of folds for k-fold cross validation using a heuristic
% (for small datasets with fewer than 10 examples per class):
%
%---INPUTS:
% groupLabels, labels of groups in the dataset
% numClasses, the number of classes of time series

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

if nargin < 2
    if iscategorical(groupLabels)
        numClasses = length(categories(groupLabels));
    else
        numClasses = max(groupLabels);
    end
end

if iscategorical(groupLabels)
    classLabels = categories(groupLabels);
    numPerClass = arrayfun(@(x)sum(groupLabels==x),classLabels);
else
    numPerClass = arrayfun(@(x)sum(groupLabels==x),1:numClasses);
end


% Make sure there are enough points in the smallest class to do proper
% cross-validation:
minPointsPerClass = min(numPerClass);

% Now the heuristic to set the number of folds:
if minPointsPerClass < 5
    numFolds = 2;
elseif minPointsPerClass < 10
    numFolds = 5;
else
    numFolds = 10;
end

end
