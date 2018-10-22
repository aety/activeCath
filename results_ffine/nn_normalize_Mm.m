function [Xout,Xmax,Xmin] = nn_normalize_Mm(Xin)
% Normalizes by [min, max] an array by column for neural network training
% Anne Yang 
% 2018.10.22

Xmax = nan(1,size(Xin,1));
Xmin = Xmax;
Xout = nan(size(Xin,1),size(Xin,2));

for ii = 1:size(Xin,1)
    temp = Xin(ii,:);
    xx = max(temp);
    mm = min(temp);    
    temp = (temp - mm)/(xx - mm);
    
    Xmax(ii) = xx;
    Xmin(ii) = mm;    
    Xout(ii,:) = temp;
end