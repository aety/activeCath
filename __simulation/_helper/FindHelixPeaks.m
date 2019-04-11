function [x_pks,y_pks] = FindHelixPeaks(xh,yh,X,Y)

%% find helices-catheter intersection
[x0,y0,~,~] = intersections(xh,yh,X,Y,0);
temp = uniquetol([x0,y0],'ByRows',true);
x0 = temp(:,1); y0 = temp(:,2);

%% find peaks
x_pks = nan(1,length(x0)-1);
y_pks = x_pks;

for ii = 1:length(x0)-1
    
    xx = x0(ii:ii+1);       % two consecutive intersects
    yy = y0(ii:ii+1);       % two consecutive intersects
    xm = mean(xx);          % midpoint
    ym = mean(yy);          % midpoint
    m = -diff(xx)/diff(yy); % slope of normal
    
    d = abs(m*xh-yh+(ym-m*xm))/sqrt(m^2+1^2); % point-to-line distance (normal of connection line)
    [~,I] = sort(d);    % sort helix-to-normal distance
    I_arr = I(1:4);     % find 4 points the helix closest to the normal line
    x_arr = xh(I_arr);  % candidate x
    y_arr = yh(I_arr);  % candidate y
    d_arr = rssq([x_arr-xm;y_arr-ym]); % candidate distance
    [~,idx] = max(d_arr);   % find the candidate furthest from the midpoint
    id = I_arr(idx);        % identify peak index
    
    x_pks(ii) = xh(id); % store
    y_pks(ii) = yh(id); % store
end
