%% FEATURE DISTRIBUTION
function FeatureDistribution(model_data)
    
figure;
subplot(3,3,1);
histogram(model_data(:,93));

subplot(3,3,2);
histogram(model_data(:,113));

subplot(3,3,3);
histogram(model_data(:,89));

subplot(3,3,4);
histogram(model_data(:,7));

subplot(3,3,5);
histogram(model_data(:,98));

subplot(3,3,6);
histogram(model_data(:,101));

subplot(3,3,7);
histogram(model_data(:,73));

subplot(3,3,8);
histogram(model_data(:,123));

subplot(3,3,9);
histogram(model_data(:,90));

end