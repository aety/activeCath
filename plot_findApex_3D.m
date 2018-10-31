load catheter_simulator_findApex_3D

c_arr = colormap(plasma(length(pitch_arr)));

for bb = 1:length(pitch_arr)
    
    for aa = 1:length(roll_arr)
        
        for rr = 1:length(bend_arr)
            
            x_pks = X_PKS_ARR{rr,aa,bb};
            y_pks = Y_PKS_ARR{rr,aa,bb};
            subplot(3,3,rr); hold on;
            plot3(x_pks,y_pks,roll_arr(aa)*ones(1,length(x_pks)),'color',c_arr(bb,:));
            
        end
    end
end

for pp = 1:9
    
    subplot(3,3,pp);
    title(['bend = ' num2str(bend_arr(pp))],'fontweight','normal');
    zlabel('roll');
    xlabel('x (mm)'); ylabel('y (mm)');
    view(3);
end
c = colorbar;
temp = linspace(0,1,length(pitch_arr)+1); temp = temp(2:end);
c.Ticks = temp;
c.TickLabels = pitch_arr;
ylabel(c,'pitch');

    