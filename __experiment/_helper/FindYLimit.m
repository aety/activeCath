function [x,y] = FindYLimit(H,A_thres,pct_sch)
plt = 0;

I_str = imadjust(H);
I = imbinarize(I_str); I = imcomplement(I);

temp = round((1-pct_sch)*size(I,1));
I(1:temp,:) = 0;

s = regionprops('table',I,'Centroid','BoundingBox','Area');
s.Area(s.Area < A_thres) = nan;
[~,b] = sort(s.Area);
b = b(1:2);
BoundingBox = s.BoundingBox(b,:);
y = mean(BoundingBox(:,2));

if plt
    imshow(I); hold on;
    for bb = 1:2
        rectangle('position',BoundingBox(bb,:),'edgecolor','b','linewidth',2);
    end
    plot([0,550],y*ones(1,2),'color','y','linewidth',2);    
end

x = mean(BoundingBox(:,1));