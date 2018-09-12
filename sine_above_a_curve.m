frac = 0.25; % arc length as a fraction of the full circle
npt = 200; % number of points 
Rk = 10; % radius of curvature
a = 1; % amplitude of the sine wave
n = 20; % number of sinusoids


x = (Rk + a*sin(n_effect*th)).*cos(th);
y = (Rk + a*sin(n_effect*th)).*sin(th);

plot(Rk*sin(th),Rk*cos(th));
hold on;
plot(x,y,'*-');
axis equal