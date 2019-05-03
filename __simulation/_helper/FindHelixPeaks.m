function [x_pks,y_pks,tgl] = FindHelixPeaks(xh,yh,X,Y)

plt = 0;

%% find helices-catheter intersection
[x0,y0,~,~] = intersections(xh,yh,X,Y,0);
if plt
    hold on;
    plot(xh,yh,'-k');
    plot(X,Y,'-k');
    plot(x0,y0,'ob');
end

%% sort [x0,y0] by the order of indices of helices (xh,yh)
i0 = nan(size(x0));
xhfind = xh; yhfind = yh;
for ii = 1:length(x0)
    dn = (x0(ii)-xhfind).^2 + (y0(ii)-yhfind).^2; % calculate distance from an intersect to the helical wire
    [~,btemp] = sort(dn,'ascend');
    b = btemp(1);
    i0(ii) = b;
    if b > 1
        xhfind(b-1:b+1) = nan;
        yhfind(b-1:b+1) = nan;
    end
end

temp = [i0,x0,y0]; % sort all intersects based on helical indices
temp = sortrows(temp,1,'ascend'); i0 = temp(:,1); x0 = temp(:,2); y0 = temp(:,3);

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
    mcath = -1/m;           % slope of catheter segment
    if isinf(m)
        m = 1000000000;
    end
    if isinf(mcath)
        m = 1000000000;
    end
    
    % find the relevant segment on the helical wire
    xd = xh(i0(ii):i0(ii+1)); yd = yh(i0(ii):i0(ii+1));
    
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
    d = abs(m*xd-yd+(ym-m*xm))/sqrt(m^2+1^2);                   % point-to-line distance, [normal] of catheter segment % https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
    dcath = abs(mcath*xd-yd+(ym-mcath*xm))/sqrt(mcath^2+1^2);   % point-to-line distance, [tangent] to catheter
    tgl_el = dcath < nanmean(dcath);        % exclude points too close to catheter
    xd(tgl_el) = nan; yd(tgl_el) = nan;     % exclude points too close to catheter
    d(tgl_el) = nan;                        % exclude points too close to catheter
    
    dcath(isnan(dcath)) = 0;    % remove nan's in dacth (for sorting purposes)
    [~,id] = nanmax(dcath);
        
    % store peaks
    x_pks(ii) = xd(id); % store
    y_pks(ii) = yd(id); % store
    if ii==1
        si = sign(sign_arr(id)); % save sign of the first peak
        si0 = si;
    end
    
    if plt
        h0 = plot(xx,yy,'or','linewidth',2);
        h1 = plot(xd,yd,'*g');
        h2 = plot(xm,ym,'+m');
        plot(xd(id),yd(id),'dm','linewidth',2);
        text(xd(id),yd(id),num2str(ii));
        title(ii);
        axis equal;
        pause;
        delete([h0,h1,h2]);
    end
end

%% generate toggle array
tgl = (-ones(1,n_pks)).^(1:n_pks);
tgl = tgl*si0;
tgl(tgl<0) = 0;
tgl = logical(tgl);

%% re-sort by x
temp = [x_pks',y_pks',tgl'];
temp = sortrows(temp);
x_pks = temp(:,1)'; y_pks = temp(:,2)'; tgl = logical(temp(:,3))';