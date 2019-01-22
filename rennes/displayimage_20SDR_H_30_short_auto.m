clear; ca; clc;

% display toggle
pltflag = 0; % plot (dianostics)
vidflag = 1; % save video
vidrate = 20; % video frame rate

% figure parameters
c_arr = lines(5); c_lab_1 = c_arr(2,:); c_lab_2 = c_arr(1,:); % marker color label
msize = 5; % markersize
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
thrs_dev = 10; % (pixels) maximum deviation from the catheter (fitted curve) an identified point is allowed to be (wire envelopes are about 5 pixels outside of the catheter)
y_min = 510; % (pixels) vertical pixel location of the lowest interesting extracted features (to avoid inclusion of the catheter base holder)

%% load image

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %

for dd = 5%1:length(dname_arr)
    
    dname = dname_arr{dd};
    cd C:\Users\yang\ownCloud\rennes_experiment\18_12_11-09_47_11-STD_18_12_11-09_47_11-STD-160410\__20181211_095212_765000
    cd(dname);
    
    fname = dir('*.ima');
    filename = fname.name;
    
    info = dicominfo(filename);
    [X,cmap,alpha,overlays] = dicomread(filename);
    
    cd C:\Users\yang\ownCloud\MATLAB\rennes
    
    %% initialize video
    if vidflag
        opengl('software');
        anim = VideoWriter([dname '_proc_auto'],'Motion JPEG AVI');
        anim.FrameRate = vidrate;
        open(anim);
    end
    
    %% permute image array
    X3 = permute(X,[1,2,4,3]); % 4D images information usually comprises of Height, Width, Color Plane, Frame Number (Color Plane is in the order Red, Green, Blue)
    
    %% find interesting frames
    th1_arr = info.PositionerPrimaryAngleIncrement;
    ind_arr = find(th1_arr > th1_range(1) & th1_arr < th1_range(2));
    
    %% show image (all frames)
    
    for ff = ind_arr(1):ind_arr(end)
        
        clear G H I_str_temp test test1 a b mat n ind *_avg *_diff ind_temp
        % select frame
        G = X3(:,:,ff);
        
        %% Find the base of the helical marker (closed coils)
        H = G(plt_range(1):plt_range(2),plt_range(3):plt_range(4));
        fr = stretchlim(H); % default: [0.01,0.99]
        I_str_temp = imadjust(H,fr);
        test2 = edge(I_str_temp);
        
        %         test = I_str_temp;
        %         test1 = test(ref_range(1):ref_range(2),ref_range(3):ref_range(4));
        test2 = test2(ref_range(1):ref_range(2),ref_range(3):ref_range(4));
        test2 = double(test2);
        
        [a,b] = find(test2==1);
        temp = [a,b];
        temp = sortrows(temp);
        n = size(temp,1);
        ind_temp = [1:5,n-4:n];
        
        a_mean = mean(a(ind_temp)) + ref_range(1); b_mean = mean(b(ind_temp)) + ref_range(3);
        a_diff = a_mean - ref_pt(2); b_diff = b_mean - ref_pt(1);
        
        G = imtranslate(G,-[b_diff,a_diff]);
        H = G(plt_range(1):plt_range(2),plt_range(3):plt_range(4));
        I_str = imadjust(H,fr);
        
        % % % %         subplot(1,2,1);
        % % %         imshow(I_str_temp);
        % % %         hold on;
        % % %         plot(b_mean,a_mean,'*y','markersize',msize,'linewidth',lwd);
        % % %         plot(ref_pt(1),ref_pt(2),'or','markersize',msize,'linewidth',lwd);
        
        %         subplot(1,2,2);
        imshow(I_str); hold on;
        plot(ref_pt(1),ref_pt(2),'or','markersize',msize,'linewidth',lwd);
        %         set(gcf,'position',[1,41,2560,1327]);
        
        %% contrast stretching (I_str)
        fr = stretchlim(H); % default: [0.01,0.99]
        I_str = imadjust(H,fr);
        
        if pltflag
            figure;
            imshow(I_str);
            title('contrast strecthing');
        end
        
        %% sharpening (I_shp)
        I_shp = imsharpen(I_str,'radius',sharp_r,'amount',sharp_a); % (default radius = 1; default amount = 0.8)
        
        if pltflag
            figure;
            imshow(I_shp);
            title('sharpen');
        end
        
        %% distance transform (I_dtr)
        I_dtr = bwdist(I_shp);
        
        if pltflag
            figure;
            imshow(I_dtr);
            title('distance tranform');
        end
        
        %% remove smaller objects (I_rsm)
        P = thrs_small;
        I_rsm = bwareaopen(I_dtr,P);
        if pltflag
            figure;
            imshow(I_rsm);
            title('remove small objects');
        end
        
        %% identify catheter
        % find the area with maximum height
        s = regionprops('table',I_rsm,'Area','BoundingBox','PixelIdxList','ConvexHull');
        BoundingBox = s.BoundingBox;
        PixelIdxList = s.PixelIdxList;
        [~,ind] = max(BoundingBox(:,4));
        bbox_big = BoundingBox(ind,:);
        bbox_big= floor(bbox_big); % round to the nearest pixel integer
        
        if pltflag
            figure;
            imshow(I_rsm);
            hold on;
            rectangle('Position',bbox_big,'edgecolor',c_lab_1,'linewidth',lwd);
            title('tallest bounding box');
            
            for ii = 1:size(BoundingBox,1)
                hold on; rectangle('Position',BoundingBox(ii,:),'facecolor','none','edgecolor',c_lab_1,'linewidth',lwd);
            end
        end
        
        %% exclude smaller boxes (I_exsb)
        %         bbox_rest = BoundingBox; bbox_rest(ind,:) = [];
        %         tgl = zeros(size(I_rsm));
        %         for bb = 1:size(bbox_rest,1)
        %             temp = bbox_rest(bb,:);
        %             bxlim = round(temp); % round to the nearest pixel integer
        %             tgl(bxlim(2):bxlim(2)+bxlim(4),bxlim(1):bxlim(1)+bxlim(3)) = 1;
        %         end
        %         tgl = logical(tgl);
        %         I_exsb = I_dtr;
        %         I_exsb(tgl) = 0; % turn irrelevant area in original image black
        %
        %         if pltflag
        %             figure;
        %             imshow(I_exsb);
        %             hold on;
        %             title('exclude small boxes');
        %         end
        
        %% retain bounding box of catheter only (I_ctol) and binarize
        tgl = zeros(size(I_dtr));
        tgl(bbox_big(2):bbox_big(2)+bbox_big(4),bbox_big(1):bbox_big(1)+bbox_big(3)) = 1;
        
        L = I_shp;
        level = graythresh(L(bbox_big(2):bbox_big(2)+bbox_big(4),bbox_big(1):bbox_big(1)+bbox_big(3)));
        I_ctol = imbinarize(L,level);
        I_ctol(~tgl) = 1;
        
        if pltflag
            figure;
            imshow(I_ctol,[]);
            title('exclude outside (from sharpen) and binarize');
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% ConvexHull regionprops (for convex back)-- divide into sections
        %% i don't think this works :((((((
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % %         n_div = 5;
        % % %         BW = imcomplement(I_ctol);
        % % %         BW(y_min:end,:) = 0;
        % % %
        % % %         wd = size(I_str,2)*ht/size(I_str,1);
        % % %         set(gcf,'position',[1000,200,wd,ht]);
        % % %         set(gca,'position',[0.01,0.01,.99,.99]);
        % % % %         imshow(I_shp); hold on;
        % % %
        % % %         for dd = 1:n_div
        % % %
        % % %             BW_temp = BW;
        % % %
        % % %             bbox = bbox_big;
        % % %             bbox(4) = (y_min-bbox(2))/n_div;
        % % %             bbox(2) = bbox(2) + (dd-1)*bbox(4);
        % % %             bbox = floor(bbox);
        % % % %             rectangle('position',bbox,'edgecolor',c_lab_1);
        % % %
        % % %             tgl = zeros(size(BW));
        % % %             tgl(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3)) = 1;
        % % %             BW_temp(~tgl) = 0;
        % % %
        % % %             s = regionprops('table',BW_temp,'ConvexHull','ConvexArea');
        % % %             ConvexHull = s.ConvexHull;
        % % %             ConvexArea = s.ConvexArea;
        % % %             [~,ind] = max(ConvexArea);
        % % %             ConvexHull = ConvexHull{ind};
        % % %
        % % %             xx2 = ConvexHull(:,1); yy2 = ConvexHull(:,2);
        % % %
        % % % %             plot(xx2,yy2,'*-','linewidth',lwd,'color',c_lab_2,'markersize',msize);
        % % %             clear ConvexHull BW_temp
        % % %         end
        % % %
        % % % %         plot(a_avg,b_avg,'*','markersize',msize,'color','y','linewidth',lwd);
        % % %
        
        
        
        
        
        %% ConvexHull regionprops (for convex back)
        % % %         BW = imcomplement(I_ctol);
        % % %         BW(y_min:end,:) = 0;
        % % %         s = regionprops('table',BW,'ConvexHull','ConvexArea');
        % % %         ConvexHull = s.ConvexHull;
        % % %         ConvexArea = s.ConvexArea;
        % % %         [~,ind] = max(ConvexArea);
        % % %         ConvexHull = ConvexHull{ind};
        % % %
        % % %         xx2 = ConvexHull(:,1); yy2 = ConvexHull(:,2);
        % % %
        % % %         % remove points that don't qualify
        % % %         tgl_2 = false(1,length(xx2));
        % % %         tgl_2(abs(yy2-y_min) < 5) = 1; % points that are at the bottom of the selected region
        % % %         temp = sqrt((xx2-xx2(1)).^2 + (yy2-yy2(1)).^2);
        % % %         tgl_2(abs(temp) < 18) = 1; % points that are too close to the first point (upper left)
        % % %         temp = sqrt(diff(xx2).^2+diff(yy2).^2);
        % % %         tgl_2(abs(temp)<1) = 2; % points that are too close to each other
        % % %         xx2(tgl_2) = []; yy2(tgl_2) = [];
        
        %% BoundingBox regionprops(for convex front)
        
        % % %         % BoundingBox
        % % %         cc = bwconncomp(I_shp,4); %  returns the connected components CC found in the binary image BW % 4 is the specification of connectivity
        % % %         s = regionprops('table',cc,'Centroid','BoundingBox','Area');
        % % %         Centroid = s.Centroid;
        % % %         Area = s.Area;
        % % %         BoundingBox = s.BoundingBox;
        % % %
        % % %         % Exclude big boxes, low centroids, and outliers from the catheter
        % % %         tgl_exc = zeros(size(Centroid,1),1);
        % % %         tgl_exc(Area > thrs_big) = 1; % remove identified boxes that are much bigger than an "envelope" size
        % % %         tgl_exc(Centroid(:,2) > y_min) = 1;
        % % %         BoundingBox(logical(tgl_exc),:) = [];
        % % %         Centroid(logical(tgl_exc),:) = [];
        % % %
        % % %         xx1 = Centroid(:,1); yy1 = Centroid(:,2);
        
        %% main plot
        % figure sizing
        % %         wd = size(I_str,2)*ht/size(I_str,1);
        % %         set(gcf,'position',[1000,200,wd,ht]);
        % %         set(gca,'position',[0.01,0.01,.99,.99]);
        % %
        % %         I_disp = imadjust(I_str,[0,level*2]);
        % %         imshow(I_disp);
        % %         hold on;
        % %         %         plot(xx1,yy1,'*','linewidth',lwd,'color',c_lab_1,'markersize',msize);
        % %         plot(xx2,yy2,'*-','linewidth',lwd,'color',c_lab_2,'markersize',msize);
        % %
        % %         text(txt_d,size(I_str,1)-txt_d,['\theta_{roll} = ' num2str(th1_arr(ff))],'fontsize',txt_s);
        
        %% save frame
        if vidflag
            frame = getframe(gcf);
            writeVideo(anim,frame);
            clf;
        else
            pause(1);
        end
    end
    
    %% close video
    if vidflag
        close(anim);
        close;
    end
    
end