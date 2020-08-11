function TS_LocalClearRemove.m(whatData,tsOrOps,idRange,doRemove)
% TS_LocalClearRemove.m     Clear or remove data from an hctsa dataset
%
% 'clear' (doRemove = false) means clearing any calculations performed about a
% given time series or operation, but keeping it in the dataset.
% 'remove' (doRemove = true) means removing the time series or operation from
% the dataset completely.
%
% The result is saved back to the hctsa-formatted .mat data file provided as whatData.
%
%---INPUTS:
% tsOrOps -- either 'ts' or 'ops' for whether to work with either time series
% 				or operations
% idRange -- a vector of the IDs (of either time series or operations) to remove
% doRemove -- (binary) whether to remove entries (specify 1), or just clear
% 				 their data (specify 0).
% whatData -- the file to load the hctsa dataset from (cf. TS_LoadData).
%
%---EXAMPLE USAGE:
% This clears the data about the time series with IDs 1,2,3,4, and 5 from the hctsa dataset
% stored in HCTSA.mat:
% >> TS_LocalClearRemove.m('HCTSA.mat','ts',1:5,false);
%
% This *removes* the time series with IDs from 1:5 from the dataset completely:
% >> TS_LocalClearRemove.m('HCTSA.mat','ts',1:5,true);
%
% IDs for a given keyword can be retrieved using TS_GetIDs. This example removes
% all time series from HCTSA.mat that have the keyword 'noise':
% >> noiseIDs = TS_GetIDs('noise','HCTSA.mat','ts');
% >> TS_LocalClearRemove.m('HCTSA.mat','ts',noiseIDs,true);

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
%% Preliminaries and input checking
%-------------------------------------------------------------------------------

if nargin < 1 || isempty(whatData)
    whatData = 'raw'; % normally want to clear data from the local store
end

if nargin < 2
	tsOrOps = 'ts';
end
switch tsOrOps
case 'ts'
    theWhat = 'TimeSeries';
case 'ops'
    theWhat = 'Operations';
case 'mops'
    theWhat = 'MasterOperations';
otherwise
    error('Specify ''mops'', ''ts'', or ''ops''')
end

% Must specify a set of time series
if nargin < 3 || min(size(idRange)) ~= 1
	error('Specify a range of IDs');
end

if nargin < 4 % doRemove
    error('You must specify whether to remove the %s or just clear their data results',theWhat)
end

% ------------------------------------------------------------------------------
%% Load data
% ------------------------------------------------------------------------------
[TS_DataMat,TimeSeries,Operations,whatDataFile] = TS_LoadData(whatData);

%-------------------------------------------------------------------------------
% Match IDs to indices
%-------------------------------------------------------------------------------
switch tsOrOps
case 'ts'
    dataTable = TimeSeries;
    theNameField = 'Name';
case 'ops'
    dataTable = Operations;
    theNameField = 'Name';
case 'mops'
	loadedMore = load(whatDataFile,'MasterOperations');
    MasterOperations = loadedMore.MasterOperations;
    dataTable = MasterOperations;
    theNameField = 'Label';
otherwise
    error('Specify ''ts'' or ''ops'' or ''mops''');
end
IDs = dataTable.ID;
doThese = ismember(IDs,idRange);

if ~any(doThese)
    error('No matches to the IDs provided for %s',tsOrOps);
end

% ------------------------------------------------------------------------------
%% Provide some user feedback
% ------------------------------------------------------------------------------
if ~doRemove % clear data
    doWhat = 'Clear data from';
else
    doWhat = '*PERMENANTLY REMOVE*';
end

iThese = find(doThese);
for i = 1:sum(doThese)
    fprintf(1,'%s [%u] %s\n',doWhat,IDs(iThese(i)),dataTable.(theNameField){iThese(i)});
end

if doRemove % clear data
	input(sprintf(['Preparing to REMOVE %u %s -- DRASTIC STUFF! ' ...
            'I HOPE THIS IS OK?!\n[press any key to continue, ctrl-C to abort]'], ...
                                sum(doThese),theWhat),'s');
else
    input(sprintf(['**Preparing to clear all calculated data for %u %s.\n' ...
                        '[press any key to continue, ctrl-C to abort]'], ...
                                    sum(doThese),theWhat),'s');
end

% ------------------------------------------------------------------------------
%% Check what to clear/remove
% ------------------------------------------------------------------------------
if doRemove
    % Need to actually remove metadata entries:
    switch tsOrOps
	case 'ts'
        TimeSeries(doThese,:) = [];
    case 'ops'
        Operations(doThese,:) = [];
	case 'mops'
		MasterOperations(doThese,:) = [];
    end
end

if strcmp(tsOrOps,'mops')
	save(whatDataFile,'MasterOperations','-append');
else
	% Clear or remove data from local matrices:
	TS_DataMat = f_clear_remove(TS_DataMat,doThese,tsOrOps,doRemove);

	% Save back to file
	save(whatDataFile,'TS_DataMat','TimeSeries','Operations','-append');

	% Repeat for any other matrix data files:
	varNames = whos('-file',whatDataFile);
	varNames = {varNames.name};
	if ismember('TS_Quality',varNames)
	    load(whatDataFile,'TS_Quality')
	    TS_Quality = f_clear_remove(TS_Quality,doThese,tsOrOps,doRemove);
	    save(whatDataFile,'TS_Quality','-append');
	end
	if ismember('TS_CalcTime',varNames)
	    load(whatDataFile,'TS_CalcTime')
	    TS_CalcTime = f_clear_remove(TS_CalcTime,doThese,tsOrOps,doRemove);
	    save(whatDataFile,'TS_CalcTime','-append');
	end
end

fprintf(1,'Saved back to %s\n',whatDataFile);

%-------------------------------------------------------------------------------
function A = f_clear_remove(A,ind,tsOrOps,doRemove)
	% Clears or removes data from a matrix, given a set of row or column indices
    if doRemove
        if strcmp(tsOrOps,'ts')
            A(ind,:) = [];
        else
            A(:,ind) = [];
        end
    else
        if strcmp(tsOrOps,'ts')
            A(ind,:) = NaN;
        else
            A(:,ind) = NaN;
        end
    end
end
%-------------------------------------------------------------------------------

end
