L = 100; % length of catheter (mm)

pct_bent = 30; % percent length bent (%)
res = 0.5; % catheter spatial resolution (interval between nodes) (mm)

Rk = 50; % radius of curvature (to define bent shape)

%% configure catheter

L2 = 0.01*pct_bent*L;
L1 = L - L2; 

x1 = 0:res:L1; % x of unbent
y1 = zeros(1,length(x1)); % y of unbent

xc = L1; % x-location of the center of virtual circle 
yc = Rk; % y-location of the center of virtual circle 

th_c = L2/Rk; % total angle that the arc spans (rad)
th_incre = th_c/(L2/res); % angle increment (rad)
th_arr = (1:(L2/res))*th_incre; % arc angle array 

x2 = L1 + Rk*sin(th_arr); % x of bent
y2 = Rk - Rk*cos(th_arr); % y of bent 

th_end = atand((y2(end)-y2(end-1))/(x2(end)-x2(end-1))); % end effector theta

%% plot
X = [x1,x2];
Y = [y1,y2];

hold on
plot(X,Y,'.-');
plot(X(end-1:end),Y(end-1:end),'*-');
text(X(end)*1.1,Y(end)*1.2,['\theta = ' num2str(th_end)]);
axis equal;

%% visual aids
x_cir = xc + Rk*cosd(0:10:360);
y_cir = yc + Rk*sind(0:10:360);
plot(x_cir,y_cir);