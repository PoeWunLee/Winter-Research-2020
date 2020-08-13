function [ts_ind,dataCell,codeEval] = TS_WhichProblemTS(opID,whatData,doPlot)
% TS_WhichProblemTS Lists the indices of the time series with bad values for a given opID
%
%---INPUTS:
% opID: the ID of the operation to investigate
% whatData: hctsa data source (default: 'raw'; cf. TS_LoadData)
% doPlot: plot some examples of problem time series
%
%---OUTPUTS:
% ts_ind: the indices of the time series that produced special-valued outputs
%           for the given operation
% dataCell: the cell of data for time series that led to special-valued outputs
%           for the given operation
% codeEval: the code to evaluate for this operation (i.e., corresponding master)

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
    whatData = 'raw';
end
if nargin < 3
    doPlot = true;
end

%-------------------------------------------------------------------------------
% Load data:
%-------------------------------------------------------------------------------
[~,TimeSeries,Operations,whatData] = TS_LoadData(whatData);
TS_Quality = TS_GetFromData(whatData,'TS_Quality');

%-------------------------------------------------------------------------------
% Get the quality labels for this operation, then output time series info:
%-------------------------------------------------------------------------------
qualityLabels = TS_Quality(:,Operations.ID==opID);

% Indices of time series with bad values:
ts_ind = find(qualityLabels > 0);

if nargout > 1
    % data for these time series
    dataCell = {TimeSeries.Data(ts_ind)};
end

if nargout > 2
    MasterOperations = TS_GetFromData(whatData,'MasterOperations');
    codeEval = MasterOperations.Code{MasterOperations.ID==Operations.MasterID(Operations.ID==opID)};
end

%-------------------------------------------------------------------------------
% Plot some bad ones
if doPlot
    TS_PlotTimeSeries(whatData,10,ts_ind);
end

end
