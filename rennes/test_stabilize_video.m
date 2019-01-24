%%
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
for ff = 1:10
    img = X3(:,:,f+ff-1); % Read first frame into imgA
    fr = stretchlim(img);
    I{ff} = imadjust(img,fr);
end

%%

% Reset the video source to the beginning of the file.
% reset(hVideoSrc);

% hVPlayer = vision.VideoPlayer; % Create video viewer

% Process all frames in the video
movMean = I{1};
imgB = movMean;
imgBp = imgB;
correctedMean = imgBp;
% ii = 2;
Hcumulative = eye(3);

for ii = 2:10
    % Read in new frame
    imgA = imgB; % z^-1
    imgAp = imgBp; % z^-1
    imgB = I{ii};
    movMean = movMean + imgB;

    % Estimate transform from frame A to frame B, and fit as an s-R-t
    H = cvexEstStabilizationTform(imgA,imgB);
    HsRt = cvexTformToSRT(H);
    Hcumulative = HsRt * Hcumulative;
    imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

    % Display as color composite with last corrected frame
%     step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
    correctedMean = correctedMean + imgBp;

%     ii = ii+1;
end
correctedMean = correctedMean/(ii-2);
movMean = movMean/(ii-2);

% Here you call the release method on the objects to close any open files
% and release memory.
% release(hVideoSrc);
% release(hVPlayer);