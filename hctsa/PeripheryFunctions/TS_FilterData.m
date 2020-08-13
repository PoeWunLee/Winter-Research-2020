function newFileName = TS_FilterData(whatData,ts_keepIDs,op_keepIDs,newFileName)
% TS_FilterData  Filters data in the hctsa data file, and saves to a new file
%
% Can use TS_GetIDs to search keywords in hctsa data structures to get IDs
% matching keyword constraints, and use them to input into this function to
% generate hctsa files filtered by keyword matches.
%
%---INPUTS:
% whatData, the input to TS_LoadData that describes the data to load in
% ts_keepIDs, a vector of TimeSeries IDs to keep (empty to keep all)
% op_keepIDs, a vector of Operations IDs to keep (empty to keep all)
%
%---OUTPUT:
% newFileName, the filename of the .mat file that the new, filtered data is saved to
%
%---USAGE:
%
% (*) Remove length-dependent features from a raw ('HCTSA.mat') file and save to a
% new file, 'HCTSA_notLocDep.mat':
% >>[~,IDs_notlocDep] = TS_GetIDs('lengthdep','raw','ops');
% >>TS_FilterData('raw',[],ID_notlocDep,'HCTSA_notLocDep.mat');
%
% (*) Keep only time series with the keyword 'patient' from an hctsa file:
% >> IDs_patient = TS_GetIDs('patient','raw','ts');
% >> TS_FilterData('raw',IDs_Patient,[],'HCTSA_noPatient.mat');
%
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
% Check inputs:
%-------------------------------------------------------------------------------
if nargin < 2
    error('Insufficient input arguments');
end
if nargin < 3
    op_keepIDs = [];
end
if nargin < 4
    newFileName = '';
end

%-------------------------------------------------------------------------------
% Load data
%-------------------------------------------------------------------------------
[TS_DataMat,TimeSeries,Operations,whatDataFile] = TS_LoadData(whatData);

% May be feeding in a loaded data structure:
TS_Quality = TS_GetFromData(whatData,'TS_Quality');
MasterOperations = TS_GetFromData(whatData,'MasterOperations');
% First check that fromDatabase exists (for back-compatability):
fromDatabase = TS_GetFromData(whatData,'fromDatabase');
if isempty(fromDatabase)
    fromDatabase = true; % (set to true if doesn't exist; for legacy compatability)
end
% Check that we have the classLabels if already assigned labels:
if ismember('Group',TimeSeries.Properties.VariableNames)
    classLabels = categories(TimeSeries.Group);
else
    classLabels = {};
end
% Check if normalizationInfo is present:
normalizationInfo = TS_GetFromData(whatData,'normalizationInfo');
if isempty(normalizationInfo)
    normalizationInfo = '';
end

%-------------------------------------------------------------------------------
% Do the row filtering:
%-------------------------------------------------------------------------------
if ~isempty(ts_keepIDs)
    % Match IDs to local indices:
    keepRows = ismember(TimeSeries.ID,ts_keepIDs);
    % A couple of basic checks first:
    if sum(keepRows)==0
        error('No time series to keep');
    end
    if all(keepRows)
        warning('Keeping all time series; no need to filter...?');
    end
    fprintf(1,'Keeping %u/%u time series from the data in %s\n',...
                        sum(keepRows),length(keepRows),whatDataFile);
    TimeSeries = TimeSeries(keepRows,:);
    TS_DataMat = TS_DataMat(keepRows,:);
    TS_Quality = TS_Quality(keepRows,:);
end

if ~isempty(op_keepIDs)
    % Match IDs to local indices:
    keepCols = ismember(Operations.ID,op_keepIDs);
    % A couple of basic checks first:
    if sum(keepCols)==0
        error('No operations to keep');
    end
    if all(keepCols)
        error('Keeping all operations; no need to filter...?');
    end
    fprintf(1,'Keeping %u/%u operations from the data in %s\n',...
                        sum(keepCols),length(keepCols),whatDataFile);
    Operations = Operations(keepCols,:);
    TS_DataMat = TS_DataMat(:,keepCols);
    TS_Quality = TS_Quality(:,keepCols);
end

% ------------------------------------------------------------------------------
% Reset default clustering details (will not be valid now)
% ------------------------------------------------------------------------------
ts_clust = struct('distanceMetric','none','Dij',[],...
                'ord',1:size(TS_DataMat,1),'linkageMethod','none');
op_clust = struct('distanceMetric','none','Dij',[],...
                'ord',1:size(TS_DataMat,2),'linkageMethod','none');

%-------------------------------------------------------------------------------
% Save back
%-------------------------------------------------------------------------------
if isempty(newFileName)
    if isstruct(whatData)
        newFileName = 'HCTSA_filtered.mat';
    else
        newFileName = [whatData(1:end-4),'_filtered.mat'];
    end
end
fprintf(1,'Saving the filtered data to %s...',newFileName);
save(newFileName,'TS_DataMat','TS_Quality','TimeSeries','Operations', ...
        'MasterOperations','fromDatabase','classLabels','normalizationInfo',...
        'ts_clust','op_clust','-v7.3');
fprintf(1,'Done.\n');

end
