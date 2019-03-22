%%

% I_ctol = I_str;
% temp = max(max(I_ctol));
% I_ctol(:,[1:bbox_big(1)-thrs_near,(thrs_near+bbox_big(1)+bbox_big(3)):end]) = temp;
% I_ctol([1:bbox_big(2)-thrs_near,(thrs_near+bbox_big(2)+bbox_big(4)):end],:) = temp;

%%
clear;
clc;
ca; 

load I_test
I = imadjust(I);
imshow(I);

%%
sharp_r = 2; % sharpening radius
sharp_a = 10;  % sharpening amount 
I = imsharpen(I,'radius',sharp_r,'amount',sharp_a); % (default radius = 1; default amount = 0.8)

imshow(I);