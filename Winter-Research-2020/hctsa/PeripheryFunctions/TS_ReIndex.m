function TS_ReIndex(whatData,tsOrOps,overRide)
% TS_ReIndex   Reindexes time series or operations in a data file (new unique indices)
%
%---INPUTS:
% whatData, the hctsa dataset to work with (default: 'norm', cf. TS_LoadData)
% tsOrOps, whether to re-index TimeSeries IDs (specify 'ts') or
%           Operation IDs (specify 'ops'), or both (specify 'both': default).
% overRide, don't check with the user to re-index
%
%---EXAMPLE USAGE:
% Reset index of TimeSeries in HCTSA_N.mat:
% >> TS_ReIndex('norm','ts');

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
% Check inputs and set defaults:
%-------------------------------------------------------------------------------

if nargin < 1
    whatData = 'norm';
end
if isstruct(whatData)
    error('TS_ReIndex works for files only. Specify a filename.');
end

if nargin < 2
    tsOrOps = 'both';
end
if ~ismember(tsOrOps,{'ts','ops','both'})
    error('Invalid tsOrOps = %s, should be ''ts'', ''ops'', or ''both''',tsOrOps);
end

if nargin < 3
    overRide = false; % check with the user that they really want to do this
end

%-------------------------------------------------------------------------------
%% Load data from file
%-------------------------------------------------------------------------------
[~,TimeSeries,Operations,dataFile] = TS_LoadData(whatData);
numTimeSeries = height(TimeSeries);
numOperations = height(Operations);

fromDatabase = TS_GetFromData(dataFile,'fromDatabase');
if fromDatabase
    error(['Shouldn''t be re-indexing data from a mySQL database, as it will' ...
                    ' no longer be matched to the database index']);
end

%-------------------------------------------------------------------------------
% Reindex:
%-------------------------------------------------------------------------------

% --- TimeSeries
if strcmp(tsOrOps,'ts') || strcmp(tsOrOps,'both')
    if ~overRide
        doContinue = input(sprintf('Be careful -- if you press ''y'', the old index system for TimeSeries in %s will be wiped...',dataFile),'s');
        if ~strcmp(doContinue,'y')
            fprintf(1,'Didn''t think so! Better to be save than sorry\n');
        end
    end
    TimeSeries.ID = (1:numTimeSeries)';
    % Save back:
    save(dataFile,'TimeSeries','-append')
    fprintf(1,'Time series re-indexed and saved back to %s.\n',dataFile);
end

% --- Operations
if strcmp(tsOrOps,'ops') || strcmp(tsOrOps,'both')
    if ~overRide
        doContinue = input(sprintf('Be careful -- if you press ''y'', the old index system for Operations in %s will be wiped...',dataFile),'s');
        if ~strcmp(doContinue,'y')
            fprintf(1,'Didn''t think so! Better to be save than sorry\n');
        end
    end
    Operations.ID = (1:numOperations)';
    % Save back:
    save(dataFile,'Operations','-append')
    fprintf(1,'Operations re-indexed and saved back to %s.\n',dataFile);
end

end
