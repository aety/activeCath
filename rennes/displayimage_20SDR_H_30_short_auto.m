clear; ca; clc;

flg_plot = 0;

vidflag = 0;

c_arr = lines(3); clab = c_arr(3,:); % marker color label
msize = 5;

%% load image
dname = '20SDR-H_30_0003';
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
    anim = VideoWriter([dname '_proc'],'Motion JPEG AVI');
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

for ff = ind_arr(1)%:ind_arr(end)
    
    % select frame
    I = X3(:,:,ff);
    I = I(201:850,251:800);
    
    %% plot current
    if flg_plot
        [counts,~] = imhist(I); % saturation should occur on the furthest left and right
        figure(98); hold on; plot(counts); % plot original histogram
    end
    
    %% contrast stretching and sharpening
    n = 256;
    fr = stretchlim(I); % default: [0.01,0.99]
    J = imadjust(I,fr);
    J = imsharpen(J,'radius',3,'amount',3); % (default radius = 1; default amount = 0.8)
    
    %% plot current
    [counts,~] = imhist(J); % saturation should occur on the furthest left and right
    if flg_plot
        figure(99); hold on; plot(counts); % plot adjusted histogram
    end
    
    %% thresholding using matlab remove background
    level = graythresh(J);
    K = imbinarize(J,level);
    %     level = multithresh(J,10); % 10 levels in total (1,2,3,4,5,6)
    %     K = imquantize(J,level);
    %     K(K<=5) = 0; K(K>5) = 1; % keep only the first 2 levels (1,2)
    
    %% identify catheter
    L = imcomplement(K);
    s = regionprops('table',L,'Area','BoundingBox','PixelIdxList');
    Area = s.Area;
    BoundingBox = s.BoundingBox;
    PixelIdxList = s.PixelIdxList;
    [~,ind] = max(Area);
    temp = BoundingBox(ind,:);
    axlim = round([temp(1),temp(2),temp(3),temp(4)]); % round to the nearest pixel integer
    
    if flg_plot
        imshow(L);
        hold on;
        rectangle('Position',axlim,'edgecolor',clab,'linewidth',2);
    end
    
    %% exclude pixels outside of the catheter bounding box
    tgl = zeros(size(K));
    tgl(axlim(2):axlim(2)+axlim(4),axlim(1):axlim(1)+axlim(3)) = 1;
    L(~tgl) = 0; % turn irrelevant area in inverted image black
    K(~tgl) = 1; % turn irrelevant area in original image black
    
    if flg_plot
        figure;
        imshow(L);
    end
    
    %% plot current image
    [countsK,~] = imhist(K); % saturation should occur on the furthest left and right
    figure(1000); subplot(1,2,1); imshow(J); %subplot(1,4,2); plot(counts,'linewidth',2);
    subplot(1,2,2); imshow(K,[]); %subplot(1,4,4); plot(countsK,'linewidth',2);
    hold on; rectangle('Position',axlim,'edgecolor',c_arr(1,:),'linewidth',1);
    
    %% edge detection
    % % %     %'Sobel' (default) | 'Prewitt' | 'Roberts' | 'log' | 'zerocross' | 'Canny' | 'approxcanny'
    % % %     method = 'Sobel';
    % % %     BW = edge(K,method);
    % % %     figure; imshow(BW);
    
    %% regionprops
    
    % BoundingBox
    cc = bwconncomp(K,4); %  returns the connected components CC found in the binary image BW
    s = regionprops('table',cc,'Centroid','BoundingBox');
    Centroid = cat(1,s.Centroid);
    BoundingBox = cat(1, s.BoundingBox);
    Centroid(BoundingBox(:,4)>400,:) = [];
    
    % plot only centroid of those areas
    temp = Centroid;
    hold on; plot(temp(:,1),temp(:,2),'o','markersize',msize,'markerfacecolor',clab,'markeredgecolor',clab);
    
    
    %%
    title(['\theta_{roll} = ' num2str(th1_arr(ff))]);
    set(gcf,'position',[1,41,600,500]); % [20,20,600,500]); 2560,1327
    if vidflag
        frame = getframe(figure(1000));
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