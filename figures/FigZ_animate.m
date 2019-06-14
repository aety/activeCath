ca;clear;clc;

%% define animate
%%% videos
% th_r_arr = 0:60; th_p_arr = zeros(1,length(th_r_arr)); th_y_arr = th_p_arr; th_b_arr = 45+th_p_arr; vname = 'roll'; ii = 1;
% th_p_arr = 0:-1:-15; th_y_arr = zeros(1,length(th_p_arr)); th_b_arr = 45+th_y_arr; th_r_arr = th_y_arr; vname = 'pitch'; ii = 2; 
% th_y_arr = 0:25; th_b_arr = 45+zeros(1,length(th_y_arr)); th_r_arr = zeros(1,length(th_y_arr)); th_p_arr = th_r_arr; vname = 'yaw'; ii = 3;
% th_b_arr = [0.0000001,2:2:60]; th_r_arr = zeros(1,length(th_b_arr)); th_p_arr = th_r_arr; th_y_arr = th_r_arr; vname = 'bend'; ii = 4;

%%% figures
% th_b_arr = 45; th_r_arr = zeros(1,length(th_b_arr)); th_p_arr = th_r_arr; th_y_arr = th_r_arr; vname = 'bend'; ii = 4;
th_r_arr = 60; th_p_arr = zeros(1,length(th_r_arr)); th_y_arr = th_p_arr; th_b_arr = 45+th_p_arr; vname = 'roll'; ii = 1;

vidflag = 0; % save video
vidrate = 10; % video frame rate

if vidflag
    opengl('software');
    anim = VideoWriter(['FigZ_animate_' vname],'Motion JPEG AVI');
    anim.FrameRate = vidrate;
    open(anim);
end

%%
fsz = 36;
lwd = 1;

% define catheter
L = 100;            % length of catheter (mm)
L_pct_bent = 80;    % active length (%)
L_res = 0.5;        % number of nodes along catheter length

% define helix
p1_helix = 20;      % helix starting point (% length)
p2_helix = 90;      % helix ending point (% length)
npt_helix = 100;    % number of points of the helix
a_helix = 1;        % amplitude of the sine wave of the helix (mm)
n_helix = 15;        % number of sinusoids of the helix

% define translation
trans_x = 0; % base x-translation
trans_y = 0; % base y-translation
trans_z = 0; % base z-translation

%%
for rr = 1:length(th_r_arr)
    
    th_b = th_b_arr(rr);              % bending (degree)
    
    % define rotation
    th_r = th_r_arr(rr);    % rotation (degree)
    th_yaw = th_y_arr(rr);  % yaw (degree)
    th_p = th_p_arr(rr);    % pitch (degree)
    
    th_end = th_b*pi/180;% bending (rad)
    alpha = th_r*pi/180;    % roll (rad)
    beta = th_yaw*pi/180;        % yaw (rad)
    gamma = th_p*pi/180;       % pitch (rad)
    M_rot = getRY(gamma)*getRZ(beta)*getRX(alpha); % associated rotation matrix
    
    
    % define camera
    cam_cl = [0,0.4470,0.7410]; % camera color in RGB
    camAngle = 0*pi/180;        % camera y-rotation angle
    cam_lc = [L/2,L/2,40];       % camera position
    
    % configure catheter
    L2 = 0.01*L_pct_bent*L;
    L1 = L - L2;
    
    if th_end==0
        error('Bending angle th_end cannot be zero.');
    end
    Rk = L2/th_end; % radius of curvature of the bent section
    
    x1 = 0:L_res:L1;            % x of unbent
    y1 = zeros(1,length(x1));   % y of unbent
    
    xc = L1;    % x-location of the center of virtual circle
    yc = Rk;    % y-location of the center of virtual circle
    
    th_c = th_end;              % total angle that the arc spans (rad)
    th_incre = th_c/(L2/L_res); % angle increment (rad)
    th_angles = (1:(L2/L_res))*th_incre; % arc angle array
    
    x2 = L1 + Rk*sin(th_angles);% x of bent section
    y2 = Rk - Rk*cos(th_angles);% y of bent sectoin
    
    X = [x1,x2];            % catheter X coordinate
    Y = [y1,y2];            % catheter Y coordinate
    Z = zeros(1,length(X)); % catheter Z coordinate
    
    M = [X;Y;Z]; % catheter XYZ combined
    
    % configure helix
    pct_helix = p2_helix - p1_helix; % helix global length (% of cathetler L)
    
    % define three segments along the bent length (space 1, helix, space 2) % the three variables below should sum up to 1
    frac_space_1 = (p1_helix - (100 - L_pct_bent))/L_pct_bent;  % ratio of the bent section before helix coverage (a ratio of bent length)
    frac_helix_bent = pct_helix/L_pct_bent;                     % ratio of helix coverage (a ratio of bent length)
    
    % identify theta angle from the perspective of the big circle defining curvature
    th_1 = -pi/2 + frac_space_1*th_c;
    th_helix_range = frac_helix_bent*th_c;
    th_2 = th_1 + th_helix_range;
    
    % adjust the total number of sinusoids based on th_helix_range
    n_effect_helix = n_helix*2*pi/th_helix_range; % effective number of sinusoids (adjusted for the equation)
    
    % define an array for all theta angles along the helix
    th_helix = linspace(th_2,th_1,npt_helix);
    
    % compile helix
    xh = xc + (Rk + a_helix*sin(n_effect_helix*th_helix)).*cos(th_helix);   % x location of helix
    yh = yc + (Rk + a_helix*sin(n_effect_helix*th_helix)).*sin(th_helix);   % y location of helix
    zh = a_helix*cos(n_effect_helix*th_helix);
    
    M_helix = [xh;yh;zh];
    
    % rotate both the catheter and the helix
    M = M_rot*M;
    X = M(1,:); Y = M(2,:); Z = M(3,:);
    M_helix = M_rot*M_helix;
    xh = M_helix(1,:); yh = M_helix(2,:); zh = M_helix(3,:);
    
    % translate both the catheter and the helix
    X = X + trans_x; xh = xh + trans_x;
    Y = Y + trans_y; yh = yh + trans_y;
    Z = Z + trans_z; zh = zh + trans_z;
    
    % prepare to plot
    c_arr = colormap(lines); % color array
    ii_arr = 1 + [0,length(x1)]; % index along the catheter to start plotting from
    vv_arr = [-37.5,30; 0,90; 0,90];% view in each subplot
    xx_arr = {'x_0','x_c','x_c'};   % xlabel in each subplot
    yy_arr = {'y_0','y_c','y_c'};   % ylabel in each subplot
    zz_arr = {'z_0','z_c','z_c'};   % zlabel in each subplot
    axcl_arr = {'k',cam_cl,cam_cl}; % axis label color in each subplot
    
    % plot 3D view
    hh = 1;
    hold on;
    ha = plot3(X(ii_arr(hh):end),Y(ii_arr(hh):end),Z(ii_arr(hh):end),'-','color',0.5*[1,1,1],'linewidth',4*lwd); % plot catheter
    hp = plot3(X(end),Y(end),Z(end),'.','color',0.5*[1,1,1],'markersize',10*lwd); % plot catheter
    hb = plot3(xh,yh,zh,'color','k','linewidth',lwd); % plot helix
    
    if rr==1
        % plot camera
        hc = plotCamera('Location',cam_lc,'Orientation',getRY(camAngle),'Size',5,'Label','','Color','k','Opacity',0.2,'AxesVisible',0);
        
        % plot axes
        if ii<4
            f = 40;
            c = c_arr(5,:);
            x = [0,0,0]; y = -2*[1,1,1]; z = [0,0,0];
            u = f*[1,0,0]; v = f*[0,1,0]; w = f*[0,0,1];
            hq = quiver3(x(ii),y(ii),z(ii),u(ii),v(ii),w(ii),'filled','color',c,'linewidth',2,'maxheadsize',1);
            switch ii
                case 1
                    hx = text(0.9*f,-0.5*f,0.1*f,'\theta_{roll}','color',c,'fontsize',fsz);
                case 2
                    hy = text(0,1.5*f,0,'\theta_{pitch}','color',c,'fontsize',fsz);
                case 3
                    hz = text(0,0,1.1*f,'\theta_{yaw}','color',c,'fontsize',fsz);
            end
        end
    end
    
    % format
    view(vv_arr(hh,:));
    axis tight;
    axis equal;
    box off;
    grid on;
    axis([-2,100,-5,66,0,50]);
    ax = gca;
    ax.TickLength = [0,0];
    ax.XTick = 0:20:100; ax.YTick =0:20:100; ax.ZTick = 0:20:100;
    ax.GridColor = 0.15*[1,1,1];
    ax.XTickLabel = []; ax.YTickLabel = []; ax.ZTickLabel = [];
    ax.Position = [0,0,1,1];
    set(gcf,'position',[500,500,500,400]);
    set(gcf,'color','w');
    if ii==4
        view(2);
        ha(2) = plot([0,L],[0,0],'--','color',c_arr(2,:),'linewidth',lwd);
        yt = Y(end); xt = yt/tand(th_b);
        ha(3) = plot([X(end)-xt,X(end)],[0,Y(end)],'--','color',c_arr(2,:),'linewidth',lwd);
        ha(4) = text(X(end)-20,Y(end)+10,'\theta_{bend}','fontsize',fsz,'color',c_arr(2,:));
    end    
    if vidflag
        removeToolbarExplorationButtons;
        frame = getframe(gcf);
        writeVideo(anim,frame);
        delete([ha]);
    else
        set(gcf,'paperposition',[0,0,6,4],'unit','inches');
        print('-dtiff','-r300',['FigZ_animate_' vname]);
        close;
    end
    
end

if vidflag
    close(anim);
    close;
end

%% FigZB
% view(2);
% delete(hc); delete(hq); delete([hx,hy,hz]);
%
% plot([0,L],[0,0],'--','color',c_arr(2,:));
% yt = Y(end); xt = yt/tand(th_b);
% plot([X(end)-xt,X(end)],[0,Y(end)],'--','color',c_arr(2,:));
% text(5+X(end)-xt,6+0,'\theta_{bend}','fontsize',fsz,'color',c_arr(2,:));

% legend([ha,hb],'catheter','helices','location','northwest','fontsize',fsz);
% ax.Position = [0.05,0,0.9,1];
% print('-dtiff','-r300','FigZB');
% close