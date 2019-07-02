function [a_base,b_base] = FindLowestHelix(ref_range,I,d)

n = diff(ref_range(1:2))+1;                     % all possible vertical pixels
d_max = nan(1,n); y_max = d_max; y_min = d_max; % preallocate

[a,b] = find(I==1);         % identify "on" pixel labels
M = [a,b];                  % merge arrays for sorting
tt_arr = unique(M(:,1));    % array of unique vertical pixels

for tt = 1:length(tt_arr)
    t = tt_arr(tt);             % current pixel 
    MM = M(M(:,1)==t,2);        % find horizontal locations of pixels at this vertical location (height)
    d_max(t) = max(MM)-min(MM); % maximum horizontal distance between pixels
    y_max(t) = max(MM);         % maximum (furthest right) horizontal pixel at this height
    y_min(t) = min(MM);         % minimum (furthest right) horizontal pixel at this height
end

ind = find(d_max > d,1,'last'); % find the lowest pair of pixels (horizontally aligned) that are at least "d" pixels apart

a_base = [ind,ind];                                 % x-coordinate of the lowest pair of pixels
b_base = [y_min(tt_arr(ind)),y_max(tt_arr(ind))];   % y-coordinate of the lowest pair of pixels

