%% calculate_error.m 
%
% This script calculates the catheter tip bending angle errors if it is a
% line contact instead of a point contact.

th = 0:20:80; % deg (bending angle)
th = th*pi/180; % rad (bending angle)
L = 90; % mm (catheter)
r = L./th; % mm (radius of curvature)
L_stopper = 1.5; % mm (stopper axial length)
th_err = L_stopper./r; % rad (max error of bending angle)
th_err = th_err*180/pi; % deg (max error of bending angle)