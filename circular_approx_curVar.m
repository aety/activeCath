L = 100; % length of catheter (mm)

res = 0.5; % catheter spatial resolution (interval between nodes) (mm)

pct_bent = 70; % percent length bent (%)

%%
Rk_arr = 50:50:500;
color_arr = colormap(lines(length(Rk_arr)));

for rr = 1:length(Rk_arr)
    
    Rk = Rk_arr(rr); % radius of curvature (to define bent shape)
    
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
    
    th_end = atan2(y2(end)-y2(end-1),x2(end)-x2(end-1))*180/pi; % end effector theta
    
    %% plot
    X = [x1,x2];
    Y = [y1,y2];
    
    hold on
    h(rr) = plot(X,Y,'.-','color',color_arr(rr,:));
    plot(X(end-1:end),Y(end-1:end),'-','linewidth',2,'color',color_arr(rr,:));
    text(X(end),Y(end),['\theta = ' num2str(th_end,3) '\circ'],'color',color_arr(rr,:));
    
    
    %% visual aids
    % x_cir = xc + Rk*cosd(0:10:360);
    % y_cir = yc + Rk*sind(0:10:360);
    % plot(x_cir,y_cir);
    
end

axis equal;

xlabel('x (mm)');
ylabel('y (mm)');
title('curvature variation','fontweight','normal');