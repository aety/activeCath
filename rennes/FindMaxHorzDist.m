function [xx,yy] = FindMaxHorzDist(ref_range,I)

n = diff(ref_range(1:2))+1;
d_max = nan(1,n); y_max = d_max; y_min = d_max;

[a,b] = find(I==1);
I = [a,b];
tt_arr = unique(I(:,1));

for tt = 1:length(tt_arr)
    t = tt_arr(tt);
    II = I(I(:,1)==t,2);
    d_max(t) = max(II) - min(II);    
    y_max(t) = max(II);
    y_min(t) = min(II);
end

ind_max = find(d_max>15,1,'last');

xx1 = ind_max;
yy1 = y_min(tt_arr(ind_max));
yy2 = y_max(tt_arr(ind_max));
xx = [xx1,xx1];
yy = [yy1,yy2];

