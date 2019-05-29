clear; clc; ca;

cd C:\Users\yang\ownCloud\MATLAB\__expTrainedExpData\2_pdt
fname = 'nn_expTrainedExpData';

load(fname);

x1 = TR.divideParam.trainRatio;
x2 = TR.divideParam.valRatio;
x3 = TR.divideParam.testRatio;

X = [x1,x2,x3];
labels = {'testing','validation','testing'};
p = pie(X,labels);
colormap(lines(3));


for ii = 1:3
    t = p(ii*2);
    t.FontSize = 12;
end

set(gcf,'paperposition',[0,0,4,3]);
print('-dtiff','-r300',['divide_Pie_' fname]);
close;