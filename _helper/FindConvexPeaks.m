function [x,y] = FindConvexPeaks(BW,n_div,bbox_big,y_min)

% figure;imshow(BW); hold on;

x = [];
y = [];

for vv = 1:n_div % need to adapt it so it can account for multiple divisions
    
    BW_temp = BW;
    
    bbox = bbox_big;
    bbox(4) = (y_min-bbox(2))/n_div;
    bbox(2) = bbox(2) + (vv-1)*bbox(4);
    bbox = floor(bbox);
    
    %     rectangle('position',bbox,'edgecolor','y');
    
    tgl = zeros(size(BW));
    tgl(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3)) = 1;
    BW_temp(~tgl) = 0;
    
    s = regionprops('table',BW_temp,'ConvexHull','ConvexArea','Extrema');
    if ~isempty(s)
        ConvexHull = s.ConvexHull;
        ConvexArea = s.ConvexArea;
        [~,ind] = max(ConvexArea);
        ConvexHull_final = ConvexHull{ind};
        
        xi = ConvexHull_final(:,1); yi = ConvexHull_final(:,2);
    else
        xi = []; yi = [];
    end
    
    % remove horizontal boundaries
    tgl = abs(diff(yi)) > 0;
    tgl = [true;tgl];
    xi = xi(tgl); yi = yi(tgl);
    
    % remove overlaps
    tgl = abs(diff(yi)) > 0.5;
    tgl = [true;tgl];
    xi = xi(tgl); yi = yi(tgl);
    
    % remove the top two points and bottom right point within each Qhull
    temp = sortrows([xi,yi],2);
    xi = temp(:,1); yi = temp(:,2);
    xi([1,2,end]) = []; yi([1,2,end]) = [];
    
    %     plot(xi,yi,'o','linewidth',2);
    
    x = [x;xi];
    y = [y;yi];
end