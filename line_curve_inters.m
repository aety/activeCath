function [x_int,y_int] =  line_curve_inters(x_line,y_line,x_curve,y_curve)

% Answer by Star Strider  on 8 Dec 2017
% https://fr.mathworks.com/matlabcentral/answers/371799-intersection-of-line-and-curve-from-thier-points

b_line = polyfit(x_line, y_line,1);                     % Fit ‘line’
y_line2 = polyval(b_line, x_curve);                     % Evaluate ‘line’ At ‘x_curve’
x_int = interp1((y_line2-y_curve), x_curve, 0);         % X-Value At Intercept
y_int = polyval(b_line,x_int);                          % Y-Value At Intercept