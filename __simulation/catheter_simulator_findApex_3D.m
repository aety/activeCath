clear; clc; ca;

%% define catheter 3D rotation (about x-axis)
roll_arr = 0:10:70; % array of the "roll" rotation (deg)
pitch_arr = -20:10:20;% array of the "pitch" rotation (deg)
bend_arr = [0.000001,20:20:80];% array of values for the varying parameter

%% define catheter
L = 105;        % length of catheter (mm)
L_res = 0.5;      % catheter spatial resolution (interval between nodes) (mm)
L_pct_bent = 95;  % percent length bent (%)

%% define helix
p1_helix = 10*100/L;    % helix starting point (% length)
p2_helix = 92*100/L;    % helix ending point (% length)
npt_helix = 500;        % number of points of the helix
a_helix = 3.5;          % amplitude of the sine wave of the helix (mm)
n_helix = 16;           % number of sinusoids of the helix

%% preallocate
X_ARR = cell(length(roll_arr),length(bend_arr),length(pitch_arr));
Y_ARR = X_ARR;
Z_ARR = X_ARR;
XH_ARR = X_ARR;
YH_ARR = X_ARR;
ZH_ARR = X_ARR;
X_PKS_ARR= X_ARR;
Y_PKS_ARR = X_ARR;

%% loop for "pitch" rotation
for bb = 1:length(pitch_arr)
    alpha_pitch = pitch_arr(bb)*pi/180;
    M_pitch = getRY(alpha_pitch);
    
    %% loop for "roll" rotation
    for aa = 1:length(roll_arr)
        
        alpha_roll = roll_arr(aa)*pi/180; % catheter's axial rotation (converting into rad)
        M_roll = getRX(alpha_roll);     % the associated rotation matrix
        
        %% loop for bending the catheter
        for rr = 1:length(bend_arr)
            
            th_end = bend_arr(rr)*pi/180;  % radius of curvature (to define bent shape)
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
            M = M_pitch*M_roll*M;
            X = M(1,:); Y = M(2,:); Z = M(3,:);
            M_helix = M_pitch*M_roll*M_helix;
            xh = M_helix(1,:); yh = M_helix(2,:); zh = M_helix(3,:);
            
            %% find apexes in X-Y projection
            [x_pks,y_pks] = FindHelixPeaks(xh,yh,X,Y);            
            
            %% save into big arrays
            X_PKS_ARR{rr,aa,bb} = x_pks;
            Y_PKS_ARR{rr,aa,bb} = y_pks;
            X_ARR{rr,aa,bb} = X; Y_ARR{rr,aa,bb} = Y; Z_ARR{rr,aa,bb} = Z;
            XH_ARR{rr,aa,bb} = xh; YH_ARR{rr,aa,bb} = yh; ZH_ARR{rr,aa,bb} = zh;
            
            
        end
        
    end
    
end

save catheter_simulator_findApex_3D *_ARR *_arr p1_helix p2_helix npt_helix a_helix n_helix L L_res L_pct_bent