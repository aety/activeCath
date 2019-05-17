clear; clc; ca;
cd C:\Users\yang\ownCloud\MATLAB\__simTrainedExpData

%%
fname = 'proc_incl_pitch_manualPicking_new';
load C:\Users\yang\ownCloud\MATLAB\__experiment\roll_bend_pitch\proc\proc_incl_pitch_manualPicking_new

% modify for compatibility with simulation data
X = -flipud(X); % flip x-y
Y = -flipud(Y); % flip x-y

% plot(X,Y); hold on; plot(X(1,:),Y(1,:),'o');

ref_pt = -fliplr(ref_pt);                       % flip x-y and signs
for ii = 1:length(PKS)
    temp = PKS{ii}(1,:);                        % flip x-y and signs
    PKS{ii}(1:2,:) = -flipud(PKS{ii}(1:2,:));   % flip x-y and signs
    PKS{ii}(2,:) = -temp;                       % flip x-y and signs
    PKS{ii}(3,:) = -PKS{ii}(3,:) + 1;           % flip toggles
    %     plot(PKS{ii}(1,:),PKS{ii}(2,:),'*');
end

pre_nn;

%% load trained network
load C:\Users\yang\ownCloud\MATLAB\__simulation\varHelixN\pitch_0_50\varHelixN_16\nn_findApex_3DoF_varHelixN_16 PDT_best Y TR NET
net = NET;
pp = PDT_best;
predictor = PDT(pp,:); [predictor,PS_pdt] = mapminmax(predictor); % normalization
response = RSP; [response,PS_rsp] = mapminmax(response);         % normalization

x = predictor;
t = response;

%% evaluate
y = net(x);
p = perform(net,t,y);

y = mapminmax('reverse',y,PS_rsp); % reverse normalization
e = gsubtract(RSP,y); % error
sum_e = sum(rssq(e))/length(rssq(e)); % square root of sum of all errors (averaged per sample)

plot(e'); % plot errors
plot(RSP,y,'*'); % plot correlation