L = 100; % length of catheter (mm)
res = 0.5; % catheter spatial resolution (interval between nodes) (mm)
pct_bent = 70; % percent length bent (%)
variable_arr = 10:10:90; % array of the varying parameter

%%
fname = 'curVar';
var_name = '\theta_{end}, tip angle (\circ)';
con_name = ['L_{bend} = ' num2str(pct_bent) ' (%)'];

%%
color_arr = colormap(parula(length(variable_arr)));

for rr = 1:length(variable_arr)
    
    th_end = variable_arr(rr)*pi/180; % theta of the catheter tip
    
    %% configure catheter
    L2 = 0.01*pct_bent*L;
    L1 = L - L2;
    
    Rk = L2/th_end; % radius of curvature of the bent section
    
    x1 = 0:res:L1; % x of unbent
    y1 = zeros(1,length(x1)); % y of unbent
    
    xc = L1; % x-location of the center of virtual circle
    yc = Rk; % y-location of the center of virtual circle
    
    th_c = th_end; % total angle that the arc spans (rad)
    th_incre = th_c/(L2/res); % angle increment (rad)
    th_arr = (1:(L2/res))*th_incre; % arc angle array
    
    x2 = L1 + Rk*sin(th_arr); % x of bent
    y2 = Rk - Rk*cos(th_arr); % y of bent
    
    %% plot
    X = [x1,x2];
    Y = [y1,y2];
    
    hold on
    h(rr) = plot(X,Y,'-','color',color_arr(rr,:),'linewidth',2);
    %     text(X(end),Y(end),[num2str(th_end*180/pi,3) '\circ'],'color',color_arr(rr,:),'fontsize',12);
    
end

axis equal;
xlim([0,1.2*L]);

xlabel('x (mm)');
ylabel('y (mm)');
title([var_name ', ' con_name],'fontweight','normal');

hc = colorbar;
set(hc,'ytick',(1:length(variable_arr))/length(variable_arr),'yticklabel',variable_arr);
set(hc,'box','off');

set(gca,'fontsize',12);
set(gcf,'paperposition',[0,0,4,3],'unit','inches');
print('-dtiff','-r300',['circular_approx_' fname]);
close;