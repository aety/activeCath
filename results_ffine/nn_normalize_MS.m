function [Xout,Xmean,Xstd] = nn_normalize_MS(Xin)
% Normalizes by [Mean, Std] an array by column for neural network training
% Anne Yang 
% 2018.10.22

Xmean = nan(1,size(Xin,1));
Xstd = Xmean;
Xout = nan(size(Xin,1),size(Xin,2));

for ii = 1:size(Xin,1)
    temp = Xin(ii,:);
    mm = mean(temp);
    ss = std(temp);    
    temp = (temp - mm)/ss;
    
    Xmean(ii) = mm;
    Xstd(ii) = ss;    
    Xout(ii,:) = temp;
end