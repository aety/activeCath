clear; clc; ca;

%% define catheter 3D rotation (about x-axis)
rot_arr = 15:10:75; % array of angles to rotate the catheter by (deg)

%% define helix
p1_helix = 55;      % helix starting point (% length)
p2_helix = 95;      % helix ending point (% length)
npt_helix = 200;    % number of points of the helix
a_helix = 1;        % amplitude of the sine wave of the helix (mm)
n_helix = 8;        % number of sinusoids of the helix

%% define catheter
L = 100;        % length of catheter (mm)
L_res = 0.5;      % catheter spatial resolution (interval between nodes) (mm)
L_pct_bent = 50;  % percent length bent (%)

%% define varying parameter and associated file name and descriptions
variable_arr = 5:10:85; % array of values for the varying parameter

fname = 'curVar';
var_name = '\theta_{end} (\circ)';
con_name = ['L_{bend} = ' num2str(L_pct_bent) '%'];

%% preallocate
X_ARR = cell(length(rot_arr),length(variable_arr));
Y_ARR = X_ARR;
Z_ARR = X_ARR;
XH_ARR = X_ARR;
YH_ARR = X_ARR;
ZH_ARR = X_ARR;
X_PKS_ARR= X_ARR;
Y_PKS_ARR = X_ARR;

%% loop for rotation
for aa = 1:length(rot_arr)
    
    alpha_rot = rot_arr(aa)*pi/180; % catheter's axial rotation (converting into rad)
    M_rot = getRX(alpha_rot);     % the associated rotation matrix
    
    %% loop for bending the catheter
    for rr = 1:length(variable_arr)        
        
        th_end = variable_arr(rr)*pi/180;  % radius of curvature (to define bent shape)
        if th_end==0
            error('Bending angle cannot be zero.');
        end
        
        %% configure catheter
        L2 = 0.01*L_pct_bent*L;
        L1 = L - L2;
        
        Rk = L2/th_end; % radius of curvature of the bent section
        
        x1 = 0:L_res:L1;              % x of unbent
        y1 = zeros(1,length(x1));   % y of unbent
        
        xc = L1;    % x-location of the center of virtual circle
        yc = Rk;    % y-location of the center of virtual circle
        
        th_c = th_end;                   % total angle that the arc spans (rad)
        th_incre = th_c/(L2/L_res);       % angle increment (rad)
        th_angles = (1:(L2/L_res))*th_incre; % arc angle array
        
        x2 = L1 + Rk*sin(th_angles);   % x of bent section
        y2 = Rk - Rk*cos(th_angles);   % y of bent sectoin
        
        X = [x1,x2];            % catheter X coordinate
        Y = [y1,y2];            % catheter Y coordinate
        Z = zeros(1,length(X)); % catheter Z coordinate
        
        M = [X;Y;Z]; % catheter XYZ combined
        
        %% configure helix
        pct_helix = p2_helix - p1_helix; % helix global length (% of cathetler L)
        
        % define three segments along the bent length (space 1, helix, space 2) % the three variables below should sum up to 1
        frac_space_1 = (p1_helix - (100 - L_pct_bent))/L_pct_bent;  % ratio of the bent section before helix coverage (a ratio of bent length)
        frac_helix_bent = pct_helix/L_pct_bent;                   % ratio of helix coverage (a ratio of bent length)
        frac_space_2 = (100 - p2_helix)/L_pct_bent;               % ratio of the bent section after helix coverage (a ratio of bent length)
        
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
        
        %% find apexes in X-Y projection
        [x_pks,y_pks] = func_find_apex_rot(xh,yh,X,Y,0);
        
        %% save into big arrays
        X_PKS_ARR{aa,rr} = x_pks;
        Y_PKS_ARR{aa,rr} = y_pks;
        X_ARR{aa,rr} = X; Y_ARR{aa,rr} = Y; Z_ARR{aa,rr} = Z;
        XH_ARR{aa,rr} = xh; YH_ARR{aa,rr} = yh; ZH_ARR{aa,rr} = zh;
        
        
    end
    
    
end

save catheter_simulator_findApex *_ARR *_arr *name p1_helix p2_helix npt_helix a_helix n_helix L L_res L_pct_bent