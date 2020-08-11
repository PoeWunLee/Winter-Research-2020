function [d, nfnn] = MS_unfolding(y,th,de,tau)
% Estimate the minimum unfolding dimension by calculating when the
% proportion of false nearest neighbours if first below th.
%
% The number of false nearest neighbours are calculated for the
% time series y embedded in dimension de with lag tau.
%
% For each pair of values (de,tau) the data y is embeded and the
% nearest neighbour to each point (excluding the immediate
% neighbourhood of n points) is determined. If the ratio of the
% distance of the next points and these points is greater
%
%-------------------------------------------------------------------------------
% Michael Small
% michael.small@uwa.edu.au, http://school.maths.uwa.edu.au/~small/
% 3/3/2005
% For further details, please see M. Small. Applied Nonlinear Time Series
% Analysis: Applications in Physics, Physiology and Finance. Nonlinear Science
% Series A, vol. 52. World Scientific, 2005. (ISBN 981-256-117-X) and the
% references therein.
% (Minor changes by Ben Fulcher, 2010)
%-------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Check inputs and set defaults:
% ------------------------------------------------------------------------------
if nargin < 2 || isempty(th)
  th = 0.01;
end
if nargin < 3 || isempty(de)
  de = (1:10);
%   disp(['de = ',int2str(de(1)),':',int2str(de(end))]);
end
if nargin < 4 || isempty(tau)
    tau = 1;
end

% Other options for tau
if strcmp(tau,'ac')
    % First zero-crossing of autocorrelation function
    tau = CO_FirstCrossing(y,'ac',0,'discrete');
elseif strcmp(tau,'mi')
    % First minimum of automutual information function
    tau = CO_FirstMin(y,'mi');
end
if isnan(tau)
    error('Time series cannot be embedded (too short?)');
end
%-------------------------------------------------------------------------------

dsp = 5; % separation cutoff
y = y(:);

n = 2*tau; % exclude nearpoints

nfnn = [];
localMin = 0; % Ben Fulcher, 2015-03-20 fixed to locamin -> localMin

for d = de

    % Embed the data
    X = MS_embed(y,d,tau); % changed from embed -> MS_embed ++BF
    [d,nx] = size(X);

    % find the nearest neighbours of each point
    ind = MS_nearest(X(:,1:(nx-1)),tau); % whooh hooo!

    % Distance between each point and its nearest neighbour
    d0 = MS_rms(X(:,(1:(nx-1)))'-X(:,ind)');
    %... and after one time step
    d1 = MS_rms(X(:,2:nx)'-X(:,ind+1)');

    % Exclude any coincident points
    d1(d0 == 0) = [];
    d0(d0 == 0) = [];

    % Calculate the proportion fnn
    prop = sum((d1./d0)>dsp)/length(d0);

%   disp(['de=' int2str(d) ', n(fnn)=' num2str(prop*100) '%']);

    % Is data sufficiently unfolded?
    if (prop < th)
        nfnn = prop;
        return
    end

    % Or maybe a local minimum
    if (length(nfnn) > 1)
        if (min(prop,nfnn(end)) > nfnn(end-1)),
          localMin = 1;
          localMini = length(nfnn)-1;
        end
    end

    nfnn = [nfnn, prop];
end


if (localMin)
    % we didn't go subthreshold, but we did have a local min.
    nfnn = nfnn(localMini);
    d = de(localMini);% changed from i->localMini ++BF
else
    % otherwise, just do the best we can
    [nfnn, i] = min(nfnn);
    d = de(i);
end

end
