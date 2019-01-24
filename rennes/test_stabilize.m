dname = '20SDR-H_30_0003';
cd C:\Users\yang\ownCloud\rennes_experiment\18_12_11-09_47_11-STD_18_12_11-09_47_11-STD-160410\__20181211_095212_765000
cd(dname);
fname = dir('*.ima');
filename = fname.name;
info = dicominfo(filename);
[X,cmap,alpha,overlays] = dicomread(filename);
cd C:\Users\yang\ownCloud\MATLAB\rennes

X3 = permute(X,[1,2,4,3]);
f = 1;
for ff = 1:2
    img = X3(:,:,f+ff-1); % Read first frame into imgA
    fr = stretchlim(img);
    I{ff} = imadjust(img,fr);
end
imgA = I{1}; imgB = I{2};

%% Read Frames 
% figure; imshowpair(imgA, imgB, 'montage');
% title(['Frame A', repmat(' ',[1 70]), 'Frame B']);

% figure; imshowpair(imgA,imgB,'ColorChannels','red-cyan');
% title('Color composite (frame A = red, frame B = cyan)');

%% Collect Salient Points from Each Frame
ptThresh = 0.1;
pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh); % (one of the fastest corner detection algorithms)
pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh); % (one of the fastest corner detection algorithms)

% Display corners found in images A and B.
% figure; imshow(imgA); hold on;
% plot(pointsA);
% title('Corners in A');
% 
% figure; imshow(imgB); hold on;
% plot(pointsB);
% title('Corners in B');

%% Select Correspondences Between Points
% Extract FREAK descriptors for the corners
[featuresA, pointsA] = extractFeatures(imgA, pointsA); % extract a Fast Retina Keypoint (FREAK) descriptor for each point
[featuresB, pointsB] = extractFeatures(imgB, pointsB); % extract a Fast Retina Keypoint (FREAK) descriptor for each point

indexPairs = matchFeatures(featuresA, featuresB); % Match features
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

% figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
% legend('A', 'B');

%% Estimating Transform from Noisy Correspondences
[tform, pointsBm, pointsAm] = estimateGeometricTransform(...
    pointsB, pointsA, 'affine');
imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
pointsBmp = transformPointsForward(tform, pointsBm.Location);

figure;
showMatchedFeatures(imgA, imgBp, pointsAm, pointsBmp);
legend('A', 'B');

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

figure(2), clf;
imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
title('Color composite of affine and s-R-t transform outputs');