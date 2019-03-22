clear; ca; clc;

% display toggle
dbgflag = 0; % plot (dianostics)
savflag = 0; % save data (mat file)
pltflag = 1; % plot (for video)
vidflag = 1; % save video
vidrate = 4; % video frame rate

% figure parameters
c_arr = lines(6); c_lab_y = c_arr(3,:); c_lab_b = c_arr(6,:); % marker color label
msize = 12; % markersize
lwd = 2; % linewidth
ht = 800; % figure height (pixels)
txt_d = 30; % distance of labeling text from the edge (pixels)
txt_s = 14; % font size

% image processing parameters
A_thres = 500; % minimum area to qualify as a candidate when searching for the three boxes at the bottom of the image
ref_n_pts = 5; % number of points to average on each side when searching for the reference point
ref_pt = [375,520]; % specify the location of the reference point (i.e. the centroid of the helices at the base)
% th1_range = [-75,75]; % range of "roll" rotations to include
plt_range = [201,850,251,800]; % range of pixels to plot ([x_0,x_end,y_0,y_end])
y_min = ref_pt(2); % y position for reference point

thrs_big = 50; % (pixels)^2 threshold for removing oversized identified area (catheter diameter is about 10 pixels)
thrs_dev = 25; % (pixels) maximum deviation from the catheter (fitted curve) an identified point is allowed to be (wire envelopes are about 5 pixels outside of the catheter)
thrs_sm = 2; % (pixels)^2 threshold for removing identified bounding boxes that are too small
thrs_near = 5; % (pixel) minimal distance required to keep points (when removing overlaps)
pf_npt = 100; % polyfit-- the of points (parallel to the base of the catheter)

cath_len_pc = 0.9; % percentage of catheter length to include in ConvexHull search

%% pitch variation associated variables
bd_arr = [1.6564, 20.2525, 35.3308, 52.8649, 65.4128]; %  [64.4128];
fn_arr = {37:51,52:66,68:82,84:98,100:114}; % {115:134}; % 15 frames for each bending angle. The last 20 frames are with a phantom;
ii = 2; % index to pitch from the third dimension of the .ima file

%% prepare video
if vidflag
    opengl('software');
    anim = VideoWriter('incl_pitch_pre','Motion JPEG AVI');
    anim.FrameRate = vidrate;
    open(anim);
end

cd C:\Users\yang\ownCloud\rennes_experiment\18_12_11-09_47_11-STD_18_12_11-09_47_11-STD-160410\__20181211_095212_765000

%% load image
for dd = 1:length(bd_arr)
    
    fn = fn_arr{dd};
    bd = dd;
    
    %% preallocate
    X = nan(pf_npt,length(fn)); Y = X;
    REF = nan(2,length(fn));
    I_disp_arr = cell(length(fn),1);
    BBOX = I_disp_arr;
    TGL = I_disp_arr;
    
    for ff = 1:length(fn)
        
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
        I = imadjust(H);
                
        %% Decide a reasonable y_min based on the three boxes at the bottom
        pct_sch = 0.5; % percentage (from the bottom) of vertical dimension to search 
        [x_mean,y_min_temp] = FindYLimit(H,A_thres,pct_sch);
        
        %% identify the base of helix and translate image (I_str)
        x = x_mean-20; y = y_min_temp-60; w = 60; h = 50;
        ref_range = round([y,y+h,x,x+w]); % range within which to search for the reference
        [a_mean,b_mean] = FindHelixBaseXY(H,ref_range,dbgflag); % find helix base x- and y- positions        
        a_diff = a_mean - ref_pt(2); b_diff = b_mean - ref_pt(1); % calculate the x- and y- offset to translate the image by        
        G = imtranslate(G,-[b_diff,a_diff]); % translate the image
        H = G(plt_range(1):plt_range(2),plt_range(3):plt_range(4)); % re-extract the "global" area of interest        
        I_str = imadjust(H); % re-stretch image
        
        %% Identify catheter shape and bounding box
        [I_ctol,x,y,p,S,mu,bbox_big] = IdentifyCatheter(I_str,y_min,pf_npt,dbgflag);
        
        %% Retain regions surrounding the catheter main shape only
        I_ctol = CutDistal(I_ctol,cath_len_pc,x,y,p,S,mu);
        temp = max(max(I_ctol));
        I_ctol(:,[1:bbox_big(1)-thrs_near,(thrs_near+bbox_big(1)+bbox_big(3)):end]) = temp;
        I_ctol([1:bbox_big(2)-thrs_near,(thrs_near+bbox_big(2)+bbox_big(4)):end],:) = temp;
        
        %% translate image again (based on catheter polyfit results
        b_diff = y(end) - ref_pt(1); a_diff = x(end) - ref_pt(2);
        I_ctol = imtranslate(I_ctol,-[b_diff,a_diff],'FillValues',1); % translate the image
        x = x - a_diff; y = y - b_diff;
        I_disp = imtranslate(I_str,-[b_diff,a_diff],'FillValues',max(max(I_str))); % change image parameters for display
        
        %% BWconncomp
        CC = bwconncomp(I_ctol,4); % this searches for the 4-connected components, which regionprops misses
        Area = nan(1,CC.NumObjects);
        for cc = 1:CC.NumObjects
            Area(cc) = length(CC.PixelIdxList{cc});
        end
        ind_exc = find(Area > thrs_big); % remove boxes much bigger than an "envelope" size
        nobj = CC.NumObjects - length(ind_exc);
        pixidlist = CC.PixelIdxList; pixidlist(ind_exc) = [];
        
        pk = nan(nobj,2);
        
        % find furthest point
        for cc = 1:nobj
            temp = pixidlist{cc};
            [temp1,temp2] = ind2sub(CC.ImageSize,temp);
            Idx = knnsearch([x;y]',[temp1,temp2]);
            Y = rssq([temp1,temp2]' - [x(Idx);y(Idx)]);
            [~,ind] = max(Y);
            pk(cc,:) = [temp1(ind),temp2(ind)];
        end
        
        imshow(I_disp); hold on;
        plot(pk(:,2),pk(:,1),'x','color',c_lab_y,'linewidth',2);
        
        tgl_exc = pk(:,1) > y_min - thrs_dev/2; % exclude those below y limit
        
        pk(tgl_exc,:) = [];
        
        plot(y,x,'w','linewidth',1);
        plot(pk(:,2),pk(:,1),'x','color',c_lab_b,'linewidth',2);
                
        %% BoundingBox regionprops(for convex front)
        
% % %         % BoundingBox
% % %         s = regionprops('table',I_ctol,'Centroid','BoundingBox','Area','FilledImage','MajorAxisLength','MinorAxisLength','Orientation');
% % %         Centroid = s.Centroid;
% % %         Area = s.Area;
% % %         BoundingBox = s.BoundingBox;
% % %         MajorAxisLength = s.MajorAxisLength;
% % %         MinorAxisLength = s.MinorAxisLength;
% % %         Orientation = s.Orientation;
% % %         
% % %         % Exclude big boxes, small boxes, and low centroids
% % %         tgl_exc = zeros(size(Centroid,1),1);
% % %         tgl_exc(Area > thrs_big) = 1; % remove boxes much bigger than an "envelope" size
% % % % %         tgl_exc(Area < thrs_sm) = 1; % remove boxes smaller than a pixel
% % %         tgl_exc(Centroid(:,2) > y_min - thrs_dev) = 1; % remove boxes below reference point
% % %         
% % %         Area(logical(tgl_exc),:) = [];
% % %         BoundingBox(logical(tgl_exc),:) = [];
% % %         Centroid(logical(tgl_exc),:) = [];
% % %         MajorAxisLength(logical(tgl_exc)) = [];
% % %         MinorAxisLength(logical(tgl_exc)) = [];
% % %         Orientation(logical(tgl_exc)) = [];
% % %         
% % %         bbox_plt = FindBoundingBoxPeaks(BoundingBox,Centroid,MajorAxisLength,MinorAxisLength,Orientation,x,y);
% % %         xx0 = bbox_plt(:,1); yy0 = bbox_plt(:,2);
        
% % %         %% ConvexHull regionprops (for convex back)-- divide into sections
% % %         n_div = 1; % number of boxes to divide the bounding box into
% % %         BW = imcomplement(I_ctol);
% % %         BW(y_min:end,:) = 0;
% % %         [xx1,yy1] = FindConvexPeaks(BW,n_div,bbox_big,y_min-10);
% % %         
% % %         if ~isempty(xx1)
% % %             % remove points too close together (usually happening along the edges)
% % %             temp = rssq([diff(xx1),diff(yy1)]');
% % %             xx1(temp < thrs_near) = [];
% % %             yy1(temp < thrs_near) = [];
% % %             
% % %             % keep only points on the right
% % %             [xout,~] = polyval(p,yy1,S,mu);
% % %             tgl_hull = (xout - xx1) > 0;
% % %             xx1(tgl_hull) = [];
% % %             yy1(tgl_hull) = [];
% % %             if length(xx1) > 2
% % %                 xx1(1) = []; xx1(end) = [];
% % %                 yy1(1) = []; yy1(end) = [];
% % %             end
% % %         end
% % %         
% % %         %% combine ConvexHulls and BoundingBoxes, clean up, and choose sides
% % %         % left to the curve --> lower left corner / right to the curve --> upper right corner
% % %         xx = [xx0;xx1]; yy = [yy0;yy1]; temp = [xx,yy];
% % %         [xout,~] = polyval(p,yy,S,mu);
% % %         tgl_side = (xout - xx) > 0;
% % %         
% % %         % remove outliers (deviated from the curve)
% % %         tgl_outlier = abs(xout - xx) > thrs_dev;
% % %         xx(tgl_outlier) = []; yy(tgl_outlier) = []; tgl_side(tgl_outlier) = [];
% % %         
% % %         % remove overlaps
% % %         tgl_near = RemoveOverlap([xx,yy],thrs_near);
% % %         xx(~tgl_near) = []; yy(~tgl_near) = [];
% % %         tgl_side(~tgl_near) = [];
% % %         
% % %         %% plot
% % %         if pltflag
% % %             wd = size(I_str,2)*ht/size(I_str,1);
% % %             set(gcf,'position',[1000,200,wd,ht]);
% % %             set(gca,'position',[0.01,0.01,.99,.99]);
% % %             
% % %             imshow(I_disp);
% % %             hold on;
% % %             
% % %             hc = plot(y,x,'--','linewidth',lwd,'color',0.5*[1,1,1]);
% % %             h1 = plot(xx(tgl_side),yy(tgl_side),'.','color',c_lab_y,'markersize',msize*2);
% % %             h2 = plot(xx(~tgl_side),yy(~tgl_side),'.','color',c_lab_b,'markersize',msize*2);
% % %             hr = plot(ref_pt(1),ref_pt(2),'ok','markerfacecolor','w','markersize',msize/2);
% % %             %             text(txt_d,size(I_str,1)-txt_d,['\theta_{roll} = ' num2str(th1_arr(fn))],'fontsize',txt_s); % th1_arr : roll angle of this frame (deg)
% % %             text(10,10,[num2str(dd) ', ' num2str(ff)]);
% % %         end
% % %         
% % %         %% ConvexHull regionprops (for convex front)-- divide into sections
% % %         % % %         temp = size(BW);
% % %         % % %         x_px = repmat((1:temp(1))',1,temp(2));
% % %         % % %         y_px = repmat(1:temp(2),temp(1),1);
% % %         % % %
% % %         % % %         % Evaluate distance between points and fitted curve
% % %         % % %         [yyy,delta] = polyval(p,x_px,S,mu);
% % %         % % %
% % %         % % %         % left to the curve --> lower left corner / right to the curve --> upper right corner
% % %         % % %         tgl_right = (yyy - y_px) < 0;
% % %         % % %         BW(tgl_right) = 0;
% % %         % % %         BW = imcomplement(BW);
% % %         % % %         [xx2,yy2] = FindConvexPeaks(BW,n_div,bbox_big,y_min);
% % %         % % %
% % %         %% store data
% % %         X(:,ff) = x; Y(:,ff) = y;
% % %         REF(:,ff) = ref_pt;
% % %         I_disp_arr{ff} = I_disp;
% % %         BBOX{ff} = [xx,yy];
% % %         TGL{ff} = tgl_side;
        
        %% save frame
        if vidflag
            frame = getframe(gcf);
            writeVideo(anim,frame);
            clf;
        else
            pause(0.5);
        end
    end
    
    %% save data
    if savflag
        save(['proc_incl_pitch_pre_test_' num2str(dd)],'X','Y','REF','BBOX','TGL','ind_arr','I_disp_arr','th1_arr');
    end
    
end

%% close video
if vidflag
    close(anim);
    close;
end

cd C:\Users\yang\ownCloud\MATLAB\rennes