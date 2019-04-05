function [xxx,yyy] = func_find_helix_start_pair(x0,y0,x,y,dist)
% function [xxx,yyy] = func_find_helix_start_pair(x0,y0,x,y,a_helix)
%
% This function outputs two 2-by-1 variables representing the x-y location
% of two points. The two points form a line that is perpendicular to the
% curve [x,y] and includes the input point [x0,y0]. The line extends on
% each side of the curve [x,y] by a lenght [dist].

d = sqrt((x0-x).^2 + (y0-y).^2);
[~,ind] = sort(d); ind = ind(1:2);
x1 = x(ind(1)); y1 = y(ind(1));
x2 = x(ind(2)); y2 = y(ind(2));
a = x2-x1; b = y2-y1;
n = (b*(x0-x1)+a*(y1-y0))/(a^2+b^2);
xx = x0-b*n; yy = y0+a*n;

dd = sqrt((xx-x0)^2+(yy-y0)^2);
n = n*dist/dd;

xxx(1) = xx - b*n; yyy(1) = yy + a*n;
xxx(2) = xx + b*n; yyy(2) = yy - a*n;