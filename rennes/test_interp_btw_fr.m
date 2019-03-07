clear; clc; ca;
load pre_nn_20SDF_H_30_short
hold on;

for dd = 5%1:size(PKS1,4)
    for ii = 1:size(PKS1,3)
        
        pk1 = PKS1(:,:,ii,dd);
        pk2 = PKS2(:,:,ii,dd);
        
        scatter(pk1(:,1),pk1(:,2),10,1:size(PKS1),'filled');
        scatter(pk2(:,1),pk2(:,2),10,1:size(PKS1),'filled');
        
    end
end

axis equal
axis tight

