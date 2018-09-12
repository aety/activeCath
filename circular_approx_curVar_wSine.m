% frac_helix = 0.25; % arc length as a fraction of the full circle
pct_helix = 30; % percent length with helical wire (%)
npt_helix = 100; % number of points of the helix
a_helix = 1; % amplitude of the sine wave of the helix (mm)
n_helix = 4; % number of sinusoids of the helix

%%
L = 100; % length of catheter (mm)
res = 0.5; % catheter spatial resolution (interval between nodes) (mm)
pct_bent = 70; % percent length bent (%)

%%
fname = 'curVar';
var_name = 'r_K, radius of curvature (mm)';
con_name = ['L_{bend} = ' num2str(pct_bent) ' (%)'];

variable_arr = 100; % 50:50:500;

%%
color_arr = colormap(lines(length(variable_arr)));

for rr = 1:length(variable_arr)
    
    Rk = variable_arr(rr); % radius of curvature (to define bent shape)
    
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
    
    %% helix
    frac_helix = th_c*pct_helix/pct_bent; % arc length as a fraction of the full circle
    th_helix = -pi/2 + th_c - linspace(0,frac_helix,npt_helix); % generate th arra for the helix
    n_effect_helix = n_helix*2*pi/frac_helix; % effective number of sinusoids (adjusted for the equation)
    
    xh = xc + (Rk + a_helix*sin(n_effect_helix*th_helix)).*cos(th_helix); % x location of helix
    yh = yc + (Rk + a_helix*sin(n_effect_helix*th_helix)).*sin(th_helix); % y location of helix
    
    %% plot
    X = [x1,x2];
    Y = [y1,y2];
    
    hold on
    h(rr) = plot(X,Y,'-','color',color_arr(rr,:),'linewidth',2);
    %     plot(X(end-1:end),Y(end-1:end),'-','linewidth',2,'color',color_arr(rr,:));
    text(X(end),Y(end),[num2str(th_end,3) '\circ'],'color',color_arr(rr,:),'fontsize',8);
    
    plot(xh,yh);
    
    %% visual aids
    % x_cir = xc + Rk*cosd(0:10:360);
    % y_cir = yc + Rk*sind(0:10:360);
    % plot(x_cir,y_cir);
    
end

axis equal;
xlim([0,1.2*L]);

xlabel('x (mm)');
ylabel('y (mm)');
title({var_name; con_name},'fontweight','normal');

% legendCell = strcat(string(num2cell(variable_arr)));
% legend(h,legendCell,'location','eastoutside');
hc = colorbar;
set(hc,'ytick',(1:length(variable_arr))/length(variable_arr),'yticklabel',variable_arr);
set(hc,'box','off');

set(gca,'fontsize',8);
set(gcf,'paperposition',[0,0,4,3],'unit','inches');
% print('-dtiff','-r150',['circular_approx_' fname]);
% close;