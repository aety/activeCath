function [x_int_arr,y_int_arr] = func_find_apex(xh,yh,X,Y,plt_flg)
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

%% find intersections between two curves
[x0,y0,~,~] = intersections(xh,yh,X,Y,0);

%% find intersections between the catheter and the helix
ind_arr = nan(1,length(x0));  % preallocate


for ii = 1:length(x0)
    temp = sqrt((xh-x0(ii)).^2 + (yh-y0(ii)).^2);
    ind_arr(ii) = find(temp==min(temp)); % find indices of intersections along the curve
    
end
xm = nan(1,length(x0)-1);       % preallocate
ym = xm;                        % preallocate
slp = nan(1,length(x0)-1);      % preallocate
x_int_arr = slp; y_int_arr = slp;   % preallocate
for ii = 1:length(x0)-1
    xm(ii) = mean(x0(ii:ii+1)); % midpoint approximation
    ym(ii) = mean(y0(ii:ii+1)); % midpoint approximation
    slp(ii) = diff(y0(ii:ii+1))/diff(x0(ii:ii+1)); % find slope
end

nml = -1./slp; % find normal vectors
xn = xm + 1; % draw normal vectors
yn = ym + 1*nml; % draw normal vectors

%% find apexes of the helix
for ii = 1:length(xm)
    x_line = [xm(ii),xn(ii)];
    y_line = [ym(ii),yn(ii)];
    arr = ind_arr(ii):ind_arr(ii+1);
    if ind_arr(ii)>ind_arr(ii+1)
        arr = ind_arr(ii+1):ind_arr(ii);
    end
    x_curve = xh(arr);
    y_curve = yh(arr);
    [x_int,y_int] =  line_curve_inters(x_line,y_line,x_curve,y_curve);
    x_int_arr(ii) = x_int;
    y_int_arr(ii) = y_int;
end

%% plot
if plt_flg
    hold on;
    plot(xh,yh); % plot helix
    plot(x0,y0,'*'); % plot intersections
    plot(xh(ind_arr),yh(ind_arr),'o'); % plot node points along the curve that are the closest to the intersections
    plot(xm,ym,'d'); % plot average points between intersections
    plot([xm;xn],[ym;yn],'k'); % plot normal vectors
    plot(x_int_arr,y_int_arr,'+'); % plot apexes
    axis equal
end