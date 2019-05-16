n_helix_arr = 4:2:24; %%%%%%%%%%%%% temp

for nnn = 1:length(n_helix_arr)
    
    n_helix = n_helix_arr(nnn);           % number of sinusoids of the helix
    
    d = ['varHelixN_' num2str(n_helix)];
    
    cd(d);
    
    fname = ['findApex_3DoF_varHelixN_' num2str(n_helix)];
    
    %% view nn results
    
    load(['nn_' fname]);
    
    y = Y;
    tr = TR;
    ind = tr.testInd;
    
    for rr = 1%:size(RSP,1)
        
        a = RSP(rr,ind);
        b = y(rr,ind);
        
        c = abs(b - a);
        
        tgl = c > (mean(c) + std(c));
%         subplot(3,1,rr);
%         hold on;        
%         h = scatter(a,c,10,'k','filled');
%         scatter(a(tgl),c(tgl),10,'r','filled');
        
        a2 = RSP(2,ind);
        a3 = RSP(3,ind);
        
        hold on;
        scatter3(a(tgl),a2(tgl),a3(tgl),20,n_helix_arr(nnn)*ones(sum(tgl),1),'filled');
        
    end
    
    cd ..
    
end

xlabel(RSP_txt{1});
ylabel(RSP_txt{2});
zlabel(RSP_txt{3});
hb = colorbar;
ylabel(hb,'no. of helices');
view(3)