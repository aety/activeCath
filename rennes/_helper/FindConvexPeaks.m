function [x,y] = FindConvexPeaks(BW,n_div,bbox_big,y_min)

% figure;imshow(BW); hold on;

for vv = 1:n_div
    
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
    ConvexHull = s.ConvexHull;
    ConvexArea = s.ConvexArea;
    [~,ind] = max(ConvexArea);
    ConvexHull = ConvexHull{ind};
    
    x = ConvexHull(:,1); y = ConvexHull(:,2);
    
%     plot(x,y,'.','color','m','markersize',10);    
    
end