function [p,S,mu] = PolyfitCatheter(fa,fb,n,n_rpt,p_exc)

a_arr = unique(fa);                                 % array of unique pixels along a-direction (y-axis in imshow)
a_arr_p = a_arr(round(length(a_arr)*p_exc):end);    % exclude the distal portion by a percentage, p_exc
lia = ismember(fa,a_arr_p);                         % identify indices of values remained after the exclusion
tempa = fa(lia); tempb = fb(lia);                   % take a subset of fa and fb (remained after tip exclusion)

% figure; hold on; axis equal
% plot(tempa,tempb,'*');

for rr = 1:n_rpt % repeat the clean-up process n_rpt times     
    
    for aa = 1:length(a_arr_p)        
        
        a = a_arr_p(aa);        % current a-value
        temp = find(tempa==a);  % find indices of elements in the array matching the current a-value
        tempb_i = tempb(temp);  % find a subset of b-values matching the current a-values
        avg = mean(tempb_i);    % take average of the b-values of interest
        st = std(tempb_i);      % take STD of the b-values of interest
        
        temp_n = find(abs(tempb_i-avg) > st); % find indices of b-values out of one STD (among the current a-value)
        tempa(temp(temp_n)) = nan; tempb(temp(temp_n)) = nan; % eliminate outliers (turn them into NaN's to retain their position in the array)
        
    end
    
%     plot(tempa,tempb,'*');
end

tempa(isnan(tempa)) = []; % replace nan's with 0
tempb(isnan(tempb)) = []; % replace nan's with 0

% polyfit
[p,S,mu] = polyfit(tempa,tempb,n); % polyfit 

% plot(x,y,'linewidth',3);
