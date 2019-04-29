%% debugging-- something is wrong with this frame (and potentially others too)

load proc_findApex_3DoF_varHelixN_16

for ii = 1:size(X,2) % 
    
    tg = TGL{ii};
    dif = abs((length(tg) - sum(tg))-sum(tg));
    
    if dif > 3
        temp = PKS{ii};
        
        hold on;
        plot(X(:,ii),Y(:,ii),'k');
        plot(temp(1,tg),temp(2,tg),'*');
        plot(temp(1,~tg),temp(2,~tg),'*');
        axis equal
        title([ii,dif]);
        
        pause;
        clf;
    end
    
end