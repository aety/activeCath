load nn_findpeaks_attributes_2D predictor response

nn_neural_fitting_2D;
neuralOutput = y';

%%

xlb_arr = {'\theta_{rot}','\theta_{bend}'};
hold on;
for pp = 1:2
    subplot(1,2,pp)
    plot(response(:,pp),neuralOutput(:,pp),'*k');
    
    xlabel([xlb_arr{pp} '(\circ)']);
    ylabel('nn-predicted');
    axis equal
    axis tight
    box off
end

