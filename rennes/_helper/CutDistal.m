function I_cut = CutDistal(I_ctol,cath_len_pc,x,y,p,S,mu)

% find image dimensions
ht = size(I_ctol,1);
wd = size(I_ctol,2);

% interpolate the polynomial catheter shape
xx = linspace(x(1),x(end),1000);
yy = interp1(x,y,xx);

% rearrange the array
x = fliplr(xx); % flip
y = fliplr(yy); % flip
x1 = x - x(1);  % offset
y1 = y - y(1);  % offset
dis = rssq([x1;y1]);            % calculate distance from base

cath_len = cath_len_pc*max(dis);

ind = find(dis > cath_len,1);   % find the critical length
y1 = y1 + y(1); x1 = x1 + x(1); % translate catheter back to initial position

% find slope at the critical point
k = polyder(p);             % find derivative coefficient
yder = polyval(k,x,S,mu);   % find derivative
slope = -yder(ind);            % find critical point slope

% calculate intercept between left edge and critical slope extension
ye = wd;        % end point
yi = y1(ind);   % middle point
y0 = 0;         % start point
yy1 = ye-yi;    % x-distance 1 
yy2 = y0-yi;    % x-distance 2
dy = [yy1,yy2]; % y-distances
dx = dy/slope;     % x-distances
ln_x = x1(ind)+dx; % translate to critical point

% evaluate all pixels in the image
px_x = repmat(1:wd,ht,1);       % x pixels
px_y = repmat((1:ht)',1,wd);    % y pixels

a = 1/slope;       % slope function coefficient 1 (y = a*x + b)
b = ln_x(2);    % slope function coefficient 2 (y = a*x + b)
fy = polyval([a,b],px_x);   % evaluate
tgl = (px_y - fy) < 0;      % decide if each point is above the slope

I_cut = I_ctol; I_cut(tgl) = 1;