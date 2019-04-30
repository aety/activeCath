%% define catheter 3D rotation (about x-axis)
roll_arr = 0:2.5:80; % array of the "roll" rotation (deg)
pitch_arr = 0:2.5:50;% array of the "pitch" rotation (deg)
bend_arr = [0.000001,2.5:2.5:80];% array of values for the varying parameter

%% define catheter
L = 105;            % length of catheter (mm)
L_res = 0.5;        % catheter spatial resolution (interval between nodes) (mm)
L_pct_bent = 95;    % percent length bent (%)
poly_npt = 100;     % number of points for polynomial appxoimation
% poly_ord = 3;       % order for polynomial fit

%% define helix
p1_helix = 10*100/L;    % helix starting point (% length)
p2_helix = 92*100/L;    % helix ending point (% length)
npt_helix = 1000;        % number of points of the helix
a_helix = 3.5;          % amplitude of the sine wave of the helix (mm)

%% define reference
ref_pt = [5,0]; % reference base point (circular coils in experiment)

%% preallocate
n_row = length(roll_arr)*length(pitch_arr)*length(bend_arr);
b_arr = nan(n_row,1);
r_arr = b_arr;
p_arr = b_arr;
PKS = cell(1,n_row);
TGL = PKS;
X_ARR = nan(poly_npt,n_row);
Y_ARR = X_ARR;
nn = 0;

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
            
            disp([num2str(bb) '/' num2str(length(pitch_arr)) ', ' num2str(aa) '/' num2str(length(roll_arr)) ', ' num2str(rr) '/' num2str(length(bend_arr))]);
            
            th_end = bend_arr(rr)*pi/180;  % radius of curvature (to define bent shape)
            if th_end==0
                error('Bending angle cannot be zero.');
            end
            
            %% configure catheter
            L2 = 0.01*L_pct_bent*L;
            L1 = L - L2;
            
            Rk = L2/th_end; % radius of curvature of the bent section
            
            x1 = 0:L_res:L1;            % x of unbent
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
            [x_pks,y_pks,tgl] = FindHelixPeaks(xh,yh,X,Y);
            
            %% determine on which side of the catheter the peaks are
            %             [p,S,mu] = polyfit(X,Y,poly_ord); % polyfit
            %             X_ap = interp1(linspace(0,1,length(X)),X,linspace(0,1,poly_npt));
            %             [Y_ap,~] = polyval(p,X_ap,S,mu);
            %             [y_pks_poly,~] = polyval(p,x_pks,S,mu);
            %             tgl = (y_pks - y_pks_poly) < 0;
            
            %% reduce the resolution of catheter (no need for high-resolution calculation)
            X = interp1(1:length(X),X,linspace(1,length(X),poly_npt));
            Y = interp1(1:length(Y),Y,linspace(1,length(Y),poly_npt));
            
            %% plot (optional)
            dif = abs(length(tgl) - sum(tgl) - sum(tgl));
            if dif > 1
                hold on;
                plot(x_pks,y_pks,'*');                
                plot(X,Y,'--');
                plot(x_pks(tgl),y_pks(tgl),'o')
                plot(xh,yh);
                axis equal
                title([bb,aa,rr]);
                pause;
                clf;
            end
            
            %% save into big arrays
            nn = nn + 1;
            b_arr(nn) = bend_arr(rr);
            r_arr(nn) = roll_arr(aa);
            p_arr(nn) = pitch_arr(bb);
            PKS{nn} = [x_pks;y_pks];
            TGL{nn} = tgl;
            X_ARR(:,nn) = X;
            Y_ARR(:,nn) = Y;
        end % bend_arr
        
    end % roll_arr
    
end % pitch_arr

X = X_ARR;
Y = Y_ARR;

save(['proc_findApex_3DoF_varHelixN_' num2str(n_helix)],'b_arr','r_arr','p_arr','PKS','TGL','X','Y','ref_pt');