function [x_pks,y_pks,tgl] = FindHelixPeaks(xh,yh,X,Y)

plt = 1;

%% find helices-catheter intersection
[x0,y0,~,~] = intersections(xh,yh,X,Y,0);
if plt
    hold on;
    plot(xh,yh,'-k');
    plot(X,Y,'-k');
    plot(x0,y0,'ob');
end
% x0 = [x0(1:4);37.27;x0(5:end)]; % only for N = 6 and fr = 3169
% y0 = [y0(1:4);0;y0(5:end)];

%% sort [x0,y0] by the order of indices of helices (xh,yh)
% % % n_apx = 4; % number of nearest elements to include (to avoid errors due to "loops")
% % % i0 = nan(size(x0));
% % % ind_arr = nan(length(x0),n_apx);
% % % for ii = 1:length(x0)
% % %     dn = (x0(ii)-xh).^2 + (y0(ii)-yh).^2; % calculate distance from an intersect to the helical wire
% % %     [~,tempb] = sort(dn);
% % %     i0(ii) = tempb(1); % find the closest points to the intersect
% % %     ind = tempb(1:n_apx); % indices of the closest points
% % %     ind_arr(ii,:) = ind; % save the indices
% % %     if plt
% % %         plot(x0(ii),y0(ii),'ob');
% % %     end
% % % end

i0 = nan(size(x0));
ind_arr = nan(length(x0),1);
xhfind = xh; yhfind = yh;
for ii = 1:length(x0)
    dn = (x0(ii)-xhfind).^2 + (y0(ii)-yhfind).^2; % calculate distance from an intersect to the helical wire
    [~,tempb] = sort(dn,'ascend');
    tempb = sort(tempb(1:2));
    b = tempb(1);
    i0(ii) = b;
    xhfind(b) = nan;
    yhfind(b) = nan;
    ind_arr(ii) = b;
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
    mcath = -1/m;           % slope of catheter segment
    if isinf(m)
        m = 1000000000;
    end
    if isinf(mcath)
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
    d = abs(m*xd-yd+(ym-m*xm))/sqrt(m^2+1^2);                   % point-to-line distance, [normal] of catheter segment % https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
    dcath = abs(mcath*xd-yd+(ym-mcath*xm))/sqrt(mcath^2+1^2);   % point-to-line distance, [tangent] to catheter
    tgl_el = dcath < nanmean(dcath);        % exclude points too close to catheter
    xd(tgl_el) = nan; yd(tgl_el) = nan;     % exclude points too close to catheter
    d(tgl_el) = nan;                        % exclude points too close to catheter
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %     % version 1 -- closest to center line
    % %     [~,I] = sort(d);    % sort helix-to-normal distance
    % %     I_arr = I(1:6);     % find 4 points on the helix closest to the normal line
    % %     x_arr = xd(I_arr);  % candidate x
    % %     y_arr = yd(I_arr);  % candidate y
    % %     d_arr = rssq([x_arr-xm;y_arr-ym]); % candidate distance
    % %     [~,idx] = max(d_arr);   % find the candidate furthest from the midpoint
    % %     id = I_arr(idx);        % identify peak index
    
    % version 2 -- furthest to catheter
    dcath(isnan(dcath)) = 0;    % remove nan's in dacth (for sorting purposes)
    % % %     [~,I] = sort(dcath,'descend');  % sort helix-to-normal distance
    % % %     I_arr = I(1:8);     % find 8 points on the helix furthest from the catheter
    % % %     x_arr = xd(I_arr);  % candidate x
    % % %     y_arr = yd(I_arr);  % candidate y
    % % %     d_arr = rssq(range([x_arr;y_arr]'));    % calculate the furthest distance between candidates
    % % %     if d_arr > mean(rssq(diff([x0,y0])'))   % if the furthest distance is greater than the average distance between catheter-helix intersects
    % % %         xy_mean = mean([x_arr;y_arr],2);
    % % %         I_arr(x_arr > xy_mean(1)) = nan;
    % % %         id = nanmax(I_arr);    % choose the first peak
    % % %     else
    % % %         id = nanmax(I_arr);    % choose the first peak
    % % %     end
    [~,id] = nanmax(dcath);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
        %         pause;
        delete([h0,h1,h2]);
    end
end

%% generate toggle array
tgl = (-ones(1,n_pks)).^(1:n_pks);
tgl = tgl*si0;
tgl(tgl<0) = 0;
tgl = logical(tgl);