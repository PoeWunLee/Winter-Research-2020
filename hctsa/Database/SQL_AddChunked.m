function SQL_AddChunked(dbc,insertString,dataSet,chunkSize)
% SQL_AddChunked
%
% Insert a large set of time series or operations into the database using
% repeated queries, adding smaller subsets over multiple iterations.
%
%---INPUTS:
%
% dbc, the database connection
% insertString, the insert portion of the query
% dataSet, a cell array of formatted strings like {'(''abc'',1)'}
% chunkSize, the number of queries to run at a time (this parameter can be
%          tweaked depend on the value of max_allowed_packet on the mySQL server)

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

% ------------------------------------------------------------------------------
% Check inputs
% ------------------------------------------------------------------------------

if nargin < 4 || isempty(chunkSize)
    chunkSize = 50; % Run this many queries at a time
    %
end

% ------------------------------------------------------------------------------
% Start adding chunks to the database
% ------------------------------------------------------------------------------
chunkExtent = 0:chunkSize:length(dataSet)-1;
numChunks = length(chunkExtent);
for k = 1:numChunks % loop over chunks

    % Start with the insert statement:
    theQuery = insertString;

    % Move through this chunk:
    for j = 1:chunkSize
        ind = chunkExtent(k) + j;
        if ind > length(dataSet) % don't exceed the dataset size
            break;
        end
        % Grow the query incrementally:
        theQuery = sprintf('%s %s,',theQuery,dataSet{ind}); % Add values in parentheses in dataSet{j}
    end
    % fprintf(1,'%u/%u (%u--%u)\n',k,numChunks,chunkExtent(k)+1,ind);
    theQuery = theQuery(1:end-1); % Remove the final comma

    % Execute this chunk:
    [~, emsg] = mysql_dbexecute(dbc,theQuery);
    if ~isempty(emsg)
        error(['Error in SQL_AddChunked for chunk %u with chunk size %u...\n' ...
                'Attempted query: %s\n%s\n'],k,chunkSize,theQuery,emsg)
    end
end

end
