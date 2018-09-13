%% helix
a = 1; % radius of projected circle
b = 2; % longitudinal dimension

t = (1:100)/10;

x = a*cos(t);
y = a*sin(t);
z = b*t;

plot3(x,y,z);

axis equal

%% helix around a circle (2D)
th = linspace(0,2*pi,200);

frac = 0.25; % arc length as a fraction of the full circle
npt = 200; % number of points 
Rk = 10; % radius of curvature
a = 1; % amplitude of the sine wave
n = 20; % number of sinusoids


x = (Rk + a*sin(n*th)).*cos(th);
y = (Rk + a*sin(n*th)).*sin(th);

plot(Rk*sin(th),Rk*cos(th));
hold on;
plot(x,y,'*-');
axis equal

%% helix around a circle (3D)
th = linspace(0,2*pi,200);

frac = 0.25; % arc length as a fraction of the full circle
npt = 200; % number of points 
Rk = 10; % radius of curvature
a = 1; % amplitude of the sine wave
n = 20; % number of sinusoids

x = (Rk + a*sin(n*th)).*cos(th);
y = (Rk + a*sin(n*th)).*sin(th);
z = a*cos(n*th);

plot(Rk*sin(th),Rk*cos(th));
hold on;
plot3(x,y,z,'*-');
axis equal
