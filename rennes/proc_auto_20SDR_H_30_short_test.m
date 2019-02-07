clear; ca; clc;

% display toggle
dbgflag = 0; % plot (dianostics)
savflag = 1; % save data (mat file)
pltflag = 1; % plot (for video)
vidflag = 1; % save video
vidrate = 10; % video frame rate

% figure parameters
c_arr = lines(6); c_lab_y = c_arr(3,:); c_lab_b = c_arr(6,:); % marker color label
msize = 8; % markersize
lwd = 2; % linewidth
ht = 800; % figure height (pixels)
txt_d = 30; % distance of labeling text from the edge (pixels)
txt_s = 14; % font size

% image processing parameters
ref_n_pts = 5; % number of points to average on each side when searching for the reference point
ref_pt = [375,520]; % specify the location of the reference point (i.e. the centroid of the helices at the base)
ref_range = [500,550,300,390]; % range within which to search for the reference
th1_range = [-75,75]; % range of "roll" rotations to include
plt_range = [201,850,251,800]; % range of pixels to plot ([x_0,x_end,y_0,y_end])
sharp_r = 1; % sharpening radius
sharp_a = 10; % sharpening amount
thrs_small = 100; % (pixels)^2 threshold for removing small objects (during arbitrary stage; helps remove tip positioning boxes)
thrs_big = 50; % (pixels)^2 threshold for removing oversized identified area (catheter diameter is about 10 pixels)
thrs_dev = 25; % (pixels) maximum deviation from the catheter (fitted curve) an identified point is allowed to be (wire envelopes are about 5 pixels outside of the catheter)
thrs_sm = 2; % (pixels)^2 threshold for removing identified bounding boxes that are too small
thrs_near = 5; % (pixel) minimum distance consecutive peaks have to be spread out by
y_min = ref_pt(2); % y_min = 510; % (pixels) vertical pixel location of the lowest interesting extracted features (to avoid inclusion of the catheter base holder)
sch_rm_pxl = 3; % (pixels) threshold for removing small object during helix base identification process
sch_d = 15; % (pixels) minimum number of pixels for two horizontally aligned points to be considered the helix base
pf_n = 3; % polyfit-- the order of equation(to find a curve best describing the catheter shape)
pf_rpt = 10; % polyfit-- the number of times to eliminate outliers (to eliminate noise)
pf_exc = 0.1; % polyfit-- the percentage of catheter distal (vertical) distance to exclude before polyfit
pf_npt = 100; % polyfit-- the of points (parallel to the base of the catheter)

%% load image

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'};

for dd = 1:length(dname_arr)
    
    dname = dname_arr{dd};
    cd C:\Users\yang\ownCloud\rennes_experiment\18_12_11-09_47_11-STD_18_12_11-09_47_11-STD-160410\__20181211_095212_765000
    cd(dname);
    
    fname = dir('*.ima');
    filename = fname.name;
    
    info = dicominfo(filename);
    [X0,cmap,alpha,overlays] = dicomread(filename);
    
    cd C:\Users\yang\ownCloud\MATLAB\rennes
    
    %% initialize video
    if vidflag
        opengl('software');
        anim = VideoWriter(['proc_auto_' dname],'Motion JPEG AVI');
        anim.FrameRate = vidrate;
        open(anim);
    end
    
    %% permute image array
    X3 = permute(X0,[1,2,4,3]); % 4D images information usually comprises of Height, Width, Color Plane, Frame Number (Color Plane is in the order Red, Green, Blue)
    
    %% find interesting frames
    th1_arr = info.PositionerPrimaryAngleIncrement;
    ind_arr = find(th1_arr > th1_range(1) & th1_arr < th1_range(2));
    
    %% preallocate
    X = nan(pf_npt,length(ind_arr)); Y = X;
    REF = nan(2,length(ind_arr));
    I_disp_arr = cell(length(ind_arr),1);
    BBOX = I_disp_arr;
    TGL = I_disp_arr;
    
    %% show image (all frames)
    for ff = 1:length(ind_arr)
        
        fn = ind_arr(ff);
        
        disp([dd,ff]);
        
        G = X3(:,:,fn); % load frame
        
        %% identify the base of helix and translate image (I_str)
        H = G(plt_range(1):plt_range(2),plt_range(3):plt_range(4)); % extract the "global" area of interest
        fr = stretchlim(H); % default: [0.01,0.99] % calculate stretch imits
        I_str_temp = imadjust(H,fr); % stretch image (contract adjusting)
        I_ref_sch = edge(I_str_temp); % identify edges
        I_ref_sch = bwareaopen(I_ref_sch,sch_rm_pxl); % remove small objects (smaller than 3 pixels)
        
        I_ref_sch = I_ref_sch(ref_range(1):ref_range(2),ref_range(3):ref_range(4)); % focus on the "reference" area of interest
        I_ref_sch = double(I_ref_sch); % convert into doubles
        
        [a_base,b_base] = FindLowestHelix(ref_range,I_ref_sch,sch_d); % identify the lowest pair of horizontal pixels that are at least "d" pixels apart
        a_base = a_base + ref_range(1); b_base = b_base + ref_range(3); % offset critical pixels to the gloabl area of interest
        a_mean = mean(a_base); b_mean = mean(b_base); % average critical pixels
        a_diff = a_mean - ref_pt(2); b_diff = b_mean - ref_pt(1); % calculate the x- and y- offset to translate the image by
        G = imtranslate(G,-[b_diff,a_diff]); % translate the image
        H = G(plt_range(1):plt_range(2),plt_range(3):plt_range(4)); % re-extract the "global" area of interest
        I_str = imadjust(H,fr); % re-stretch image
        
        if dbgflag
            subplot(1,2,1); hold on;
            imshow(I_str_temp); % show original "gloabl" area
            plot(b_base,a_base,'.r'); % plot critical points
            plot(b_mean,a_mean,'.w','markersize',msize,'linewidth',lwd); % plot calculated helix base
            plot(ref_pt(1),ref_pt(2),'.y','markersize',msize,'linewidth',lwd); % plot desired reference point
            title(fn);
            
            subplot(1,2,2); hold on;
            imshow(I_str); % show translated "gloabl" area
            plot(ref_pt(1),ref_pt(2),'.y','markersize',msize,'linewidth',lwd); % plot desired reference point
        end
        
        %% sharpening (I_shp)
        I_shp = imsharpen(I_str,'radius',sharp_r,'amount',sharp_a); % (default radius = 1; default amount = 0.8)
        
        if dbgflag
            figure;
            subplot(1,4,1);
            imshow(I_shp);
            title('sharpen');
        end
        
        %% distance transform (I_dtr)
        I_dtr = bwdist(I_shp);
        
        if dbgflag
            subplot(1,4,2);
            imshow(I_dtr);
            title('distance tranform');
        end
        
        %% remove smaller objects (I_rsm)
        I_rsm = bwareaopen(I_dtr,thrs_small);
        
        if dbgflag
            subplot(1,4,3);
            imshow(I_rsm);
            title('remove small objects');
        end
        
        %% identify catheter (BoundingBox)
        s = regionprops('table',I_rsm,'Area','BoundingBox','PixelIdxList','ConvexHull');
        BoundingBox = s.BoundingBox;
        PixelIdxList = s.PixelIdxList;
        [~,ind] = max(BoundingBox(:,4)); % find the tallest BoundingBox
        bbox_big = BoundingBox(ind,:);
        bbox_big = floor(bbox_big); % round down to the nearest pixel integer
        
        if dbgflag
            subplot(1,4,4);
            imshow(I_rsm);
            hold on;
            rectangle('Position',bbox_big,'edgecolor',c_lab_y,'linewidth',lwd);
            title('tallest bounding box');
            
        end
        
        %% retain bounding box of catheter only and binarize (I_shp_ctol)
        tgl = zeros(size(I_dtr));
        tgl(bbox_big(2):bbox_big(2)+bbox_big(4),bbox_big(1):bbox_big(1)+bbox_big(3)) = 1;
        
        level = graythresh(I_shp(bbox_big(2):bbox_big(2)+bbox_big(4),bbox_big(1):bbox_big(1)+bbox_big(3)));
        I_ctol = imbinarize(I_shp,level);
        I_ctol(~tgl) = 1;
        
        if dbgflag
            figure;
            imshow(I_ctol,[]); hold on;
            title('exclude outside (from sharpen) and binarize');
        end
        
        %% identify catheter main shape
        I_ctol_inv = imcomplement(I_ctol);
        I_ctol_inv(y_min:end,:) = 0;
        
        s = regionprops('table',I_ctol_inv,'BoundingBox');
        BoundingBox = s.BoundingBox;
        [~,ind] = max(BoundingBox(:,4)); % find the tallest BoundingBox
        BoundingBox = BoundingBox(ind,:);
        bbox_big = floor(BoundingBox); % round down to the nearest pixel integer
        
        [fa,fb] = find(I_ctol_inv==1);
        [p,S,mu] = PolyfitCatheter(fa,fb,pf_n,pf_rpt,pf_exc); % find the best polynomial fit describing the catheter shape
        x = linspace(min(fa),max(fa),pf_npt);
        [y,~] = polyval(p,x,S,mu);
        
        if dbgflag
            imshow(I_ctol,[]); hold on;
            rectangle('position',BoundingBox,'edgecolor',c_lab_y,'linewidth',lwd);
        end
        
        %% translate image again (based on catheter polyfit results
        b_diff = y(end) - ref_pt(1); a_diff = x(end) - ref_pt(2);
        I_ctol = imtranslate(I_ctol,-[b_diff,a_diff],'FillValues',1); % translate the image
        x = x - a_diff; y = y - b_diff;
        
        % change image parameters for display
        I_temp = imadjust(I_str,[0,level*2]);
        I_disp = imtranslate(I_temp,-[b_diff,a_diff],'FillValues',max(max(I_temp)));
        
        %% BoundingBox regionprops(for convex front)
        
        % BoundingBox
        s = regionprops('table',I_ctol,'Centroid','BoundingBox','Area','FilledImage','MajorAxisLength','MinorAxisLength','Orientation');
        Centroid = s.Centroid;
        Area = s.Area;
        BoundingBox = s.BoundingBox;
        %         FilledImage = s.FilledImage;
        MajorAxisLength = s.MajorAxisLength;
        MinorAxisLength = s.MinorAxisLength;
        Orientation = s.Orientation;
        
        % Exclude big boxes, small boxes, and low centroids
        tgl_exc = zeros(size(Centroid,1),1);
        tgl_exc(Area > thrs_big) = 1; % remove boxes much bigger than an "envelope" size
        tgl_exc(Area < thrs_sm) = 1; % remove boxes smaller than a pixel
        tgl_exc(Centroid(:,2) > y_min - thrs_dev) = 1; % remove boxes below reference point
        
        Area(logical(tgl_exc),:) = [];
        BoundingBox(logical(tgl_exc),:) = [];
        Centroid(logical(tgl_exc),:) = [];
        %         FilledImage(logical(tgl_exc)) = [];
        MajorAxisLength(logical(tgl_exc)) = [];
        MinorAxisLength(logical(tgl_exc)) = [];
        Orientation(logical(tgl_exc)) = [];
        
        %         tgl_exc = zeros(size(Centroid,1),1); % remove boxes that are too close together
        %         temp = diff(Centroid).^2; temp = sqrt(temp(:,1) + temp(:,2)); % remove boxes that are too close together
        %         tgl_exc(temp < thrs_near) = 1; % remove boxes that are too close together
        
        bbox_plt = FindBoundingBoxPeaks(BoundingBox,Centroid,MajorAxisLength,MinorAxisLength,Orientation,x,y);
        xx0 = bbox_plt(:,1); yy0 = bbox_plt(:,2);
        
        %% ConvexHull regionprops (for convex back)-- divide into sections
        n_div = 1; % number of boxes to divide the bounding box into
        BW = imcomplement(I_ctol);
        BW(y_min:end,:) = 0;
        [xx1,yy1] = FindConvexPeaks(BW,n_div,bbox_big,y_min-10);
        
        temp = sqrt(diff(yy1).^2 + diff(xx1).^2);
        xx1(temp < thrs_near) = [];
        yy1(temp < thrs_near) = [];
        xx1([1,2,end-1,end]) = []; yy1([1,2,end-1,end]) = []; %%%%%%%%%%%%%%%
        
        %% clean up and choose sides
        
        % Evaluate distance between points and fitted curve
        % left to the curve --> lower left corner / right to the curve --> upper right corner
        xx = [xx0;xx1]; yy = [yy0;yy1]; temp = [xx,yy];
        [xout,~] = polyval(p,yy,S,mu);
        tgl_corner = (xout - xx) > 0;
        
        % remove outliers (deviated from the curve)
        tgl_outlier = abs(xout - xx) > thrs_dev;
        xx(tgl_outlier) = []; yy(tgl_outlier) = []; tgl_corner(tgl_outlier) = [];
        
        %% plot
        if pltflag
            wd = size(I_str,2)*ht/size(I_str,1);
            set(gcf,'position',[1000,200,wd,ht]);
            set(gca,'position',[0.01,0.01,.99,.99]);
            
            imshow(I_disp); hold on;
            
            plot(y,x,'--','linewidth',lwd,'color',0.5*[1,1,1]);
            plot(xx(tgl_corner),yy(tgl_corner),'.','color',c_lab_y,'markersize',msize*2);
            plot(xx(~tgl_corner),yy(~tgl_corner),'.','color',c_lab_b,'markersize',msize*2);
            plot(ref_pt(1),ref_pt(2),'.w','markersize',msize*2);
            text(txt_d,size(I_str,1)-txt_d,['\theta_{roll} = ' num2str(th1_arr(ff))],'fontsize',txt_s);
        end
        
        %% ConvexHull regionprops (for convex front)-- divide into sections
        % % %         temp = size(BW);
        % % %         x_px = repmat((1:temp(1))',1,temp(2));
        % % %         y_px = repmat(1:temp(2),temp(1),1);
        % % %
        % % %         % Evaluate distance between points and fitted curve
        % % %         [yyy,delta] = polyval(p,x_px,S,mu);
        % % %
        % % %         % left to the curve --> lower left corner / right to the curve --> upper right corner
        % % %         tgl_right = (yyy - y_px) < 0;
        % % %         BW(tgl_right) = 0;
        % % %         BW = imcomplement(BW);
        % % %         [xx2,yy2] = FindConvexPeaks(BW,n_div,bbox_big,y_min);
        % % %
        %% store data
        X(:,ff) = x; Y(:,ff) = y;
        REF(:,ff) = ref_pt;
        I_disp_arr{ff} = I_disp;
        BBOX{ff} = [xx,yy];
        TGL{ff} = tgl_corner;
        
        
        %% save frame
        if vidflag
            frame = getframe(gcf);
            writeVideo(anim,frame);
            clf;
        end
    end
    
    %% save data
    if savflag
        save(['proc_auto_data_' dname],'X','Y','REF','BBOX','TGL','ind_arr','I_disp_arr','th1_arr');
    end
    
    %% close video
    if vidflag
        close(anim);
        close;
    end
    
end