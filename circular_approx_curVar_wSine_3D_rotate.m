%% define vido (animation) properties
opengl('software');

vidflag = 1;

if vidflag
    anim = VideoWriter(datestr(datetime('now'),'yyyy-mm-dd-HHMMss'),'Motion JPEG AVI');
    anim.FrameRate = 3;
    open(anim);
end

%% define catheter 3D rotation (about x-axis)
rot_arr = [0:10:90,80:-10:0]; % array of angles to rotate the catheter by (deg)

%% define helix
p1_helix = 70;      % helix starting point (% length)
p2_helix = 95;      % helix ending point (% length)
npt_helix = 100;    % number of points of the helix
a_helix = 1;        % amplitude of the sine wave of the helix (mm)
n_helix = 4;        % number of sinusoids of the helix

%% define catheter
L = 100;        % length of catheter (mm)
res = 0.5;      % catheter spatial resolution (interval between nodes) (mm)
pct_bent = 70;  % percent length bent (%)

%% define varying parameter and associated file name and descriptions
variable_arr = 10:10:90; % array of values for the varying parameter

fname = 'curVar';
var_name = '\theta_{end} (\circ)';
con_name = ['L_{bend} = ' num2str(pct_bent) '%'];

%% looop for rotation
for aa = 1:length(rot_arr)% aa = 1;
    
    alpha_rot = rot_arr(aa)*pi/180; % catheter's axial rotation (converting into rad)
    M_rot = getRX(alpha_rot);     % the associated rotation matrix
    
    %% loop for bending the catheter
    color_arr = colormap(parula(length(variable_arr)));
    
    for rr = 1:length(variable_arr)
        
        th_end = variable_arr(rr)*pi/180;  % radius of curvature (to define bent shape)
        
        %% configure catheter
        L2 = 0.01*pct_bent*L;
        L1 = L - L2;
        
        Rk = L2/th_end; % radius of curvature of the bent section
        
        x1 = 0:res:L1;              % x of unbent
        y1 = zeros(1,length(x1));   % y of unbent
        
        xc = L1;    % x-location of the center of virtual circle
        yc = Rk;    % y-location of the center of virtual circle
        
        th_c = th_end;                   % total angle that the arc spans (rad)
        th_incre = th_c/(L2/res);       % angle increment (rad)
        th_arr = (1:(L2/res))*th_incre; % arc angle array
        
        x2 = L1 + Rk*sin(th_arr);   % x of bent section
        y2 = Rk - Rk*cos(th_arr);   % y of bent sectoin
        
        X = [x1,x2];            % catheter X coordinate
        Y = [y1,y2];            % catheter Y coordinate
        Z = zeros(1,length(X)); % catheter Z coordinate
        
        M = [X;Y;Z]; % catheter XYZ combined
        
        %% configure helix
        pct_helix = p2_helix - p1_helix; % helix global length (% of cathetler L)
        
        % define three segments along the bent length (space 1, helix, space 2) % the three variables below should sum up to 1
        frac_space_1 = (p1_helix - (100 - pct_bent))/pct_bent;  % ratio of the bent section before helix coverage (a ratio of bent length)
        frac_helix_bent = pct_helix/pct_bent;                   % ratio of helix coverage (a ratio of bent length)
        frac_space_2 = (100 - p2_helix)/pct_bent;               % ratio of the bent section after helix coverage (a ratio of bent length)
        
        % identify theta angle from the perspective of the big circle defining curvature
        th_1 = -pi/2 + frac_space_1*th_c;
        th_helix_range = frac_helix_bent*th_c;
        th_2 = th_1 + th_helix_range;
        
        % adjust the total number of sinusoids based on th_helix_range
        n_effect_helix = n_helix*2*pi/th_helix_range;           % effective number of sinusoids (adjusted for the equation)
        
        % define an array for all theta angles along the helix
        th_helix = linspace(th_2,th_1,npt_helix);
        
        % compile helix
        xh = xc + (Rk + a_helix*sin(n_effect_helix*th_helix)).*cos(th_helix);   % x location of helix
        yh = yc + (Rk + a_helix*sin(n_effect_helix*th_helix)).*sin(th_helix);   % y location of helix
        zh = a_helix*cos(n_effect_helix*th_helix);
        
        M_helix = [xh;yh;zh];
        
        %% rotate both the catheter and the helix
        M = M_rot*M;
        X = M(1,:); Y = M(2,:); Z = M(3,:);
        M_helix = M_rot*M_helix;
        xh = M_helix(1,:); yh = M_helix(2,:); zh = M_helix(3,:);
        
        %% plot
        for pp = 1:4
            subplot(2,2,pp);
            hold on
            plot3(X,Y,Z,'-','color',color_arr(rr,:),'linewidth',1); % plot catheter
            plot3(xh,yh,zh,'color',color_arr(rr,:),'linewidth',1); % plot helix
        end
        text(X(end),Y(end),Z(end),num2str(th_end*180/pi,3),'color',color_arr(rr,:));
    end
    
    %% format figure
    
    view_arr = [-37.5+90,30; 0,90; 90,0; 0,0];
    
    for pp = 1:4
        
        subplot(2,2,pp);
        
        axis equal;
        xlim([0,L]);
        ylim([0,L/2]);
        zlim([0,L/2]);
        view(view_arr(pp,:));
        
        % labels
        xlabel('x (mm)');
        ylabel('y (mm)');
        zlabel('z (mm)');
        set(gca,'fontsize',12);
        
    end
    
    % add information about the helix
    subplot(2,2,1);
    text(0,0,L/2,{[con_name ', L_{helix} = ' num2str(p1_helix) '~' num2str(p2_helix) ' %'];...
        [num2str(n_helix) ' sines at ' num2str(a_helix) ' mm']},'fontweight','normal');
    
    % % %     % colorbar (legend)
    % % %     subplot(2,2,1);
    % % %     hc = colorbar;
    % % %     set(hc,'ytick',[1,length(variable_arr)]/length(variable_arr),'yticklabel',[variable_arr(1),variable_arr(end)]);
    % % %     set(hc,'box','off');
    % % %     ylabel(hc,var_name);
    % % %     hc.Location = 'southoutside';
    
    % sizing and saving
    set(gcf,'position',[100,100,600,400]);
    
    %% save frame for video
    if vidflag
        frame = getframe(figure(1));
        writeVideo(anim,frame);
    else
        pause;
    end
    clf;
    
end

%% close video
if vidflag
    close(anim);
end
close;