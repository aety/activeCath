function [x_pks,y_pks,tgl] = FindHelixPeaks(xh,yh,X,Y)

plt = 1;

%% find helices-catheter intersection
[x0,y0,~,~] = intersections(xh,yh,X,Y,0);
if plt
    hold on;
    plot(xh,yh,'k');
    plot(X,Y,'k');
end

%% sort [x0,y0] by the order of indices of helices (xh,yh)
n_apx = 4; % number of nearest elements to include (to avoid errors due to "loops")
i0 = nan(size(x0));
ind_arr = nan(length(x0),n_apx);
for ii = 1:length(x0)
    dn = (x0(ii)-xh).^2 + (y0(ii)-yh).^2; % calculate distance from an intersect to the helical wire
    [~,tempb] = sort(dn); i0(ii) = tempb(1); % find the closest points to the intersect
    ind = tempb(1:n_apx); % indices of the closest points
    ind_arr(ii,:) = ind; % save the indices
    if plt
        plot(x0(ii),y0(ii),'ob');
    end
end
temp = [i0,x0,y0]; % sort all intersects based on helical indices
temp = sortrows(temp,1,'ascend'); x0 = temp(:,2); y0 = temp(:,3);

%% find peaks
n_pks = length(x0)-1;
x_pks = nan(1,n_pks);
y_pks = x_pks;
si = 1; % initialize sign

for ii = 1:n_pks
    
    % calculate local slope
    xx = x0(ii:ii+1);       % two consecutive intersects
    yy = y0(ii:ii+1);       % two consecutive intersects
    xm = mean(xx);          % midpoint
    ym = mean(yy);          % midpoint
    m = -diff(xx)/diff(yy); % slope of normal
    if isinf(m)
        m = 1000000000;
    end
    
    % find the relevant segment on the helical wire
    id = [ind_arr(ii,:),ind_arr(ii+1,:)]; % include the widest range of possible helices
    xd = xh(min(id):max(id)); yd = yh(min(id):max(id));
    
    % contrain to only one side of the catheter (alternating)
    temp = [xx,yy]; temp = sortrows(temp); xx = temp(:,1); yy = temp(:,2); % sort [xx,yy] so they are in the order of x
    dot_arr = (xd - xx(1))*(yy(2) - yy(1)) - (yd - yy(1))*(xx(2) - xx(1)); % dot product
    sign_arr = sign(dot_arr); % retain only the signs of the dot products
    if ii > 1
        si = si*(-1); % flip signs
        xd(sign_arr~=si) = nan; % exclude points on the wrong side
        yd(sign_arr~=si) = nan; % exclude points on the wrong side
    end
    
    % find the point furthest from the catheter from the points nearest to the normal of the tangent at midpoint
    d = abs(m*xd-yd+(ym-m*xm))/sqrt(m^2+1^2); % point-to-line distance (normal of connection line) % https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
    [~,I] = sort(d);    % sort helix-to-normal distance
    I_arr = I(1:6);     % find 4 points the helix closest to the normal line
    x_arr = xd(I_arr);  % candidate x
    y_arr = yd(I_arr);  % candidate y
    d_arr = rssq([x_arr-xm;y_arr-ym]); % candidate distance
    [~,idx] = max(d_arr);   % find the candidate furthest from the midpoint
    id = I_arr(idx);        % identify peak index
    
    % store peaks
    x_pks(ii) = xd(id); % store
    y_pks(ii) = yd(id); % store
    if ii==1
        si = sign(sign_arr(id)); % save sign of the first peak
        si0 = si;
    end
    
    if plt
        plot(xd,yd,'*g');
        plot(xm,ym,'+m');
        plot(xd(id),yd(id),'dm','linewidth',2);
        title(ii);
        axis equal;
        pause;
    end
end

%% generate toggle array
tgl = (-ones(1,n_pks)).^(1:n_pks);
tgl = tgl*si0;
tgl(tgl<0) = 0;
tgl = logical(tgl);