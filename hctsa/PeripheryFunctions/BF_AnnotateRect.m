function BF_AnnotateRect(featureVector,groupLabels,cfnParams,colors,ax,underOrLeft)
% BF_AnnotateRect Annotates rectangles under distributions for group classification
%
%---INPUTS:
% whatCfn, the classification method to use
% featureVector, the values given to each observation
% groupLabels, the class labels assigned to each observation
% numClasses, the number of classes (usually the max of the groupLabels)
% colors, a custom cell of colors for plotting
% ax, the handle for the axes to annotate
% underOrLeft, where to annotate (bottom, or to the left of the plot)

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
% This function is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program. If not, see <http://www.gnu.org/licenses/>.
% ------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Check Inputs:
%-------------------------------------------------------------------------------
if nargin < 4
    colors = BF_GetColorMap('dark2',numClasses,1);
end
if nargin < 5
    ax = gca;
end
if nargin < 6
    underOrLeft = 'under'; % under the plot (from 0) by default
end

% How many increments across the axis to determine classification labels:
numIncrements = 100;

%--------------------------------------------------------------------
% Learn a basic classification model from the 1-d feature vector:
try
    [~,Mdl] = GiveMeCfn(featureVector,groupLabels,[],[],cfnParams,false);
catch emsg
    warning('Unable to fit classification model')
    return
end

%-------------------------------------------------------------------------------
switch underOrLeft
case 'under'
    dataPlotted = ax.XLim;
case 'left'
    dataPlotted = ax.YLim;
otherwise
    error('Unknown setting ''%s'', should be ''under'' or ''left''',underOrLeft);
end
predRange = linspace(dataPlotted(1),dataPlotted(2),numIncrements)'; % numIncrements-grid through x
predLabels = predict(Mdl,predRange);

%-------------------------------------------------------------------------------
% Annotate rectangles under the distribution reflecting the predictive model:
xPlotted = ax.XLim;
yPlotted = ax.YLim;
switch underOrLeft
case 'under'
    rectHeight = 0.1*diff(yPlotted);
case 'left'
    rectHeight = 0.05*diff(xPlotted);
end

ind = 1;
while ind < numIncrements
    rectLength = find(predLabels(ind+1:end)~=predLabels(ind),1,'first');
    if isempty(rectLength)
        rectLength = length(predLabels)-ind;
    end
    switch underOrLeft
    case 'under'
        rectangle('Position',[predRange(ind),-rectHeight*1.1,predRange(ind+rectLength)-predRange(ind),rectHeight],...
                                'FaceColor',colors{predLabels(ind)});
    case 'left'
        rectangle('Position',[-rectHeight*1.1,predRange(ind),rectHeight,predRange(ind+rectLength)-predRange(ind)],...
                                'FaceColor',colors{predLabels(ind)});
    end
    ind = ind+rectLength;
end

switch underOrLeft
case 'under'
    ax.YLim(1) = -rectHeight*1.1;
    ax.XLim = xPlotted;
    ax.YLim(2) = yPlotted(2);
case 'left'
    ax.XLim = [-rectHeight*1.1,xPlotted(2)];
end

end
