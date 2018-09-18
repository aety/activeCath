% % % function [x_int_arr,y_int_arr] = func_find_apex_rot(xh,yh,X,Y,plt_flg)
% % % % This function looks for the apexes of the sinusoidal helices wrapped
% % % % around around a catheter in the X-Y projection view
% % % % Anne Yang 2018.09.17
% % % % --------------------------------
% % % % Input variables--
% % % %   xh: helix x-coordinate
% % % %   yh: helix y-coordinate
% % % %   X: catheter x-coordinate
% % % %   Y: catheter y-coordinate
% % % %   plt_flg: toggle for plotting

load test_3samples
plt_flg = 1;

%% find intersections between two curves
[x0,y0,~,~] = intersections(xh,yh,X,Y,0);

%% find intersections between the catheter and the helix
ind_arr = nan(1,length(x0));  % preallocate

for ii = 1:length(x0)
    temp = sqrt((xh-x0(ii)).^2 + (yh-y0(ii)).^2);
    ind_arr(ii) = find(temp==min(temp)); % find indices of intersections along the curve
end

% check if the critical indices are unique
rep = length(ind_arr) - length(unique(ind_arr)); % no. of elements - no. of unique elements
if  rep > 0
    warning([num2str(rep) ' catheter-helix intersections too close. Examine the surrounding nodes for substitutes.']);
    [~,b] = unique(ind_arr); % find indices of unique elements
    i_problem = setdiff(1:length(ind_arr),sort(b)); % find the repeating indices
    for pp = 1:length(i_problem)
        ii = i_problem(pp);
        temp = sqrt((xh-x0(ii)).^2 + (yh-y0(ii)).^2); % recalculate distance
        [~,b] = sort(temp);
        [~,a] = max(abs(b(1:4) - ii)); % find the most different index in the surrounding
        ind_arr(ii) = b(a);
    end
end


%% find apexes of the helix
ind_peak = nan(1,length(x0)-1);
for ii = 1:length(x0)-1
    tempi = ind_arr(ii):ind_arr(ii+1);      % array of indices to go through
    if ind_arr(ii+1)-ind_arr(ii)<0
        tempi = ind_arr(ii+1):ind_arr(ii);  % flip the order if x is in reverse order
    end
    if length(tempi)<2
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
    tempxx = temp(1,:); tempyy = temp(2,:);                         % temporarily save sorted x and y
    [pks,locs,~,~] = findpeaks(tempyy,tempxx,'NPeaks',1,'SortStr','descend');   % find the maximum peak
    ind_peak(ii) = tempi(tempy==pks);                                           % find the indice of the maximum peak
end
x_int_arr = xh(ind_peak); % save the peak's original x location
y_int_arr = yh(ind_peak); % save the peak's original y location

%% plot
if plt_flg
    hold on;
    %     plot(X,Y);
    plot(xh,yh,'.-'); % plot helix
    plot(xh(ind_arr),yh(ind_arr),'o'); % plot node points along the curve that are the closest to the intersections
    plot(xh(ind_peak),yh(ind_peak),'*'); % plot peaks
    axis equal
end