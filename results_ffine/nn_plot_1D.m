load nn_findpeaks_attributes predictor response

neuralOutput = myNeuralNetworkFunction(predictor);

%%

plot(response,neuralOutput,'*k');

xlabel('\theta_{rot}');
ylabel('nn-predicted');
axis equal