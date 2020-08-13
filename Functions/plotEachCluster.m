function plotEachCluster(group,Y,clusNum)

%description
%periphery function called by clusterWith3DTraject.m to scatter plot each
%epoch feature on low dimensional space (3D tSNE and PCA)

%input
%group = cluster labels for each epoch, array
%Y = data to be plotted on 3D, table
%clusNum = number of clusters, int

%output
%plotted scatter on tSNE and PCA 3D according to each group


%plot groups one by one
for i=1:clusNum
    
    %get data from current group
    thisY = Y(i==group,:);
    
    %plot scatter 
    scatter3(thisY(:,1),thisY(:,2),thisY(:,3),'.');
    hold on;
    
end

legend(strsplit(num2str(1:clusNum)));

end