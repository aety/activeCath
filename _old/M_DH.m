function T = M_DH(d,th,r,alpha)

%% Denavit–Hartenberg parameters

T = [cos(th), -sin(th)*cos(alpha), sin(th)*sin(alpha), r*cos(th);
    sin(th), cos(th)*cos(alpha), -cos(th)*sin(alpha), r*sin(th);
    0, sin(alpha), cos(alpha), d;
    0, 0, 0, 1];
