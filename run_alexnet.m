net = alexnet;
im = imread('strawberry.jpg');
im = imresize(im,[227,227]);
classify(net,im)
