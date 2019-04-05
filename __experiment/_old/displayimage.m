clear; ca; clc;

flg_plot = 0;

vidflag = 1;

c_arr = lines(3); clab = c_arr(3,:); % marker color label
msize = 3;

%% load image
dname = '20SDR-H_30_0135';
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
th1_bound = [-75,75];
th1_arr = info.PositionerPrimaryAngleIncrement;
ind_arr = find(th1_arr > th1_bound(1) & th1_arr < th1_bound(2));

%% show image (all frames)

for ff = ind_arr(1):ind_arr(end)
    
    % select frame
    I = X3(:,:,ff);
    I = I(100:920,400:800);
    
    %% plot current
    if flg_plot
        [counts,~] = imhist(I); % saturation should occur on the furthest left and right
        figure(98); hold on; plot(counts); % plot original histogram
    end
    
    %% contrast stretching 1
    n = 256;
    fr = stretchlim(I); % default: [0.01,0.99]
    J = imadjust(I,fr);
    
    %% plot current
    [counts,~] = imhist(J); % saturation should occur on the furthest left and right
    if flg_plot
        figure(99); hold on; plot(counts); % plot adjusted histogram
    end
    
    %% thresholding using matlab remove background
    %     level = graythresh(J);
    %     K = imbinarize(J,level);
    level = multithresh(J,2);
    K = imquantize(J,level);
    K(K==1) = 0; K(K~=0) = 1;
    %% thresholding using the histogram
    
    % %     % no-filter on the histogram
    % %     y = counts;
    % %
    % %     % find maximum peak and cut off values to its left
    % %     pksx = find(y==max(y)); % find the x-index of the peak
    % %     y = y(pksx+1:end);        % only retain values to the right
    % %
    % %     if flg_plot
    % %         figure(100); hold on; plot(y,'linewidth',1); % plot thresheld histogram
    % %     end
    % %
    % %     % find local min
    % %     % %     TF = islocalmin(y); % find local minima
    % %     % %     temp = 1:256;       % temporary array for x-indices
    % %     % %     lminx = temp(TF);   % x-values of local minima
    % %     % %     lminy = y(TF);      % y-values of local minima
    % %     % %
    % %     % %     if flg_plot
    % %     % %         figure(100); plot(lminx,lminy,'*','linewidth',5); % plot local minima
    % %     % %     end
    % %
    % %     % mirror the first inflection point on the right of the peak to the left
    % %     % %     ind_infl = find(diff(lminy)>0,1);       % find index of inflection point
    % %     % %     if isempty(ind_infl)
    % %     % %         ind_infl = length(lminy);           % take the last point if no inflection
    % %     % %     end
    % %
    % %     % mirror the minimum on the right by its y-value
    % %     %     cut_y = lminy(ind_infl);                    % find the y-value of the cutoff point on the right
    % %     cut_y = min(y);
    % %     cut_x_temp = find(counts(1:pksx) > cut_y);  % find (left) values greater than the cutoff
    % %     temp = find(diff(cut_x_temp)>1,1,'last');   % find the first point of the last bunch greater than the cutoff
    % %     cut_pt = cut_x_temp(temp+1);                % find the x-value of the cutoff point
    % %
    % %     if flg_plot
    % %         figure(99); plot(cut_pt,counts(cut_pt),'o','linewidth',5); % plot cutoff
    % %     end
    % %
    % %     fr = [0,cut_pt]/256;
    % %     K = imadjust(J,fr);
    
    %% plot current image
    [countsK,~] = imhist(K); % saturation should occur on the furthest left and right
    figure(1000); subplot(1,2,1); imshow(J); %subplot(1,4,2); plot(counts,'linewidth',2);
    subplot(1,2,2); imshow(K,[]); %subplot(1,4,4); plot(countsK,'linewidth',2);
    
    %% edge detection
    % % %     %'Sobel' (default) | 'Prewitt' | 'Roberts' | 'log' | 'zerocross' | 'Canny' | 'approxcanny'
    % % %     method = 'Sobel';
    % % %     BW = edge(K,method);
    % % %     figure; imshow(BW);
    
    %% regionprops
    % Centroid
    % %     cc = bwconncomp(K);
    % %     s = regionprops('table',cc,'Centroid');
    % %     Centroid = cat(1, s.Centroid);
    % %     hold on; plot(Centroid(:,1),Centroid(:,2),'o','markersize',5,'markerfacecolor','g','markeredgecolor','g');
    
    % BoundingBox
    cc = bwconncomp(K,4); %  returns the connected components CC found in the binary image BW
    s = regionprops('table',cc,'Centroid','BoundingBox');
    Centroid = cat(1,s.Centroid);
    BoundingBox = cat(1, s.BoundingBox);
    Centroid(BoundingBox(:,4)>400,:) = [];
    BoundingBox(BoundingBox(:,4)>400,:) = [];
    
    
    % plot full areas
    %     for ii = 1:size(BoundingBox,1)
    %         hold on; rectangle('Position',BoundingBox(ii,:),'facecolor',clab,'edgecolor',clab);
    %     end
    
    % plot only centroid of those areas
    temp = Centroid;
    hold on; plot(temp(:,1),temp(:,2),'o','markersize',msize,'markerfacecolor',clab,'markeredgecolor',c_arr(2,:));
    
    
    %%
    title(['\theta_{roll} = ' num2str(th1_arr(ff))]);
    set(gcf,'position',[20,20,600,500]); % [1,41,2560,1327]);
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