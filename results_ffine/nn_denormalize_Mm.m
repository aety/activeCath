function [Xin] = nn_denormalize_Mm(Xout,MX,mn)
% Normalizes by [Mean, Std] an array by column for neural network training
% Anne Yang 
% 2018.10.22

Xin = nan(size(Xout,1),size(Xout,2));

for ii = 1:size(Xin,1)
    temp = Xout(ii,:);    
    temp = temp*(MX(ii)-mn(ii)) + mn(ii);
    
    Xin(ii,:) = temp;
end