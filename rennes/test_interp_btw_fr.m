clear; clc; ca;
load pre_nn_20SDF_H_30_short

%% plot by frame
% % for dd = 1%1:size(PKS1,4)
% %
% %     hold on;
% %
% %     for xx = 1:size(PKS1,1)
% %
% %         pk1 = permute(PKS1(xx,:,:,dd),[3,2,1]);
% %         pk2 = permute(PKS2(xx,:,:,dd),[3,2,1]);
% %
% %         scatter(pk1(:,1),pk1(:,2),10,1:size(PKS1,3),'filled');
% %         scatter(pk2(:,1),pk2(:,2),10,1:size(PKS1,3),'filled');
% %     end
% %     axis equal
% %     axis tight
% % end

%% plot by node
% % % for dd = 1%:size(PKS1,4)
% % %
% % %     hold on;
% % %
% % %     for ii = 1:size(PKS1,3)
% % %
% % %         pk1 = PKS1(:,:,ii,dd);
% % %         pk2 = PKS2(:,:,ii,dd);
% % %
% % %         scatter(pk1(:,1),pk1(:,2),10,1:size(PKS1,1),'filled');
% % %         scatter(pk2(:,1),pk2(:,2),10,1:size(PKS1,1),'filled');
% % %     end
% % % end
% % % % %     axis equal
% % % %     axis tight


%% plot by node with mean and std
% % cmap = colormap(parula(size(PKS1,1)));
% %
% % for dd = 1%1:size(PKS1,4)
% %
% %     for xx = 1:size(PKS1,1)
% %
% %         pk1 = permute(PKS1(xx,:,:,dd),[3,2,1]);
% %         pk2 = permute(PKS2(xx,:,:,dd),[3,2,1]);
% %
% %         %         scatter(pk1(:,1),pk1(:,2),10,xx*ones(1,size(PKS1,3)),'filled');
% %         %         scatter(pk2(:,1),pk2(:,2),10,xx*ones(1,size(PKS1,3)),'filled');
% %
% %         hold on;
% %         plot(pk1(:,1),pk1(:,2),'.','color',cmap(xx,:)); % plot peaks
% %
% %         pkm = nanmean(pk1); pkstd = nanstd(pk1);
% %         plot(pkm(1),pkm(2),'*','color',cmap(xx,:)); % plot mean
% %         %         plot(pkm(1)*ones(1,3),pkm(2)+[-pkstd(2),0,pkstd(2)],'*-','color',cmap(xx,:)); % plot mean and std
% %
% %         %         tgl = abs(pk1(:,2)-pkm(2)) < pkstd(2); % remove outliers
% %         %         plot(pk1(tgl,1),pk1(tgl,2),'o','color',cmap(xx,:)); % plot peaks without outliers
% %         %         title(xx); pause; clf;
% %
% %     end
% %     %     axis equal
% %     %     axis tight
% % end

%% clustering

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% not quite done yet-- not all iterations generate correct clustering
% need to try different starting methods
% also the scaling factor needs to be determined more systematically
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ca;

colormap(lines);
hold on;
for dd = 5%1:size(PKS1,4)
    
    n_node = repmat(1:20,188,1)';
    n_fr = repmat(1:188,20,1);
    pk1 = permute(PKS1(:,:,:,dd),[1,3,2]);
    
    B_node = reshape(n_node,3760,1);    % reshape
    B_fr = reshape(n_fr,3760,1);        % reshape
    B_pk1 = reshape(pk1,3760,2);        % reshape
    
    B_node(isnan(B_pk1(:,1))) = [];     % remove NaNs
    B_fr(isnan(B_pk1(:,1))) = [];       % remove NaNs
    B_pk1(isnan(B_pk1(:,1)),:) = [];    % remove NaNs
    
    temp = [min(B_pk1(:,2)),max(B_pk1(:,2))];   % save original scale
    B_pk1(:,2) = rescale(B_pk1(:,2),0,100000000);    % scale to y-dimension to help clustering    
    [idx,C,sumd,D] = kmeans(B_pk1,16,'Display','final','start','plus'); % cluster    
    B_pk1(:,2) = rescale(B_pk1(:,2),temp(1),temp(2));   % scale back to original y-dimension
    
    for cc = 1:16
        tgl = idx==cc;
        h = scatter(B_pk1(tgl,1),B_pk1(tgl,2),10,'r','filled');
        axis equal
        title(cc);
        axis([-400,0,0,450]);
        pause;
        h.CData = [0,0,0];
    end
end