function thisDir = plotTraject(Y)
%description
%plots trajectory in 3D tSNE plots

%input:
%Y=data matrix, each column is one axis

%output: 
%plotted trajectory in the tSNE 3D plot for visualisation
%%
rMag = 0.5;

% Length of vector
lenTime = length(Y);

%index out each column
vX = Y(:,1);
vY = Y(:,2);
vZ = Y(:,3);

% Indices of tails of arrows
vSelect0 = 1:(lenTime-1);
% Indices of tails of arrows
vSelect1 = vSelect0 + 1;

% X coordinates of tails of arrows
vXQ0 = vX(vSelect0, 1);
% Y coordinates of tails of arrows
vYQ0 = vY(vSelect0, 1);
% Z coordinates of tails of arrows
vZQ0 = vZ(vSelect0, 1);


% X coordinates of heads of arrows
vXQ1 = vX(vSelect1, 1);
% Y coordinates of heads of arrows
vYQ1 = vY(vSelect1, 1);
% Z coordinates of heads of arrows
vZQ1 = vZ(vSelect1, 1);


% vector difference between heads & tails
vPx = (vXQ1 - vXQ0);
vPy = (vYQ1 - vYQ0);
vPz = (vZQ1 - vZQ0);


% add arrows 
thisDir = quiver3(vXQ0,vYQ0,vZQ0, vPx, vPy,vPz,0,'ShowArrowHead','on',...
            'MaxHeadSize',0.001); 
grid on; 
axis equal;
set(get(get(thisDir,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');


end