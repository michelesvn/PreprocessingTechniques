%% GRID SEARCH
function [lr, epochs, lmd] = GridSearch(model_data, k)

% Define parameters for Grid Search
parameters.lr = [0.1, 0.035, 0.05, 0.015, 0.025, 0.01, 0.001, 0.0025,...
    0.005, 0.0001, 0.0005, 0.00001, 0.000001, 0.000001, 0.0000001,...
    0.00000001, 0.000000001];
parameters.epochs = [10, 20, 30, 50, 75, 100, 200, 500, 1000];
parameters.lmd = [200, 100, 10, 1, 0, 0.1];

% Initialize structure to store the best parameters found
bestmodel.lr = 0;
bestmodel.epochs = 0;
bestmodel.lmd = 0;
bestmodel.score = 0;

% Initialize counters
i = 1;
j = 0; 

% Isolate the test set
% Compute fold size
samples = size(model_data, 1);
fold_size = ceil(samples / k);

% Split input and output
X = model_data(:, 1:end-1);
Y = model_data(:, end);

% Fixed test set
split = (k-1)/k; % (5-1)/5 = 0.8
MaxValidationIndex = ceil(size(model_data, 1) * split);
X_test = X(MaxValidationIndex:end, :);
y_test = Y(MaxValidationIndex:end);

X = X(1:MaxValidationIndex, :);
Y = Y(1:MaxValidationIndex, :);

% Handle duplicate row
X_test = X_test(2:end, :);
y_test = y_test(2:end, :);

% Perform Grid Search by splitting between Validation and Train
max = k-2;

% Initialize Grid Search
best_score = -Inf;

for lr_idx = 1:length(parameters.lr)

    lr = parameters.lr(lr_idx);

    for epochs_idx = 1:length(parameters.epochs)

        epochs = parameters.epochs(epochs_idx);

        for lmd_idx = 1:length(parameters.lmd)

            lmd = parameters.lmd(lmd_idx);
            
            r2TOT = [];

            for rep = 1:k-2
                
                % Call the CV function
                [X_train, y_train, X_val, y_val] = CV(X, Y, j,...
                    fold_size, max);
                j = rep;

                i = i+1;
                linearRegression = LinearRegression(lr, epochs, lmd);
                linearRegression = linearRegression.fit(X_train, ...
                    y_train, X_val, y_val);
                r2 = linearRegression.computeScore(X_test, y_test);
                r2TOT = [r2TOT r2];

            end

            r2 = mean(r2TOT);

            if r2 > best_score && r2 <= 1

                best_score = r2;
                bestmodel.lr = parameters.lr(lr_idx);
                bestmodel.epochs = parameters.epochs(epochs_idx);
                bestmodel.lmd = parameters.lmd(lmd_idx);
                bestmodel.score = best_score;

            end

        end

    end

end

fprintf('Total combinations analyzed: %d\n', i);

% Set output format to shortG
format shortG

% Display the best model structure
disp(bestmodel)

lr = bestmodel.lr;
epochs = bestmodel.epochs;
lmd = bestmodel.lmd;

% Reset output format
format("default")

end