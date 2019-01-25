clear; ca; clc;
dname = '20SDR-H_30_0003';

cd C:\Users\yang\ownCloud\rennes_experiment\18_12_11-09_47_11-STD_18_12_11-09_47_11-STD-160410\__20181211_095212_765000
cd(dname);
fname = dir('*.ima');
filename = fname.name;
info = dicominfo(filename);
[X,cmap,alpha,overlays] = dicomread(filename);
cd C:\Users\yang\ownCloud\MATLAB\rennes

vidflag = 1; % save video
vidrate = 10; 

tgl_plt = 0;
tgl_sav = 0;
v_cut = 500; % vertical pixel to cutoff during point search;

% plt_range = [201,850,251,800];
th1_range = [-75,75]; % range of "roll" rotations to include

sch_rm_pxl = 3;

%%
if vidflag
    opengl('software');
    anim = VideoWriter(['test_stabilize_multi_' dname],'Motion JPEG AVI');
    anim.FrameRate = vidrate;
    open(anim);
end

%% find interesting frames
th1_arr = info.PositionerPrimaryAngleIncrement;
ind_arr = find(th1_arr > th1_range(1) & th1_arr < th1_range(2));

%%

X3 = permute(X,[1,2,4,3]); % 4D images information usually comprises of Height, Width, Color Plane, Frame Number (Color Plane is in the order Red, Green, Blue)

imgA = X3(:,:,ind_arr(1));
% imgA = imgA(plt_range(1):plt_range(2),plt_range(3):plt_range(4));
fr = stretchlim(imgA);
imgA = imadjust(imgA,fr);
I{1} = imgA;

for ii = 2:size(X3,3)
    
    i_ind = ind_arr(ii);
    
    imgA = I{ii-1};
    
    imgB = X3(:,:,i_ind);
    %     imgB = imgB(plt_range(1):plt_range(2),plt_range(3):plt_range(4));
    %     fr = stretchlim(imgB);
    imgB = imadjust(imgB,fr);
    
    %% Read Frames
    if tgl_plt
        figure; imshowpair(imgA, imgB, 'montage');
        title(['Frame A', repmat(' ',[1 70]), 'Frame B']);
        
        figure; imshowpair(imgA,imgB,'ColorChannels','red-cyan');
        title('Color composite (frame A = red, frame B = cyan)');
    end
    
    %% Collect Salient Points from Each Frame
    ptThresh = 0.1;
    pointsA = detectFASTFeatures(imgA(v_cut+1:end,:), 'MinContrast', ptThresh); % (one of the fastest corner detection algorithms)
    pointsB = detectFASTFeatures(imgB(v_cut+1:end,:), 'MinContrast', ptThresh); % (one of the fastest corner detection algorithms)
    
    pointsA.Location(:,2) = pointsA.Location(:,2) + v_cut;
    pointsB.Location(:,2) = pointsB.Location(:,2) + v_cut;
    
    if tgl_plt
        % Display corners found in images A and B.
        figure; imshow(imgA); hold on;
        plot(pointsA);
        title('Corners in A');
        
        figure; imshow(imgB); hold on;
        plot(pointsB);
        title('Corners in B');
    end
    
    %% Select Correspondences Between Points
    % Extract FREAK descriptors for the corners
    [featuresA, pointsA] = extractFeatures(imgA, pointsA); % extract a Fast Retina Keypoint (FREAK) descriptor for each point
    [featuresB, pointsB] = extractFeatures(imgB, pointsB); % extract a Fast Retina Keypoint (FREAK) descriptor for each point
    
    indexPairs = matchFeatures(featuresA, featuresB); % Match features
    pointsA = pointsA(indexPairs(:, 1), :);
    pointsB = pointsB(indexPairs(:, 2), :);
    
    if tgl_plt
        figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
        legend('A', 'B');
    end
    
    %% Estimating Transform from Noisy Correspondences
    [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
        pointsB, pointsA, 'affine');
    imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
    pointsBmp = transformPointsForward(tform, pointsBm.Location);
        
    showMatchedFeatures(imgA, imgBp, pointsAm, pointsBmp);
    legend('A', 'B');
    title(ii);
    
    %% Transform Approximation and Smoothing
    
    % Extract scale and rotation part sub-matrix.
    H = tform.T;
    R = H(1:2,1:2);
    % Compute theta from mean of two possible arctangents
    theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
    % Compute scale from mean of two stable mean calculations
    scale = mean(R([1 4])/cos(theta));
    % Translation remains the same:
    translation = H(3, 1:2);
    % Reconstitute new s-R-t transform:
    HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
        translation], [0 0 1]'];
    tformsRT = affine2d(HsRt);
    
    imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
    imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));
    
    if tgl_plt
        clf;
        imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
        title('Color composite of affine and s-R-t transform outputs');
    end
    
    I{ii} = imgBsRt;
    imgA = imgBsRt;
    
    disp(i_ind);
    
    if vidflag
        frame = getframe(gcf);
        writeVideo(anim,frame);
        clf;
    else
        pause(0.1);
    end
    
end

if tgl_sav
    save(dname,'I');
end

%% close video
if vidflag
    close(anim);
    close;
end
