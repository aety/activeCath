TGL_sav = 1;

% define catheter
L = 100;            % length of catheter (mm)
L_pct_bent = 40;    % active length (%)
L_res = 0.5;        % number of nodes along catheter length

% define helix
p1_helix = 70;      % helix starting point (% length)
p2_helix = 90;      % helix ending point (% length)
npt_helix = 100;    % number of points of the helix
a_helix = 1;        % amplitude of the sine wave of the helix (mm)
n_helix = 5;        % number of sinusoids of the helix

% define rotation
th_b = 1;           % bending (degree)
th_r = 80;           % rotation (degree)

th_end = th_b*pi/180;% bending (rad)
alpha = th_r*pi/180;    % roll (rad)
beta = 0*pi/180;        % yaw (rad)
gamma = 0*pi/180;       % pitch (rad)
M_rot = getRY(gamma)*getRZ(beta)*getRX(alpha); % associated rotation matrix

% define translation
trans_x = 0; % base x-translation
trans_y = 0; % base y-translation
trans_z = 0; % base z-translation

% define camera
cam_cl = [0,0.4470,0.7410]; % camera color in RGB
camAngle = 0*pi/180;        % camera y-rotation angle
cam_lc = [L/2,0,L/2];       % camera position

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
% frac_space_2 = (100 - p2_helix)/L_pct_bent;               % ratio of the bent section after helix coverage (a ratio of bent length)

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
hh_arr = {subplot(1,3,1),subplot(1,3,2),subplot(1,3,3)}; % subplot handles
vv_arr = [-37.5,30; 0,90; 0,90];% view in each subplot
xx_arr = {'x_0','x_c','x_c'};   % xlabel in each subplot
yy_arr = {'y_0','y_c','y_c'};   % ylabel in each subplot
zz_arr = {'z_0','z_c','z_c'};   % zlabel in each subplot
axcl_arr = {'k',cam_cl,cam_cl}; % axis label color in each subplot

% ------------ plot 1 ------------
% plot 3D view
hh = 1;
subplot(1,3,hh); hold on;
plot3(X(ii_arr(hh):end),Y(ii_arr(hh):end),Z(ii_arr(hh):end),'-','color',c_arr(3,:),'linewidth',2); % plot catheter
plot3(xh,yh,zh,'color',c_arr(4,:),'linewidth',1); % plot helix

% plot origin
plot3(0+trans_x,0+trans_y,0+trans_z,'ko','linewidth',2);

% plot camera
plotCamera('Location',cam_lc,'Orientation',getRY(camAngle),'Size',10,'Label','camera','Color',cam_cl,'Opacity',0.2,'AxesVisible',1);

% ------------ plot 2 & 3 ------------

% rotate according to camera angle
[X,Y] = CameraProjection([X;Y;Z],[0;camAngle;0],cam_lc,[0,0,-cam_lc(3)]);
[xh,yh] = CameraProjection([xh;yh;zh],[0;camAngle;0],cam_lc,[0,0,-cam_lc(3)]);

% find apexes in X-Y projection
[x_pks,y_pks] = func_find_apex_rot(xh,yh,X,Y,0);

grid on;

% plot camera views
hh = 2;
subplot(1,3,hh); hold on;
plot(X(ii_arr(hh):end),Y(ii_arr(hh):end),'-','color',c_arr(3,:),'linewidth',2); % plot catheter
plot(xh,yh,'color',c_arr(4,:),'linewidth',1); % plot helix

% plot peaks
for hh = 2:3
    subplot(1,3,hh);
    hold on;
    plot(x_pks,y_pks,'.','color',c_arr(2,:),'markersize',10);
end

% ------------ configure plots ------------
for hh = 1:3
    subplot(1,3,hh);
    view(vv_arr(hh,:));
    axis tight;
    axis equal;
    
    set(gca,'fontsize',12);
    xlabel([xx_arr{hh} ' (mm)'],'color',axcl_arr{hh});
    ylabel([yy_arr{hh} ' (mm)'],'color',axcl_arr{hh});
    zlabel([zz_arr{hh} ' (mm)']);
    box off;
end

set(gcf,'position',[0,0,900,300]);
set(gcf,'color','w');

if TGL_sav
    set(gcf,'paperposition',[0,0,8,3],'unit','inches');
    print('-dtiff','-r300',['catheter_7dof_draw_' num2str(th_b) '_' num2str(th_r)]);
    close
end