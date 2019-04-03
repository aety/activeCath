clear; ca; clc;

% display toggle
dbgflag = 0; % plot (dianostics)
savflag = 1; % save data (mat file)
pltflag = 0; % plot (for video)
vidflag = 0; % save video
vidrate = 3; % video frame rate

% figure parameters
c_arr = lines(6); c_lab_y = c_arr(2,:); c_lab_b = c_arr(6,:); % marker color label
msize = 12; % markersize
lwd = 1; % linewidth
ht = 800; % figure height (pixels)
txt_d = 30; % distance of labeling text from the edge (pixels)
txt_s = 14; % font size

% image processing parameters
A_thres = 500; % minimum area to qualify as a candidate when searching for the three boxes at the bottom of the image
ref_n_pts = 5; % number of points to average on each side when searching for the reference point
ref_pt = [375,520]; % specify the location of the reference point (i.e. the centroid of the helices at the base)
ref_pct_sch = 0.5; % percentage (from the bottom) of vertical dimension to search for the reference boxes
% th1_range = [-75,75]; % range of "roll" rotations to include
plt_range = [201,850,251,800]; % range of pixels to plot ([x_0,x_end,y_0,y_end])
y_min = ref_pt(2); % y position for reference point

thrs_big = 50; % (pixels)^2 threshold for removing oversized identified area (catheter diameter is about 10 pixels)
thrs_dev = 10; % (pixels) maximum deviation from the catheter (fitted curve) an identified point is allowed to be (wire envelopes are about 5 pixels outside of the catheter)
thrs_sm = 2; % (pixels)^2 threshold for removing identified bounding boxes that are too small
thrs_near = 5; % (pixel) minimal distance required to keep points (when removing overlaps)
pf_npt = 100; % polyfit-- the of points (parallel to the base of the catheter)

cath_len_pc = 0.9; % percentage of catheter length to include in ConvexHull search

%% pitch variation associated variables
bd_arr = [1.6564, 20.2525, 35.3308, 52.8649, 65.4128]; %  [64.4128];
fn_arr = {37:51,52:66,68:82,84:98,100:114}; % {115:134}; % 15 frames for each bending angle. The last 20 frames are with a phantom;

%% prepare video
if vidflag
    opengl('software');
    anim = VideoWriter('incl_pitch_pre','Motion JPEG AVI');
    anim.FrameRate = vidrate;
    open(anim);
end

cd C:\Users\yang\ownCloud\rennes_experiment\18_12_11-09_47_11-STD_18_12_11-09_47_11-STD-160410\__20181211_095212_765000

nn = 0;
n_fr = length(cell2mat(fn_arr));
I_arr = cell(n_fr,1);
r_arr = nan(n_fr,1);
p_arr = nan(n_fr,1);
b_arr = nan(n_fr,1);

%% load image
for dd = 1:length(bd_arr)
    
    fn = fn_arr{dd};
    bd = dd;
    bend = bd_arr(dd);
    
    %% preallocate
    X = nan(pf_npt,length(fn)); Y = X;
    REF = nan(2,length(fn));
    I_disp_arr = cell(length(fn),1);
    BBOX = I_disp_arr;
    TGL = I_disp_arr;
    
    for ff = 1:length(fn)
        
        disp([dd,ff]);
        
        %% load image and data
        dname = ['DSA_2_0' num2str(fn(ff),'%03.f')];
        cd(dname);
        fname = dir('*.ima');
        filename = fname.name;
        
        info = dicominfo(filename);
        [X0,cmap,alpha,overlays] = dicomread(filename);
        roll = info.PositionerPrimaryAngle;
        pitch = info.PositionerSecondaryAngle;
        cd ..
        
        %% sizing
        X3 = permute(X0,[1,2,4,3]);
        G = X3(:,:,1);
        for gg = 1:size(X3,3)
            G = imfuse(G,X3(:,:,gg));
        end
        H = G(plt_range(1):plt_range(2),plt_range(3):plt_range(4)); % extract the "global" area of interest
        
        %% Decide a reasonable y_min based on the three boxes at the bottom
        [x_mean,y_min_temp] = FindYLimit(H,A_thres,ref_pct_sch);    % find y-limit of view of interest based on the three reference boxes at the base
        
        %% identify the base of helix and translate image (I_str)
        x = x_mean-20; y = y_min_temp-60; w = 60; h = 50;           % define range within which to search for the reference
        ref_range = round([y,y+h,x,x+w]);                           % define range within which to search for the reference
        [a_mean,b_mean] = FindHelixBaseXY(H,ref_range,dbgflag);     % find helix base x- and y- positions
        a_diff = a_mean - ref_pt(2); b_diff = b_mean - ref_pt(1);   % calculate the x- and y- offset to translate the image by
        G = imtranslate(G,-[b_diff,a_diff]);                        % translate the image
        H = G(plt_range(1):plt_range(2),plt_range(3):plt_range(4)); % re-extract the "global" area of interest
        I_str = imadjust(H);                                        % re-stretch image
        
        %% Identify catheter shape and bounding box
        [~,x,y,p,S,mu,bbox_big] = IdentifyCatheter(I_str,y_min,pf_npt,dbgflag); % approximate catheter shape
        
        %% Retain regions surrounding the catheter main shape only
        I_cut = CutDistal(I_str,cath_len_pc,x,y,p,S,mu);            % truncate the tip of the catheter based on defined range
        temp = max(max(I_cut)); % calculate brightest pixel value
        I_cut(:,[1:bbox_big(1)-thrs_near,(thrs_near+bbox_big(1)+bbox_big(3)):end]) = temp;  % retain only area around the catheter
        I_cut([1:bbox_big(2)-thrs_near,(thrs_near+bbox_big(2)+bbox_big(4)):end],:) = temp;  % retain only area around the catheter
        
        %% Translate again (based on catheter polyfit results
        b_diff = y(end) - ref_pt(1); a_diff = x(end) - ref_pt(2);       % calcuate distance to translate
        x = x - a_diff; y = y - b_diff;                                 % offset catheter
        %         I = imtranslate(I_cut,-[b_diff,a_diff],'FillValues',1);         % translate the image
        I_disp = imtranslate(I_str,-[b_diff,a_diff],'FillValues',1);    % translate the image
        
        %% Find connected components
        pks = FindConnComp(I_cut,x,y,y_min,thrs_dev); % find peaks by bwconncomp
        xx1 = pks(:,2); yy1 = pks(:,1);
        
        %% ConvexHull regionprops (for convex back)-- divide into sections
        II = imbinarize(imsharpen(I_cut,'radius',2,'amount',10));
        n_div = 2; % number of boxes to divide the bounding box into
        BW = imcomplement(II);
        BW(y_min:end,:) = 0;
        [xx2,yy2] = FindConvexPeaks(BW,n_div,bbox_big,y_min-10);
        
        %% combine ConvexHulls and BoundingBoxes, clean up, and choose sides
        % left to the curve --> lower left corner / right to the curve --> upper right corner
        xx = [xx1;xx2]; yy = [yy1;yy2]; temp = [xx,yy];
        [xout,~] = polyval(p,yy,S,mu);
        tgl_side = (xout - xx) > 0;
        
        % remove overlaps
        tgl_near = RemoveOverlap([xx,yy],thrs_near);
        xx(~tgl_near) = []; yy(~tgl_near) = [];
        tgl_side(~tgl_near) = [];
        
        if pltflag
            imshow(I_str); hold on;
            hc = plot(y,x,'linewidth',lwd,'color',0.5*[1,1,1]);
            hr = plot(ref_pt(1),ref_pt(2),'.w','markersize',msize);
            plot(xx(tgl_side),yy(tgl_side),'.','color',c_lab_y,'markersize',msize);
            plot(xx(~tgl_side),yy(~tgl_side),'.','color',c_lab_b,'markersize',msize);
            
            text(10,50,{['\theta_{roll} = ' num2str(roll)];...
                ['\theta_{pitch} = ' num2str(pitch)];...
                ['\theta_{bend} = ' num2str(bend)]});
        end
        
        %% save frame
        if vidflag
            frame = getframe(gcf);
            writeVideo(anim,frame);
            clf;
        else
            pause(0.5);
        end
        
        
        %% store data
        % % %         X(:,ff) = x; Y(:,ff) = y;
        % % %         REF(:,ff) = ref_pt;
        % % %         I_disp_arr{ff} = I_disp;
        % % %         BBOX{ff} = [xx,yy];
        % % %         TGL{ff} = tgl_side;
        
        nn = nn + 1;
        I_arr{nn} = I_str;
        r_arr(nn) = roll;
        p_arr(nn) = pitch;
        b_arr(nn) = bend;
        
    end
    
end

%% save data
if savflag
    save incl_pitch_pre I_arr r_arr p_arr b_arr ref_pt;
    %         save(['proc_incl_pitch_pre_test_' num2str(dd)],'X','Y','REF','BBOX','TGL','ind_arr','I_disp_arr','th1_arr');
end

%% close video
if vidflag
    close(anim);
    close;
end

cd C:\Users\yang\ownCloud\MATLAB\rennes