function f = TS_PlotLowDim(whatData,whatAlgorithm,showDist,annotateParams,cfnParams)
% TS_PlotLowDim   2-dimensional feature-based representation of a time-series dataset
%
% The low-dimensional representation is computed using PCA.
%
%---INPUTS:
% whatData, the hctsa data file (or structure) to use (input to TS_LoadData)
% whatAlgorithm, what dimensionality-reduction algorithm to use ('pca' is default),
%                   also 'tSNE'.
% showDist, whether to also plot marginal class distributions of each PC
% annotateParams, the annotation parameters used when plotting the dataset using
%                 TS_Plot2d. Can also specify an integer; will annotate this
%                 many time series segments to the 2d scatter plot.
% cfnParams, parameters for classification in 2-d space (cf., GiveMeDefaultClassificationParams)
%
%---OUTPUT:
% Figure handle, f
%
%---EXAMPLE USAGE:
% (*) Plot a PCA projection of the normalized data stored in HCTSA_N.mat
% >> TS_PlotLowDim('norm','pca');

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
%% Check Inputs:
% ------------------------------------------------------------------------------
if nargin < 1 || isempty(whatData)
    whatData = 'norm'; % load in normalized data by default, from HCTSA_N.mat
end
if nargin < 2 || isempty(whatAlgorithm)
    whatAlgorithm = 'pca';
end
if nargin < 3 || isempty(showDist)
    showDist = true;
end
if nargin < 4 || isempty(annotateParams)
    % Annotate 6 points by default
    fprintf(1,'Annotating 6 points by default with time series segment and names\n');
    annotateParams = struct('n',6,'textAnnotation','Name','userInput',false);
end
if ~isstruct(annotateParams)
    annotateParams = struct('n',annotateParams);
end

%-------------------------------------------------------------------------------
%% Load the data
%-------------------------------------------------------------------------------
[TS_DataMat,TimeSeries,Operations] = TS_LoadData(whatData);
numFeatures = height(Operations);

% (for classification in the embedding space):
if nargin < 5 || isempty(cfnParams)
    cfnParams = GiveMeDefaultClassificationParams(TimeSeries);
end

% Assign group labels (removing unlabeled data):
[TS_DataMat,TimeSeries] = FilterLabeledTimeSeries(TS_DataMat,TimeSeries);
% Give basic info about the represented classes:
TellMeAboutLabeling(TimeSeries);

% ------------------------------------------------------------------------------
%% Do the dimensionality reduction using Matlab's built-in PCA algorithm
% ------------------------------------------------------------------------------
switch whatAlgorithm
case {'pca','PCA'}
    fprintf(1,'Calculating 2-dimensional principal components of the %u x %u data matrix...\n', ...
                        size(TS_DataMat,1),size(TS_DataMat,2));

    % Use pca to compute the first two principal components:
    % (project data into space of PC scores, Y)
    if ~any(isnan(TS_DataMat))
        [pcCoeff,Y,~,~,percVar] = pca(zscore(TS_DataMat),'NumComponents',2);
    else
        warning(sprintf(['Data matrix contains %.2g%% NaNs. Estimating covariances on remaining data...\n' ...
                    '(Could take some time...)'],100*mean(isnan(TS_DataMat(:)))))
        % Data matrix contains NaNs; try the pairwise rows approximation to the
        % covariance matrix:
        [pcCoeff,Y,~,~,percVar] = pca(BF_NormalizeMatrix(TS_DataMat,'zscore'),...
                                        'Rows','pairwise','NumComponents',2);
        % If this fails (covariance matrix not positive definite), can try the
        % (...,'algorithm','als') option in pca... (or toolbox for probabilistic PCA)
    end
    fprintf(1,'---Done.\n');

    %-------------------------------------------------------------------------------
    % Display the features loading strongly into the two components:
    numTopLoadFeat = min(numFeatures,20); % display this many features loading onto each PC
    LowDimDisplayTopLoadings(numTopLoadFeat,2,pcCoeff,Y,TS_DataMat,Operations);

    % Axis labels for the plot:
    featureLabels = cell(2,1);
    for i = 1:2
        featureLabels{i} = sprintf('PC-%u (%.2f%% var)',i,percVar(i));
    end

case {'tSNE','tsne'}
    numPCAComponents = min(size(TS_DataMat,2),50);
    rng('default') % for reproducibility

    if numPCAComponents < size(TS_DataMat,2)
        fprintf(1,['Computing a two-dimensional t-SNE embedding (using barnes-hut',...
                        ' approximation after %u-dim PC reduction) of the %u x %u data matrix...\n'], ...
                            numPCAComponents,size(TS_DataMat,1),size(TS_DataMat,2));
        Y = tsne(BF_NormalizeMatrix(TS_DataMat,'zscore'),'Algorithm','barneshut',...
                        'Distance','euclidean','NumPCAComponents',numPCAComponents,'NumDimensions',2);

    else
        fprintf(1,['Computing a two-dimensional t-SNE embedding (using barnes-hut',...
                        ' approximation) of the %u x %u data matrix...\n'], ...
                            numPCAComponents,size(TS_DataMat,1),size(TS_DataMat,2));
        Y = tsne(BF_NormalizeMatrix(TS_DataMat,'zscore'),'Algorithm','barneshut',...
                        'Distance','euclidean','NumDimensions',2);
    end
    fprintf(1,'---Done.\n');
    % Axis labels for the plot:
    featureLabels = arrayfun(@(x)sprintf('tSNE-%u',x),1:2,'UniformOutput',false);
otherwise
    error('Unknown dimensionality-reduction algorithm: %s',whatAlgorithm);
end

%-------------------------------------------------------------------------------
% Plot two-dimensional representation of the data using TS_Plot2d:
f = TS_Plot2d(Y(:,1:2),TimeSeries,featureLabels,annotateParams,showDist,cfnParams);

%-------------------------------------------------------------------------------
% Clear output
if nargout==0
    clear('f')
end

end
