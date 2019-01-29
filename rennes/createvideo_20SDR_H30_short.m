clear; ca; clc;

% display toggle
vidflag = 1; % save video
vidrate = 20; % video frame rate

% figure parameters
c_arr = lines(6); c_lab_y = c_arr(3,:); c_lab_b = c_arr(6,:); % marker color label
msize = 8; % markersize
lwd = 2; % linewidth
ht = 800; % figure height (pixels)
txt_d = 30; % distance of labeling text from the edge (pixels)
txt_s = 14; % font size

% image processing parameters
th1_range = [-75,75]; % range of "roll" rotations to include
plt_range = [201,850,251,800]; % range of pixels to plot ([x_0,x_end,y_0,y_end])
sharp_r = 1; % sharpening radius
sharp_a = 10; % sharpening amount

%% load image

dname_arr = {'20SDR-H_30_0003','20SDR-H_30_0021','20SDR-H_30_0067','20SDR-H_30_0083','20SDR-H_30_0099'}; %

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
        anim = VideoWriter(['createvideo_' dname],'Motion JPEG AVI');
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
        
        G = X3(:,:,ff); % load frame
        
        %% stretch (I_str)
        H = G(plt_range(1):plt_range(2),plt_range(3):plt_range(4)); % extract the "global" area of interest
        fr = stretchlim(H); % default: [0.01,0.99] % calculate stretch imits
        I_str = imadjust(H,fr); % stretch image (contract adjusting)
       
        %% sharpening (I_shp)
%         I_shp = imsharpen(I_str,'radius',sharp_r,'amount',sharp_a); % (default radius = 1; default amount = 0.8)
        
        %% plot
        wd = size(I_str,2)*ht/size(I_str,1);
        set(gcf,'position',[1000,200,wd,ht]);
        set(gca,'position',[0.01,0.01,.99,.99]);        
        imshow(I_str); 
        
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