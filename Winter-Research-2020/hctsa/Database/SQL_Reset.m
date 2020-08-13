function SQL_Reset()
% SQL_Reset      Drops all tables and data and recreates the default hctsa package
% in the mySQL database

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

[dbc, databaseName] = SQL_OpenDatabase;

% ------------------------------------------------------------------------------
% Get how many time series and operations are in the database
% ------------------------------------------------------------------------------
selectString = 'SELECT COUNT(op_id) as numOps FROM Operations';
numOps = mysql_dbquery(dbc,selectString);
if isempty(numOps), numOps = 0;
else numOps = numOps{1};
end

selectString = 'SELECT COUNT(ts_id) as numTs FROM TimeSeries';
numTs = mysql_dbquery(dbc,selectString);
if isempty(numTs), numTs = 0;
else numTs = numTs{1};
end

% ------------------------------------------------------------------------------
% Make doubly sure the user wants to do this!!:
% ------------------------------------------------------------------------------
if numOps==0 && numTs==0
    % No Operations or Timeseries tables with anything in it
    fprintf(1,['Database does not contain any identifiable Operations or TimeSeries.\n' ...
            'This will drop all tables (if they exist) and populate %s with the hctsa software.\n'], ...
            databaseName);
    reply = input(['Happy with this in ' databaseName '?!?!?! (say ''yes'') '],'s');
else
    % Operations or Timeseries tables exist and contain data
    fprintf(1,['Are you sure you want to DELETE ALL EXISTING DATA FOR %u TIME SERIES' ...
                        ' AND %u OPERATIONS in %s?!\n'],numTs,numOps,databaseName);
    reply = input(['THIS WILL RESET EVERYTHING in ' databaseName '?!?!?! (say ''yes'') '],'s');
    if ~strcmp(reply,'yes')
        fprintf(1,'I didn''t think so... Better to be safe than sorry, hey?\n'); return
    end
    reply = input(sprintf(['Zomg be careful, we''re destroying everything.\n' ...
                            'Confirm that you want %s to be deleted? (say ''yes'') '],databaseName),'s');
end
if ~strcmp(reply,'yes')
    fprintf(1,'I didn''t think so... Better to be safe than sorry, hey?\n'); return
end

% ------------------------------------------------------------------------------
% Drop the database:
% ------------------------------------------------------------------------------
mysql_dbexecute(dbc,sprintf('DROP DATABASE IF EXISTS %s;',databaseName));
fprintf(1,'%s and all the data contained within it dropped.\n',databaseName);
mysql_dbexecute(dbc,sprintf('CREATE DATABASE %s;',databaseName));
SQL_CloseDatabase(dbc) % Close the database
SQL_CreateAllTables; % Create all basic tables required by the database

% Add operations
SQL_Add('mops','Database/INP_mops.txt',1,0);
SQL_Add('ops','Database/INP_ops.txt',1,0);

end
