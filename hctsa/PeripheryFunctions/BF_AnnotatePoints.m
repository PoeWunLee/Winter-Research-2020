function BF_AnnotatePoints(xy,TimeSeries,annotateParams)
% BF_AnnotatePoints     Annotates time series/metadata to a plot
%
%---INPUTS:
% xy, a vector (or cell) of x-y co-ordinates of points on the plot
% TimeSeries, a table of time series making up the plot
% annotateParams, structure of custom plotting parameters

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

numTimeSeries = height(TimeSeries);

% ------------------------------------------------------------------------------
%% Set default plotting parameters:
% ------------------------------------------------------------------------------
if isfield(annotateParams,'n')
    numAnnotate = annotateParams.n;
else
    numAnnotate = 6;
end
if numAnnotate==0 % no need to go further
    return
end
% Cannot allow to annotate more points than time series
numAnnotate = min(numAnnotate,numTimeSeries);
if isfield(annotateParams,'maxL')
    maxL = annotateParams.maxL;
else
    maxL = 300; % length of annotated time series segments
end
if isfield(annotateParams,'userInput')
    userInput = annotateParams.userInput;
else
    userInput = true; % user input points rather than being randomly chosen
end
if isfield(annotateParams,'fdim')
    fdim = annotateParams.fdim;
else
    fdim = [0.30,0.08]; % width, height
end
% textAnnotation can be: 'Name' (annotate name),
% 'ID' (annotate ts_id), or 'none' (not annotation)
if isfield(annotateParams,'textAnnotation')
    if ismember(annotateParams.textAnnotation,{'Name','ID','none'})
        textAnnotation = annotateParams.textAnnotation;
    else
        warning('Unknown annotation type: %s',annotateParams.textAnnotation);
        textAnnotation = 'none'; % no annotations by default
    end
else
    textAnnotation = 'none'; % no annotations by default
end
if isfield(annotateParams,'theLineWidth')
    theLineWidth = annotateParams.theLineWidth;
else
    theLineWidth = 0.8; % % line width for time series
end
% Work through colors of the rainbow if only one class:
if isfield(annotateParams,'doRainbow')
    doRainbow = annotateParams.doRainbow;
else
    doRainbow = true;
end
plotCircle = true; % circle around annotated points

%-------------------------------------------------------------------------------

% Want on a common scale for finding neighbors:
xy_std = std(xy);
xy_mean = mean(xy);
xy_zscore = zscore(xy);

% Initializing basic parameters/variables:
ax = gca;
pxlim = ax.XLim; % plot limits
pylim = ax.YLim; % plot limits
pWidth = diff(pxlim); % plot width
pHeight = diff(pylim); % plot height
alreadyPicked = zeros(numAnnotate,1); % record those already picked

% Groups:
[groupLabels,classLabels,groupLabelsInteger,numGroups] = ExtractGroupLabels(TimeSeries);

% Colors:
if ~isfield(annotateParams,'groupColors')
    groupColors = GiveMeGroupColors(annotateParams,numGroups); % Set colors
else
    groupColors = annotateParams.groupColors;
end
if numGroups==1
    if doRainbow
        rainbowColors = [BF_GetColorMap('set1',5,1); BF_GetColorMap('dark2',6,1)];
    else
        % all black:
        rainbowColors = repmat([0,0,0],20,1);
        rainbowColors = mat2cell(rainbowColors,ones(20,1));
    end
end

%-------------------------------------------------------------------------------
% Don't use user input to select points to annotate: instead they are selected randomly
%-------------------------------------------------------------------------------
if ~userInput
    % Annotate a random set:
    alreadyPicked = randsample(numTimeSeries,numAnnotate);
end

% ------------------------------------------------------------------------------
% Go through and annotate selected points
%-------------------------------------------------------------------------------
fprintf(1,['Annotating time series segments to %u points in the plot, ' ...
                    'displaying %u samples from each...\n'],numAnnotate,maxL);

for j = 1:numAnnotate
    title(sprintf('%u points remaining to annotate',numAnnotate-j+1));

    % Get user to pick a point, then find closest datapoint to their input:
    if userInput % user input
        newPointPicked = false;
        numAttempts = 0;
        % Keep selecting until you get a new point (can't get stuck in infinite
        % loop because maximum annotations is number of datapoints). Still, you
        % get 3 attempts to pick a new point
        while ~newPointPicked && (numAttempts < 3)
            point = ginput(1);
            point_z = (point-xy_mean)./xy_std;
            iPlot = BF_ClosestPoint_ginput(xy_zscore,point_z);
            if ~ismember(iPlot,alreadyPicked)
                alreadyPicked(j) = iPlot;
                newPointPicked = true;
            else
                beep
                numAttempts = numAttempts + 1;
            end
        end
        if numAttempts==3 % maxed out
            alreadyPicked(j) = NaN;
            continue
        end
    else
        % Use a previously-selected point (pre-selected at random)
        iPlot = alreadyPicked(j);
    end

    % (x,y) co-ords of the point to plot:
    plotPoint = xy(iPlot,:);

    % Get the group index of the selected time series:
    theGroupIndex = groupLabelsInteger(iPlot);

    % Crop the time series:
    if ~isempty(maxL)
        timeSeriesSegment = TimeSeries.Data{iPlot}(1:min(maxL,end));
    else
        timeSeriesSegment = [];
    end

    % When only one group, cycle through rainbow colors for each annotation:
    if numGroups==1
        % cycle through rainbow colors sequentially:
        groupColors{1} = rainbowColors{rem(j,length(rainbowColors)-1)+1};
    end

    % Plot a circle around the annotated point:
    if plotCircle
        plot(plotPoint(1),plotPoint(2),'o','MarkerEdgeColor',groupColors{theGroupIndex},...
                            'MarkerFaceColor',brighten(groupColors{theGroupIndex},0.5));
    end

    % Add text annotations:
    switch textAnnotation
    case 'Name'
        % Annotate text with names of datapoints:
        if ismember('Group',TimeSeries.Properties.VariableNames)
            text(plotPoint(1),plotPoint(2)-0.01*pHeight,sprintf('%s-%u',...
                    TimeSeries.Name{iPlot},TimeSeries.Group(iPlot)),...
                    'interpreter','none','FontSize',8,...
                    'color',brighten(groupColors{theGroupIndex},-0.6));
        else
            text(plotPoint(1),plotPoint(2)-0.01*pHeight,TimeSeries.Name{iPlot},...
                    'interpreter','none','FontSize',8,...
                    'color',brighten(groupColors{theGroupIndex},-0.6));
        end
    case 'ID'
        % Annotate text with ts_id:
        text(plotPoint(1),plotPoint(2)-0.01*pHeight,...
                num2str(TimeSeries.ID(iPlot)),...
                    'interpreter','none','FontSize',8,...
                    'color',brighten(groupColors{theGroupIndex},-0.6));
    case 'length'
        text(plotPoint(1),plotPoint(2)-0.01*pHeight,...
                num2str(length(TimeSeries.Data{iPlot})),...
                'interpreter','none','FontSize',8,...
                'color',brighten(groupColors{theGroupIndex},-0.6));
    end

    % Adjust if annotation goes off axis x-limits
    px = plotPoint(1)+[-fdim(1)*pWidth/2,+fdim(1)*pWidth/2];
    if px(1) < pxlim(1), px(1) = pxlim(1); end % can't plot off left side of plot
    if px(2) > pxlim(2), px(1) = pxlim(2)-fdim(1)*pWidth; end % can't plot off right side of plot

    % Adjust if annotation goes above maximum y-limits
    py = plotPoint(2)+[0,fdim(2)*pHeight];
    if py(2) > pylim(2)
        py(1) = pylim(2)-fdim(2)*pHeight;
    end

    % Annotate the time series
    if ~isempty(timeSeriesSegment)
        plot(px(1)+linspace(0,fdim(1)*pWidth,length(timeSeriesSegment)),...
                py(1)+fdim(2)*pHeight*(timeSeriesSegment-min(timeSeriesSegment))/(max(timeSeriesSegment)-min(timeSeriesSegment)),...
                    '-','color',groupColors{theGroupIndex},'LineWidth',theLineWidth);
    end

end

% Clear the title
title('')

%-------------------------------------------------------------------------------
function groupColors = GiveMeGroupColors(annotateParams,numGroups) % Set colors
    if isstruct(annotateParams) && isfield(annotateParams,'cmap')
        if ischar(annotateParams.cmap)
            groupColors = BF_GetColorMap(annotateParams.cmap,numGroups,1);
        else
            groupColors = annotateParams.cmap; % specify the cell itself
        end
    else
        if numGroups < 10
            groupColors = BF_GetColorMap('set1',numGroups,1);
        elseif numGroups <= 12
            groupColors = BF_GetColorMap('set3',numGroups,1);
        elseif numGroups <= 22
            groupColors = [BF_GetColorMap('set1',numGroups,1); ...
                        BF_GetColorMap('set3',numGroups,1)];
        elseif numGroups <= 50
            groupColors = mat2cell(jet(numGroups),ones(numGroups,1));
        else
            error('There aren''t enough colors in the rainbow to plot this many classes!')
        end
    end
    if (numGroups == 1)
        groupColors = {'k'}; % Just use black...
    end
end
%-------------------------------------------------------------------------------

end
