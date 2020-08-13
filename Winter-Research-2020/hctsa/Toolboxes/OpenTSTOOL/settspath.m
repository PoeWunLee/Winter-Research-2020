function settspath(TSTOOLpath)
% Set environment for using TSTOOL
%
% Either use 'settspath(TSTOOLpath)'
% or just 'settspath' when in the OpenTSTool-Directory

if nargin == 0
    if which('units.mat')
        [TSTOOLpath,~,~] = fileparts(which('units.mat'));
    elseif exist(fullfile(pwd,'tstoolbox','units.mat')) == 2
        TSTOOLpath = fullfile(pwd,'tstoolbox');
    else
        error('Cannot find TSTOOL! Please specify TSTOOL''s path by calling settspath(TSTOOLpath).');
    end
else
    if(~(exist(fullfile(TSTOOLpath,'units.mat')) == 2))
        if(exist(fullfile(TSTOOLpath,'tstoolbox','units.mat')))
            TSTOOLpath = fullfile(TSTOOLpath,'tstoolbox');
        else
            error('Cannot find TSTOOL under given path');
        end
    end
end

addpath(fileparts(TSTOOLpath));
addpath(TSTOOLpath);
addpath(fullfile(TSTOOLpath, 'demos'));
addpath(fullfile(TSTOOLpath, 'gui'));
addpath(fullfile(TSTOOLpath, 'utils'));
addpath(fullfile(TSTOOLpath, 'mex'));

% If mex compilation hasn't been done, then this won't exist:
if exist(fullfile(TSTOOLpath, 'mex', mexext),'file')
    addpath(fullfile(TSTOOLpath, 'mex', mexext));
end

end
