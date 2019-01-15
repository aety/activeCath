clear; ca; clc;

flg_plot = 0;

vidflag = 1;

c_arr = lines(3); clab = c_arr(3,:); % marker color label
msize = 5;

%% load image

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'};

for dd = 1:length(dname_arr)
    
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
        anim.FrameRate = 10;
        open(anim);
    end
    
    %% permute image array
    X3 = permute(X,[1,2,4,3]); % 4D images information usually comprises of Height, Width, Color Plane, Frame Number (Color Plane is in the order Red, Green, Blue)
    
    %% find interesting frames
    th1_bound = [-75,65];
    th1_arr = info.PositionerPrimaryAngleIncrement;
    ind_arr = find(th1_arr > th1_bound(1) & th1_arr < th1_bound(2));
    
    %% show image (all frames)
    
    for ff = ind_arr(1):ind_arr(end)
        
        % select frame
        H = X3(:,:,ff);
        H = H(201:850,251:800);
        
        %% contrast stretching and sharpening
        n = 256;
        fr = stretchlim(H); % default: [0.01,0.99]
        I = imadjust(H,fr);
        
        if flg_plot
            figure;
            imshow(I);
            title('contrast strecthing');
        end
        
        J = imsharpen(I,'radius',3,'amount',3); % (default radius = 1; default amount = 0.8)
        
        if flg_plot
            figure;
            imshow(J);
            title('sharpen');
        end
        
        %% distance transform
        K = bwdist(J);
        
        if flg_plot
            figure;
            imshow(K);
            title('distance tranform');
        end
        
        %% erode
        % % %     SE = strel('rectangle',[50,2]);
        % % %     K = imerode(K,SE);
        % % %
        % % %     if flg_plot
        % % %         figure;
        % % %         imshow(K);
        % % %         title('eroded');
        % % %     end
        
        %% remove smaller objects
        % %     P = 2;
        % %     L = bwareaopen(K,P);
        % %     if flg_plot
        % %         figure;
        % %         imshow(L);
        % %         title('bwareaopen');
        % %     end
        
        %% identify catheter
        
        % find the area with maximum height
        s = regionprops('table',K,'Area','BoundingBox','PixelIdxList');
        BoundingBox = s.BoundingBox;
        PixelIdxList = s.PixelIdxList;
        [~,ind] = max(BoundingBox(:,4));
        temp = BoundingBox(ind,:);
        axlim = round([temp(1),temp(2),temp(3),temp(4)]); % round to the nearest pixel integer
        
        if flg_plot
            figure;
            imshow(K);
            hold on;
            rectangle('Position',axlim,'edgecolor',clab,'linewidth',2);
            title('tallest bounding box');
        end
        
        %% exclude pixels outside of the catheter bounding box
        tgl = zeros(size(K));
        tgl(axlim(2):axlim(2)+axlim(4),axlim(1):axlim(1)+axlim(3)) = 1;
        L = J;
        L(~tgl) = 0; % turn irrelevant area in original image black
        
        level = graythresh(L);
        M = imbinarize(L,level);
        
        if flg_plot
            figure;
            imshow(M);
            title('exclude outside');
        end
        
        %% edge detection
        % % %     %'Sobel' (default) | 'Prewitt' | 'Roberts' | 'log' | 'zerocross' | 'Canny' | 'approxcanny'
        % % %     method = 'Sobel';
        % % %     BW = edge(K,method);
        % % %     figure; imshow(BW);
        
        %% regionprops
        
        % BoundingBox
        cc = bwconncomp(M,4); %  returns the connected components CC found in the binary image BW
        s = regionprops('table',cc,'Centroid','BoundingBox','Area');
        Centroid = s.Centroid;
        Area = s.Area;
        BoundingBox = s.BoundingBox;
        
        Centroid(Area>10,:) = [];
        BoundingBox(Area>10,:) = [];
        
        % plot only centroid of those areas
        %     temp = Centroid;
        %     hold on; plot(temp(:,1),temp(:,2),'o','markersize',msize,'markerfacecolor',clab,'markeredgecolor',clab);
        
        % plot full areas
        figure(1);
        imshow(I);
        for ii = 1:size(BoundingBox,1)
            hold on; rectangle('Position',BoundingBox(ii,:),'facecolor','none','edgecolor',clab,'linewidth',3);
        end
        
        %%
        title(['\theta_{roll} = ' num2str(th1_arr(ff))]);
        set(gcf,'position',[1024,807,500,500]); % [20,20,600,500]); 2560,1327
        if vidflag
            frame = getframe(figure(1));
            writeVideo(anim,frame);
            clf;
        else
            pause(0.001);
        end
    end
    
    %% close video
    if vidflag
        close(anim);
        close;
    end
    
end