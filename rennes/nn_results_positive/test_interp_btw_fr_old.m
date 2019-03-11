
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
% for dd = 1%:size(PKS1,4)
%
%     hold on;
%
%     for ii = 1:size(PKS1,3)
%
%         pk1 = PKS1(:,:,ii,dd);
%         pk2 = PKS2(:,:,ii,dd);
%
%         scatter(pk1(:,1),pk1(:,2),10,1:size(PKS1,1),'filled');
%         scatter(pk2(:,1),pk2(:,2),10,1:size(PKS1,1),'filled');
%     end
% end
% % %     axis equal
% %     axis tight


%% plot by node with mean and std
% % % cmap = colormap(lines(size(PKS1,1)));
% % %
% % % for dd = 1:size(PKS1,4)
% % %
% % %     for xx = 1:size(PKS1,1)
% % %
% % %         pk1 = permute(PKS1(xx,:,:,dd),[3,2,1]);
% % %         pk2 = permute(PKS2(xx,:,:,dd),[3,2,1]);
% % %
% % %         %         scatter(pk1(:,1),pk1(:,2),10,xx*ones(1,size(PKS1,3)),'filled');
% % %         %         scatter(pk2(:,1),pk2(:,2),10,xx*ones(1,size(PKS1,3)),'filled');
% % %
% % %         hold on;
% % %         plot(pk1(:,1),pk1(:,2),'.','color',cmap(xx,:),'markersize',10); % plot peaks
% % %
% % %         %         pkm = nanmean(pk1); pkstd = nanstd(pk1);
% % %         %         plot(pkm(1),pkm(2),'*','color',cmap(xx,:)); % plot mean
% % %         %         plot(pkm(1)*ones(1,3),pkm(2)+[-pkstd(2),0,pkstd(2)],'*-','color',cmap(xx,:)); % plot mean and std
% % %
% % %         %         tgl = abs(pk1(:,2)-pkm(2)) < pkstd(2); % remove outliers
% % %         %         plot(pk1(tgl,1),pk1(tgl,2),'o','color',cmap(xx,:)); % plot peaks without outliers
% % %         %         title(xx); pause; clf;
% % %
% % %     end
% % %     %     axis equal
% % %     %     axis tight
% % %
% % %     ylim([0,450]);
% % %     set(gca,'fontsize',8);
% % %     set(gcf,'paperposition',[0,0,3,3],'unit','inches');
% % %     print('-dtiff','-r300',['test_interp_byNode_' num2str(dd)]);
% % %     close;
% % % end


%% alternative clustering
%     GMModel = fitgmdist(B_pk1,16,'Options',statset('MaxIter',500),'CovarianceType','diagonal','SharedCovariance',true,'RegularizationValue',0.01);
%     idx = cluster(GMModel,B_pk1);

%     [~, idx, ~] = dbscan(B_pk1', 1, 1);

%     [centers,U] = fcm(B_pk1,16);
%     maxU = max(U);
%     tgl = U(cc,:) == maxU;