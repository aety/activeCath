clear; clc; ca;

cd C:\Users\yang\ownCloud\MATLAB\__expTrainedExpData\2_pdt
fname = 'nn_expTrainedExpData';

load(fname);

x1 = TR.divideParam.trainRatio;
x2 = TR.divideParam.valRatio;
x3 = TR.divideParam.testRatio;

X = [x1,x2,x3];
labels = {'training','validation','testing'};
p = pie(X,labels);
colormap(white);


for ii = 1:3
    t = p(ii*2);
    t.FontSize = 16;
end

set(gcf,'paperposition',[0,0,4,2]);
print('-dtiff','-r300',['divide_Pie_' fname]);
close;

%%
function g = white(m)

if nargin < 1
    f = get(groot,'CurrentFigure');
    if isempty(f)
        m = size(get(groot,'DefaultFigureColormap'),1);
    else
        m = size(f.Colormap,1);
    end
end

g = [1,1,1];
g = repmat(g,m,1);%
end