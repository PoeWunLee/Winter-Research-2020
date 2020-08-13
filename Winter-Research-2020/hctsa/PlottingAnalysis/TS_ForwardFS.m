function [ifeat, testStat, trainErr, testErr, testClass] = TS_ForwardFS(whatData,iTrain,criterion,cvFolds,numFeatSelect,annotateParams)
% TS_ForwardFS  Greedy forward feature selection
%
% --NOT FULLY FUNCTIONAL CURRENTLY--
%
% Uses the sequentialfs function from Matlab's Statistics Toolbox.
% After selecting the features (using specified training indices), then
% applies the learned classification rule to the training and test sets to get
% training and test classification errors.
%
% Typical usage uses 'fast_linear' for the criterion (linear classification rates),
% or 'diaglinear' when there are highly correlated features in the data matrix.
%
% NOTE: This function requires a training portion to be specified. If there
%       is no obvious training portion of your data, this should be specified
%       at random (e.g., stratified to represent groups in your data) and
%       repeated to get an estimate of the out-of-sample classification that is
%       not dependent on the particular data partition.
%
%---INPUTS:
% whatData: the data to load in (cf. TS_LoadData)
% iTrain: indices of data to train on
% criterion: what criterion on which to evaluate the quality of a feature set
% cvFolds: the number of cross-validation folds to use in the feature selection
%           process
% numFeatSelect: the total number of features to select
% annotateParams: annotation parameters for the 2-d space
%
%---OUTPUTS:
% ifeat: indices of features selected.
% testStat: test statistics for all operations.
% trainErr: training errors for selected features.
% testErr: test errors for selected features.
% testClass: classification of the test data.

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
%% Check inputs:
% ------------------------------------------------------------------------------
if nargin < 1 || isempty(whatData)
    whatData = 'norm';
end

if nargin < 2
    iTrain = [];
end

if nargin < 3 || isempty(criterion)
    criterion = 'fast_linear';
    fprintf(1,'Default test statistic: Using fast, in-sample linear classification rate\n');
end

if nargin < 4 || isempty(cvFolds)
    cvFolds = 5;
    fprintf(1,'Default: 5-fold cross-validation\n');
end

if nargin < 5 || isempty(numFeatSelect)
    numFeatSelect = 2; % Stop after two features are selected
end

if nargin < 6
    annotateParams = struct('n',6,'textAnnotation','Name');
end

%-------------------------------------------------------------------------------
%% Load the data
%-------------------------------------------------------------------------------
[TS_DataMat,TimeSeries,Operations,whatDataFile] = TS_LoadData(whatData);

% Retrieve group names also:
classLabels = categories(TimeSeries.Group);
numClasses = length(classLabels);

% ------------------------------------------------------------------------------
%% Set up the classification function
% ------------------------------------------------------------------------------
% We get (*) Classify_fn (takes test labels as input): gives the mean classification rate across partitions
classNumbers = arrayfun(@(x)sum(TimeSeries.Group==x),1:numClasses);
isBalanced = all(classNumbers==classNumbers(1));
if isBalanced
    whatLoss = 'sumLoss';
    reWeight = 0;
else
    whatLoss = 'balancedLoss';
    reWeight = 1;
    fprintf(1,'Unbalanced classes: using a balanced accuracy measure to select features (& using reweighting)...\n');
end

% sequentialfs not compatible with nested function handles...? :/
classify_fn = GiveMeCfn(criterion,numClasses,whatLoss,reWeight);

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
%% Do the feature selection
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
FS_timer = tic;
fprintf(1,['Performing greedy forward feature selection using ''%s''...\n'],criterion);

opts = statset('display','iter');
% classify_fn = @(XTrain,yTrain,XTest,yTest) 1 - GiveMeCfn(criterion,XTrain,yTrain,XTest,yTest,numClasses);
[fs,history] = sequentialfs(classify_fn,TS_DataMat,TimeSeries.Group,...
                    'cv',cvFolds,'options',opts,'nfeatures',numFeatSelect);
fprintf(1,'Selected %u features\n',sum(fs));

% Finished selecting features!
fprintf(1,'Feature selection to %u features completed in %s.\n',...
            numFeatSelect,BF_TheTime(toc(FS_timer)))
clear('FS_timer');

%-------------------------------------------------------------------------------
% Plot in a 2-D space
%-------------------------------------------------------------------------------
% Set feature labels:
featureLabels = cell(2,1);
ifeat = find(history.In(2,:));
for i = 1:2
    featureLabels{i} = sprintf('%s (%.2f%%)',Operations.Name{ifeat(i)},100-history.Crit(i)*100);
end

if sum(fs) > 1
    TS_Plot2d(TS_DataMat(:,ifeat),TimeSeries,featureLabels,annotateParams);
end

end
