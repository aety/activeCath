function [I_ctol,x,y,p,S,mu,bbox_big] = IdentifyCatheter(I_str,y_min,pf_npt,dbgflag)

sharp_r = 2; % sharpening radius
sharp_a = 10;  % sharpening amount 
thrs_small = 100; % (pixels)^2 threshold for removing small objects (during arbitrary stage; helps remove tip positioning boxes)
pf_n = 3; % polyfit-- the order of equation(to find a curve best describing the catheter shape)
pf_rpt = 10; % polyfit-- the number of times to eliminate outliers (to eliminate noise)
pf_exc = 0.1; % polyfit-- the percentage of catheter distal (vertical) distance to exclude before polyfit

%% sharpening (I_shp)
I_shp = imsharpen(I_str,'radius',sharp_r,'amount',sharp_a); % (default radius = 1; default amount = 0.8)

if dbgflag
    figure;
    subplot(1,4,1);
    imshow(I_shp);
    title('sharpen');
end

%% distance transform (I_dtr)
I_dtr = bwdist(I_shp);

if dbgflag
    subplot(1,4,2);
    imshow(I_dtr);
    title('distance tranform');
end

%% remove smaller objects (I_rsm)
I_rsm = bwareaopen(I_dtr,thrs_small);

if dbgflag
    subplot(1,4,3);
    imshow(I_rsm);
    title('remove small objects');
end

%% identify catheter (BoundingBox)
s = regionprops('table',I_rsm,'Area','BoundingBox','PixelIdxList','ConvexHull');
BoundingBox = s.BoundingBox;
[~,ind] = max(BoundingBox(:,4)); % find the tallest BoundingBox
bbox_big = BoundingBox(ind,:);
bbox_big = floor(bbox_big); % round down to the nearest pixel integer

if dbgflag
    subplot(1,4,4);
    imshow(I_rsm);
    hold on;
    rectangle('Position',bbox_big,'edgecolor','y','linewidth',2);
    title('tallest bounding box');
    
end

%% retain bounding box of catheter only and binarize (I_shp_ctol)
tgl = zeros(size(I_dtr));
tgl(bbox_big(2):bbox_big(2)+bbox_big(4),bbox_big(1):bbox_big(1)+bbox_big(3)) = 1;

level = graythresh(I_shp(bbox_big(2):bbox_big(2)+bbox_big(4),bbox_big(1):bbox_big(1)+bbox_big(3)));
I_ctol = imbinarize(I_shp,level);
I_ctol(~tgl) = 1;

if dbgflag    
    imshow(I_ctol,[]); hold on;
    title('exclude outside (from sharpen) and binarize');    
end

%% identify catheter main shape
I_ctol_inv = imcomplement(I_ctol);
I_ctol_inv(y_min:end,:) = 0;

s = regionprops('table',I_ctol_inv,'BoundingBox');
BoundingBox = s.BoundingBox;
[~,ind] = max(BoundingBox(:,4)); % find the tallest BoundingBox
BoundingBox = BoundingBox(ind,:);
bbox_big = floor(BoundingBox); % round down to the nearest pixel integer

[fa,fb] = find(I_ctol_inv==1);
[p,S,mu] = PolyfitCatheter(fa,fb,pf_n,pf_rpt,pf_exc); % find the best polynomial fit describing the catheter shape
x = linspace(min(fa),max(fa),pf_npt);
[y,~] = polyval(p,x,S,mu);

if dbgflag
    figure;
    imshow(I_ctol_inv,[]); hold on;
    rectangle('position',BoundingBox,'edgecolor','y','linewidth',2);
end