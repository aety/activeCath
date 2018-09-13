
%% define helix
p1_helix = 80; % helix starting point (% length)
p2_helix = 95; % helix ending point (% length)
npt_helix = 100; % number of points of the helix
a_helix = 1; % amplitude of the sine wave of the helix (mm)
n_helix = 4; % number of sinusoids of the helix

%% define catheter
L = 100; % length of catheter (mm)
res = 0.5; % catheter spatial resolution (interval between nodes) (mm)
pct_bent = 70; % percent length bent (%)

%% define varying parameter and associated file name and descriptions
variable_arr = 50:50:500; % array of values for the varying parameter

fname = 'curVar';
var_name = 'r_K, radius of curvature (mm)';
con_name = ['L_{bend} = ' num2str(pct_bent) ' (%)'];

%%
color_arr = colormap(parula(length(variable_arr)));
TH_END_arr = nan(1,length(variable_arr));

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
    
    TH_END_arr(rr) = th_end;
    
    X = [x1,x2];
    Y = [y1,y2];
    
    %% configure helix
    pct_helix = p2_helix - p1_helix; % helix global length (% of cathetler L)
    
    % define three segments along the bent length (space 1, helix, space 2) % the three variables below should sum up to 1
    frac_space_1 = (p1_helix - (100 - pct_bent))/pct_bent; % ratio of the bent section before helix coverage (a ratio of bent length)
    frac_helix_bent = pct_helix/pct_bent; % ratio of helix coverage (a ratio of bent length)
    frac_space_2 = (100 - p2_helix)/pct_bent; % ratio of the bent section after helix coverage (a ratio of bent length)
    
    % identify theta angle from the perspective of the big circle defining curvature
    th_1 = -pi/2 + frac_space_1*th_c;
    th_helix_range = frac_helix_bent*th_c;
    th_2 = th_1 + th_helix_range;
    
    % adjust the total number of sinusoids based on th_helix_range
    n_effect_helix = n_helix*2*pi/th_helix_range; % effective number of sinusoids (adjusted for the equation)
    
    % define an array for all theta angles along the helix
    th_helix = linspace(th_2,th_1,npt_helix);
    
    % compile helix
    xh = xc + (Rk + a_helix*sin(n_effect_helix*th_helix)).*cos(th_helix); % x location of helix
    yh = yc + (Rk + a_helix*sin(n_effect_helix*th_helix)).*sin(th_helix); % y location of helix
    zh = a_helix*cos(n_effect_helix*th_helix);

    %% plot
    hold on
    h(rr) = plot(X,Y,'-','color',color_arr(rr,:)); % plot catheter
    %     plot(X(end-1:end),Y(end-1:end),'-','linewidth',2,'color',color_arr(rr,:)); % plot end effector angle
%     text(X(end),Y(end),[num2str(th_end,3) '\circ'],'color',color_arr(rr,:),'fontsize',8); % label end effector angle
    plot3(xh,yh,zh,'color',color_arr(rr,:)); % plot helix
    
    %% visual aids
    % x_cir = xc + Rk*cosd(0:10:360);
    % y_cir = yc + Rk*sind(0:10:360);
    % plot(x_cir,y_cir);
    
end

%% format figure
axis equal;
xlim([0,1.2*L]);
view([-37.5+90,30]);

% labels
xlabel('x (mm)');
ylabel('y (mm)');
title([var_name ', ' con_name],'fontweight','normal');

% add information about the helix
text(5,50,...
    {['helix: ' num2str(p1_helix) ' to ' num2str(p2_helix) ' % L'];...
    ['n \circ of sinusoids = ' num2str(n_helix)];...
    ['sinusoidal amplitude = ' num2str(a_helix) ' (mm)']}...
    ,'fontsize',6);

% colorbar (legend)
hc = colorbar;
set(hc,'ytick',(1:length(variable_arr))/length(variable_arr),'yticklabel',variable_arr);
set(hc,'box','off');

% sizing and saving 
set(gca,'fontsize',8);
set(gcf,'paperposition',[0,0,4,3],'unit','inches');
print('-dtiff','-r300',['circular_approx_' fname '_wSine_3D']);
close;