function pks = FindConnComp(I_in,x,y,y_min,thrs_dev)

sharp_r = 0.5; % sharpening radius
sharp_a = 50;  % sharpening amount
thrs_big = 50; % threshold for removing oversized connected components

I = I_in;

% sharpen
I = imsharpen(I,'radius',sharp_r,'amount',sharp_a); % (default radius = 1; default amount = 0.8)

% binarize
I = imbinarize(I,0.9);

% remove noise
I = imcomplement(I);
I = bwareaopen(I,200);
I = imcomplement(I);

%% find peaks
CC = bwconncomp(I,4); % this searches for the 4-connected components, which regionprops misses
Area = nan(1,CC.NumObjects);
for cc = 1:CC.NumObjects
    Area(cc) = length(CC.PixelIdxList{cc});
end
ind_exc = find(Area > thrs_big); % remove boxes much bigger than an "envelope" size
nobj = CC.NumObjects - length(ind_exc);
pixidlist = CC.PixelIdxList; pixidlist(ind_exc) = [];

pks = nan(nobj,2);
d = nan(nobj,1);

% find furthest point
for cc = 1:nobj
    temp = pixidlist{cc};
    [temp1,temp2] = ind2sub(CC.ImageSize,temp);
    Idx = knnsearch([x;y]',[temp1,temp2]);
    Y = rssq([temp1,temp2]' - [x(Idx);y(Idx)]);
    [~,ind] = max(Y);
    pks(cc,:) = [temp1(ind),temp2(ind)];
    d(cc) = Y(ind);
end

tgl_dev = d > thrs_dev; % exclude those deviating too much from the catheter
pks(tgl_dev,:) = [];

tgl_exc = pks(:,1) > y_min - thrs_dev; % exclude those below y limit
pks(tgl_exc,:) = [];

%% remove points that are too close
d_temp = nan(1,size(pks,1));
idx = d_temp;
for nn = 1:size(pks,1)
    pkss = pks; pkss(nn) = nan; % make a second array and block the element of this iteration 
    i_temp = knnsearch(pkss,pks(nn,:)); % look for the nearest neighbor
    d_temp(nn) = rssq(pks(i_temp,:) - pks(nn,:)); % distance from nearest neighbor
    idx(nn) = i_temp; % index of the nearst neighbor
end
ind_ovl = find(d_temp < (mean(d_temp)-1*std(d_temp))); % look for minimal distances that are more than 2 STD below the mean 

temp = [ind_ovl; idx(ind_ovl)]; % prepare to eliminate overlaps (only one of them)
dtemp = d(temp);                % distances of these close points from the catheter
ind_arr = unique(temp(dtemp==max(dtemp)));  % eliminte one of each pair of peaks (the one that is nearer to the catheter)
pks(ind_arr,:) = [];                        % eliminte one of each pair of peaks (the one that is nearer to the catheter)