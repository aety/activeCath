close all;
clear;

[I,map,transparency] = imread('catheter_example.png'); % read images
I = I(:,:,1); % pick only one layer (???)
J = imadjust(I,[0,0.3],[0,1]); % adjust intensity values (increases contrast)

imshow(J); % display image
mtd_arr = {'Sobel','Prewitt','Roberts','log','zerocross','Canny','approxcanny'};

% 'Sobel','Prewitt','Roberts'-- shape (maximum gradient)
% 'log','zerocross'-- texture (zero crossing)
% 'Canny'-- texture (local maximum gradient)
% 'approxcanny'-- I don't understand (an approximate version of Canny)

%%
for ii = 1%:length(mtd_arr)
    
    [BW,threshOut] = edge(J,mtd_arr{ii}); % edge detection
    figure;
    imshow(BW);
    
    
    
    %     fudgeFactor = 0.5;
    %     BW1 = edge(J,mtd_arr{ii},'Sobel',fudgeFactor*threshOut);
    %     figure;
    %     imshow(BW1);
    
    
   
    [B,L,n,A] = bwboundaries(BW); % trace boundaries 
    figure;
    imshow(label2rgb(L, @jet, [.5 .5 .5]))
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    end
    
    
    
    %     se90 = strel('line', 3, 90);
    %     se0 = strel('line', 3, 0);
    %     BWsdil = imdilate(BW, [se90 se0]); % dilate images 
    %     figure, imshow(BWsdil), title('dilated gradient mask');
    
    
    
    %     imshowpair(BW,BW1); % display two images side by side
    %     title(mtd_arr{ii});
    
end
