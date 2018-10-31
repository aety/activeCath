function [x_pks_arr,y_pks_arr] = func_find_apex_rot(xh,yh,X,Y,plt_flg)
% This function looks for the apexes of the sinusoidal helices wrapped
% around around a catheter in the X-Y projection view
% Anne Yang 2018.09.17
% --------------------------------
% Input variables--
%   xh: helix x-coordinate
%   yh: helix y-coordinate
%   X: catheter x-coordinate
%   Y: catheter y-coordinate
%   plt_flg: toggle for plotting
%
% Output variables--
%   x_pks_arr: x-values of peaks
%   y_pks_arr: y-values of peaks

%% find intersections between two curves
[x0,y0,~,~] = intersections(xh,yh,X,Y,0);
temp = uniquetol([x0,y0],'ByRows',true);
x0 = temp(:,1); y0 = temp(:,2);

%% find intersections between the catheter and the helix
ind_arr = nan(1,length(x0));  % preallocate

for ii = 1:length(x0)
    temp = sqrt((xh-x0(ii)).^2 + (yh-y0(ii)).^2);
    ind_arr(ii) = find(temp==min(temp)); % find indices of intersections along the curve
end
temp = [ind_arr',x0,y0];
temp = sortrows(temp);
ind_arr = temp(:,1); x0 = temp(:,2); y0 = temp(:,3);

% check if the critical indices are unique
rep = sum(diff(ind_arr)<2);
if  rep > 0
    warning([num2str(rep) ' catheter-helix intersections too close. Examine the surrounding nodes for substitutes.']);
    i_problem = find(diff(ind_arr)<2); %     i_problem = setdiff(1:length(ind_arr),sort(b)); % find the repeating indices
    for pp = 1:length(i_problem)
        ii = i_problem(pp); % index in the array of intersections
        temp = sqrt((xh-x0(ii)).^2 + (yh-y0(ii)).^2); % recalculate distance
        [~,b] = sort(temp);
        [~,a] = max(abs(b(1:4) - ind_arr(ii))); % find the most different index in the surrounding
        ind_arr(ii) = b(a);
    end
end
ind_arr = sort(ind_arr);

%% find apexes of the helix
ind_peak = nan(1,length(ind_arr)-1);
for ii = 1:length(ind_arr)-1
    tempi = ind_arr(ii):ind_arr(ii+1);      % array of indices to go through
    if length(tempi)<3
        error('Indices overlapped because the intersections are too close to each other. Increase the number of nodes along the helix.');
    else
    end
    tempx = xh(tempi); tempy = yh(tempi);                           % find local slope of the line connecting the first and last nodes
    tempa = atan2(tempy(end)-tempy(1),tempx(end)-tempx(1));         % find the angle under the slope
    temp = getRZ(-tempa)*[tempx;tempy;zeros(1,length(tempx))];      % rotate the curve to align with the x-axis
    tempx = temp(1,:) - temp(1,1); tempy = temp(2,:) - temp(2,1);   % translate the curve to the origin
    if mean(tempy) < 0
        tempy = -tempy;                                             % flip y coordinates if concave up
    end
    temp = [tempx;tempy]'; temp = sortrows(temp); temp = temp';     % sort x and y so x is in ascending order
    tempyy = temp(2,:);                         % temporarily save sorted x and y
    pks = max(tempyy);
    if sum(tempy==pks)~=1
        error(['One of the peaks (ii = ' num2str(ii) ') has a number of representative nodes that is not equal to 1. The helices might be too wide.']);
    end
    ind_peak(ii) = tempi(tempy==pks);                                           % find the indice of the maximum peak
end
x_pks_arr = xh(ind_peak); % save the peak's original x location
y_pks_arr = yh(ind_peak); % save the peak's original y location

%% plot
if plt_flg
    hold on;
    plot(xh,yh,'.-'); % plot helix
    plot(xh(ind_arr),yh(ind_arr),'o'); % plot node points along the curve that are the closest to the intersections
    plot(xh(ind_peak),yh(ind_peak),'*'); % plot peaks
    axis equal
end