function TS_SingleFeature(whatData,featID,makeViolin,makeNewFigure,whatStat,beVocal)
% TS_SingleFeature  Plot distributions for a single feature given a feature ID
%
%---INPUTS:
% whatData: the data to load in (cf. TS_LoadData)
% featID: the ID of the feature to plot
% makeViolin: makes a violin plot instead of overlapping kernel-smoothed distributions
% makeNewFigure: generates a new figure
% whatStat: can provide an already-computed stat for the feature (otherwise will
%           compute a simple linear classification based metric)

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
% Check Inputs:
if nargin < 3
    makeViolin = false;
end
if nargin < 4
    makeNewFigure = false;
end
if nargin < 5
    whatStat = [];
end
if nargin < 6
    beVocal = true;
end

%-------------------------------------------------------------------------------
% Load data:
[TS_DataMat,TimeSeries,Operations,whatDataSource] = TS_LoadData(whatData);
% Get classLabels:
if ismember('Group',TimeSeries.Properties.VariableNames)
    classLabels = categories(TimeSeries.Group);
else
    error('You must assign groups to data to use TS_SingleFeature. Use TS_LabelGroups.');
end
numClasses = length(classLabels);

%-------------------------------------------------------------------------------
op_ind = find(Operations.ID==featID);

if isempty(op_ind)
    error('Operation with ID %u not found in %s',featID,whatDataSource);
end
if beVocal
    fprintf(1,'[%u] %s (%s)\n',featID,Operations.Name{op_ind},Operations.Keywords{op_ind});
end

%-------------------------------------------------------------------------------
% Plot this stuff:
if makeNewFigure
    f = figure('color','w');
end
hold('on')
ax = gca;
colors = GiveMeColors(numClasses);

if makeViolin
    dataCell = cell(numClasses,1);
    for i = 1:numClasses
        dataCell{i} = (TS_DataMat(TimeSeries.Group==classLabels{i},op_ind));
    end

    % Re-order groups by mean (excluding any NaNs, descending):
    meanGroup = cellfun(@nanmean,dataCell);
    [~,ix] = sort(meanGroup,'descend');

    extraParams = struct();
    extraParams.theColors = colors(ix);
    extraParams.customOffset = -0.5;
    extraParams.offsetRange = 0.7;
    BF_JitteredParallelScatter(dataCell(ix),1,1,0,extraParams);

    % Adjust appearance:
    ax = gca;
    ax.XLim = [0.5+extraParams.customOffset,numClasses+0.5+extraParams.customOffset];
    ax.XTick = extraParams.customOffset+(1:numClasses);
    ax.XTickLabel = classLabels(ix);
    ax.XTickLabelRotation = 30;
    ylabel('Output')
    ax.TickLabelInterpreter = 'none';
    if makeNewFigure
        f.Position(3:4) = [402,159];
    end

    % Annotate rectangles for predicted intervals:
    cfnParams = GiveMeDefaultClassificationParams(TimeSeries,[],false);
    cfnParams.numFolds = 0;
    BF_AnnotateRect(TS_DataMat(:,op_ind),TimeSeries.Group,cfnParams,colors,ax,'left');

    % Trim y-limits (with 2% overreach)
    ax.YLim(1) = min(TS_DataMat(:,op_ind))-0.02*range(TS_DataMat(:,op_ind));
    ax.YLim(2) = max(TS_DataMat(:,op_ind))+0.02*range(TS_DataMat(:,op_ind));

else
    linePlots = cell(numClasses,1);
    for i = 1:numClasses
        featVector = TS_DataMat(TimeSeries.Group==classLabels{i},op_ind);
        [~,~,linePlots{i}] = BF_plot_ks(featVector,colors{i},0,2,20,1);
    end
    % Trim x-limits (with 2% overreach)
    ax.XLim(1) = min(TS_DataMat(:,op_ind))-0.02*range(TS_DataMat(:,op_ind));
    ax.XLim(2) = max(TS_DataMat(:,op_ind))+0.02*range(TS_DataMat(:,op_ind));

    % Add a legend:
    legend([linePlots{:}],classLabels,'interpreter','none','Location','best')
    ylabel('Probability density')

    % Annotate rectangles:
    BF_AnnotateRect('diaglinear',TS_DataMat(:,op_ind),TimeSeries.Group,numClasses,colors,ax,'under');

    % Add x-label:
    xlabel('Output')

    % Adjust position
    if makeNewFigure
        f.Position(3:4) = [405,179];
    end
end

%-------------------------------------------------------------------------------
% Get cross-validated accuracy for this single feature using a Naive Bayes linear classifier:
if isempty(whatStat)
    cfnParams = GiveMeDefaultClassificationParams(TimeSeries,[],false);
    cfnParams.whatClassifier = 'fast_linear';
    cfnParams.numFolds = 10;
    cfnParams.computePerFold = true;
    accuracy = GiveMeCfn(TS_DataMat(:,op_ind),TimeSeries.Group,[],[],cfnParams);
    fprintf(1,'%u-fold cross-validated %s: %.2f +/- %.2f%%\n',...
                cfnParams.numFolds,cfnParams.whatLoss,mean(accuracy),std(accuracy));
    statText = sprintf('%.1f%s',mean(accuracy),cfnParams.whatLossUnits);
else
    if isnumeric(whatStat)
        statText = sprintf('%.1f',whatStat);
    else % otherwise assume text
        statText = whatStat;
    end
end
title({sprintf('[%u] %s: %s',Operations.ID(op_ind),Operations.Name{op_ind},statText);...
                        ['(',Operations.Keywords{op_ind},')']},'interpreter','none')

end
