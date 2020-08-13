function UKeywords = TS_WhatKeywords(whatData)
% TS_WhatKeywords   Lists keywords contained in the specified HCTSA data file

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
% This work is licensed under the Creative Commons
% Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of
% this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send
% a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View,
% California, 94041, USA.
% ------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Check inputs, set defaults:
%-------------------------------------------------------------------------------
if nargin < 1
    whatData = 'raw';
end

% ------------------------------------------------------------------------------
%% Load data from file
% ------------------------------------------------------------------------------
[~,TimeSeries] = TS_LoadData(whatData);
Keywords = SUB_cell2cellcell(TimeSeries.Keywords); % Split into sub-cells using comma delimiter
keywordsAll = [Keywords{:}]; % every keyword used across the dataset
UKeywords = unique(keywordsAll);
numUniqueKeywords = length(UKeywords);
keywordCounts = cellfun(@(x)sum(strcmp(keywordsAll,x)),UKeywords);

[~,ix] = sort(keywordCounts,'descend');

fprintf(1,'\nKeyword   # Occurences\n\n');
for i = 1:numUniqueKeywords
    fprintf(1,'''%s''   %u\n',UKeywords{ix(i)},keywordCounts(ix(i)));
end

if nargout==0
    clear('UKeywords')
end

end
