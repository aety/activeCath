clear;clc;ca
net = alexnet;

orig = webread('https://media.bakingmad.com/app_/responsive/BakingMad/media/content/Recipes/Tarts/Apple-tart/1-Apple-tart-rectangle-web.jpg?w=840');
im = imresize(orig,[227 227]);
prediction = classify(net,im);
imshow(orig); title(char(prediction));

% Get all layers of network 
layers = net.Layers;

% The categories / class names are contained in the final layer of the network
class_names = layers(end).ClassNames;

% Get prediction and all confidence values
% from every category ( 1000 values )
[prediction,all_confidences] = classify(net,im); 

% You can create plots easily in MATLAB
figure;
plot(all_confidences);

% 
[sorted_confidence,idx] = sort(all_confidences,'descend');
labels = categorical(class_names(idx(1:10)));
barh(labels,sorted_confidence(1:10));

% add important information/labels to plot
xlabel('Confidence');
title('Top 10 predictions');