clear; clc; ca;
load('circular_approx_curVar_wSine_3D_rotate_findApex');

%% find the maximum node number
temp_size = nan(length(rot_arr),length(variable_arr));
for aa = 1:length(rot_arr)
    for rr = 1:length(variable_arr)
        temp_size(aa,rr) = length(X_PKS_ARR{aa,rr});
    end
end
ss = max(max(temp_size));
clear temp_size

%% reshape matrices
XX = nan(ss,length(variable_arr),length(rot_arr));
YY = XX; NN = XX; BB = XX; AA = XX;

for aa = 1:length(rot_arr)
    for rr = 1:length(variable_arr)
        x_pks = X_PKS_ARR{aa,rr};
        y_pks = Y_PKS_ARR{aa,rr};
        
        XX(1:length(x_pks),rr,aa) = x_pks;
        YY(1:length(y_pks),rr,aa) = y_pks;
        NN(1:length(x_pks),rr,aa) = 1:length(x_pks);
        BB(1:length(x_pks),rr,aa) = variable_arr(rr)*ones(length(x_pks),1);
        AA(1:length(x_pks),rr,aa) = rot_arr(aa)*ones(length(x_pks),1);
    end
end

%%
rsp_XX = reshape(XX,size(XX,1),size(XX,2)*size(XX,3));
rsp_YY = reshape(YY,size(XX,1),size(XX,2)*size(XX,3));
rsp_AA = reshape(AA,size(XX,1),size(XX,2)*size(XX,3));
rsp_BB = reshape(BB,size(XX,1),size(XX,2)*size(XX,3));

rsp_input = [rsp_XX;rsp_YY];
rsp_output = [rsp_AA(1,:);rsp_BB(1,:)];