function TS_FeatureSummary(opID,whatData,doViolin,annotateParams)
% TS_FeatureSummary   How a given feature behaves across a time-series dataset
%
% Plots the distribution of outputs of an operation across the given dataset
% and allows the user to annotate time series onto the plot to visualize
% how the operation is behaving.
%
%---INPUTS:
% opID, the operation ID to plot
% whatData, the data to visualize (HCTSA.mat by default; cf. TS_LoadData)
% annotateParams, a structure of custom plotting options

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
% Check inputs
%-------------------------------------------------------------------------------
if nargin < 1
    opID = 1;
end
if nargin < 2 || isempty(whatData)
   whatData = 'raw'; % Visualize unnormalized outputs by default
end
if nargin < 3 || isempty(doViolin) % annotation parameters
    doViolin = true;
end
if nargin < 4 || isempty(annotateParams) % annotation parameters
    annotateParams = struct();
end

%-------------------------------------------------------------------------------
% Load in data:
%-------------------------------------------------------------------------------
[TS_DataMat,TimeSeries,Operations] = TS_LoadData(whatData);
theOp = (Operations.ID==opID);
if ~any(theOp)
    error('No matches for operation ID %u',opID);
end

dataVector = TS_DataMat(:,theOp); % the outputs of interest
notNaN = find(~isnan(dataVector));
dataVector = dataVector(notNaN); % remove bad values
TimeSeries = TimeSeries(notNaN,:); % remove bad values
theOperation = table2struct(Operations(theOp,:));

if isempty(dataVector)
    error('No data for %s',theOperation.Name);
end

% Retrieve group names also:
if ~ismember('Group',TimeSeries.Properties.VariableNames)
    timeSeriesGroup = [];
    classLabels = {};
    numGroups = 0;
else
    timeSeriesGroup = TimeSeries.Group; % Use group form
    classLabels = categories(timeSeriesGroup);
    timeSeriesGroupInteger = arrayfun(@(x)find(classLabels==x),timeSeriesGroup);
    numGroups = length(classLabels);
    annotateParams.groupColors = BF_GetColorMap('set1',numGroups,1);
end

%-------------------------------------------------------------------------------
% Apply default plotting settings in the annotateParams structure
if ~isfield(annotateParams,'userInput')
    annotateParams.userInput = true; % user clicks to annotate rather than randomly chosen
end
if ~isfield(annotateParams,'textAnnotation') % what text annotation to use
    annotateParams.textAnnotation = 'Name';
end
if ~isfield(annotateParams,'n')
    annotateParams.n = min(15,height(TimeSeries));
end
if annotateParams.n < 1
    error('You need to specify at least one time series to annotate with TS_FeatureSummary');
end
if ~isfield(annotateParams,'maxL')
    annotateParams.maxL = 1000;
end

%-------------------------------------------------------------------------------
% Plot the kernel-smoothed probability density
%-------------------------------------------------------------------------------
f = figure('color','w');
box('on'); hold('on');

if doViolin
    % Violin plots
    rainbowColors = [BF_GetColorMap('set1',5,1); BF_GetColorMap('dark2',5,1)];

    % Determine a subset, highlightInd, of time series to highlight:
    [~,ix] = sort(TS_DataMat(:,theOp),'ascend');
    highlightInd = ix(round(linspace(1,length(ix),annotateParams.n)));

    if ~isempty(timeSeriesGroup)
        dataCell = cell(numGroups+1,1);
        dataCell{1} = TS_DataMat(:,theOp); % global distribution
        for i = 1:numGroups
            dataCell{i+1} = TS_DataMat(timeSeriesGroup==classLabels{i},theOp);
        end

        myColors = cell(numGroups+1,1);
        myColors{1} = ones(3,1)*0.5; % gray for combined
        myColors(2:numGroups+1) = GiveMeColors(numGroups);
        extraParams = struct();
        extraParams.theColors = myColors;
        extraParams.customOffset = -0.5;
        extraParams.offsetRange = 0.7;

        ax = subplot(1,4,1:2);
        [ff,xx] = BF_JitteredParallelScatter(dataCell,1,1,0,extraParams);

        % Annotate lines for each feature in the distribution:
        for i = 1:annotateParams.n
            ri = find(xx{1}>=TS_DataMat(highlightInd(i),theOp),1);
            plot(0.5+0.35*[-ff{1}(ri),ff{1}(ri)],ones(2,1)*xx{1}(ri),'color',rainbowColors{rem(i-1,10)+1},'LineWidth',2)
            groupColor = myColors{1+timeSeriesGroupInteger(highlightInd(i))};
            plot(0.5+0.35*ff{1}(ri),xx{1}(ri),'o','MarkerFaceColor',groupColor,'MarkerEdgeColor',groupColor)
            plot(0.5-0.35*ff{1}(ri),xx{1}(ri),'o','MarkerFaceColor',groupColor,'MarkerEdgeColor',groupColor)
        end
        ax.XTick = 0.5+(0:numGroups);
        axisLabels = cell(numGroups+1,1);
        axisLabels{1} = 'all';
        axisLabels(2:end) = classLabels;
        ax.XTickLabel = axisLabels;
        ax.XTickLabelRotation = 20;
    else
        % Just run a single global one
        extraParams = struct();
        extraParams.theColors = {ones(3,1)*0.5};

        ax = subplot(1,4,1:2);
        [ff,xx] = BF_JitteredParallelScatter({TS_DataMat(:,theOp)},1,1,0,extraParams);

        % Annotate lines for each feature in the distribution:
        for i = 1:annotateParams.n
            ri = find(xx{1}>=TS_DataMat(highlightInd(i),theOp),1);
            rainbowColor = rainbowColors{rem(i-1,10)+1};
            plot(1+0.25*[-ff{1}(ri),ff{1}(ri)],ones(2,1)*xx{1}(ri),'color',rainbowColor,'LineWidth',2)
            plot(1+0.25*ff{1}(ri),xx{1}(ri),'o','MarkerFaceColor',rainbowColor,'MarkerEdgeColor',rainbowColor)
            plot(1-0.25*ff{1}(ri),xx{1}(ri),'o','MarkerFaceColor',rainbowColor,'MarkerEdgeColor',rainbowColor)
        end
        ax.XTick = [];
    end
    ax.TickLabelInterpreter = 'none';
    title(sprintf('[%u]%s (%s)',theOperation.ID,theOperation.Name,theOperation.Keywords),...
                                'interpreter','none')
    ylabel('Feature value');

    %-------------------------------------------------------------------------------
    % Time series annotations using TS_PlotTimeSeries
    % (cycling through groups of 10 rainbow colors):
    ax = subplot(1,4,3:4);
    plotOptions.newFigure = false;
    plotOptions.colorMap = cell(annotateParams.n,1);
    for i = 1:annotateParams.n
        plotOptions.colorMap{i} = rainbowColors{rem(i-1,10)+1};
    end
    plotOptions.colorMap = flipud(plotOptions.colorMap);

    TS_PlotTimeSeries(TimeSeries,annotateParams.n,flipud(highlightInd),annotateParams.maxL,plotOptions);

    % Put rectangles if data is grouped
    if ~isempty(timeSeriesGroup)
        rectHeight = 1/annotateParams.n;
        rectWidth = 0.1;
        for i = 1:annotateParams.n
            rectangle('Position',[-rectWidth*1,(i-1)*rectHeight,rectWidth,rectHeight],...
                            'FaceColor',myColors{1+timeSeriesGroupInteger(highlightInd(i))});
        end
        ax.XLim = [-rectWidth,1];
    end

    fig.Position(3:4) = [1151,886];

else % kernel distributions
    if ~isempty(timeSeriesGroup)
        % Repeat for each group
        fx = cell(numGroups,1);
        lineHandles = cell(numGroups+1,1);
        tsInd = cell(numGroups,1); % keeps track of indices from TimeSeries structure

        % Global distribution:
        [~,~,lineHandles{1}] = BF_plot_ks(dataVector,ones(1,3)*0.5,0,1,8);

        % Distribution for each group:
        for k = 1:numGroups
            [fr,xr,lineHandles{k+1}] = BF_plot_ks(dataVector(timeSeriesGroup==classLabels{k}),...
                                annotateParams.groupColors{k},0,2,12);
            fx{k} = [xr',fr'];
            tsInd{k} = find(timeSeriesGroup==classLabels{k});
        end
        xy = vertcat(fx{:});
        % Now make sure that elements of TimeSeries matches ordering of xy
        tsInd = vertcat(tsInd{:});
        ix = arrayfun(@(x)find(x==tsInd),1:height(TimeSeries));
        TimeSeries = TimeSeries(tsInd,:);

        % Set up legend:
        legendText = cell(length(classLabels)+1,1);
        legendText{1} = 'combined';
        legendText(2:end) = classLabels;
        legend(horzcat(lineHandles{:}),legendText)

    else
        % Just run a single global one (black)
        [fr,xr] = BF_plot_ks(dataVector,'k',0,1.5,10);
        xy = [xr',fr'];
    end

    f.Position = [f.Position(1:2),649,354];

    %-------------------------------------------------------------------------------
    % Annotate time series:
    xlabel(theOperation.Name,'Interpreter','none');
    ylabel('Probability Density')
    BF_AnnotatePoints(xy,TimeSeries,annotateParams);
    title(sprintf('[%u] %s (%u-sample annotations)',opID,theOperation.Name, ...
                    annotateParams.maxL),'Interpreter','none');
    xlabel('Outputs','Interpreter','none');
end

end
