%% PCA GRID SEARCH
function [lr, epochs, lmd, components] = PCAGridSearch(data, kCV)

% Define parameters for Grid Search
parameters.lr = [0.1, 0.035, 0.05, 0.015, 0.025, 0.01, 0.001, ...
    0.0025, 0.005, 0.0001];
parameters.epochs = [10, 20, 30, 50, 75, 100, 200, 500];
parameters.lmd = [200, 100, 10, 1, 0, 0.1];
parameters.components = [1, 2, 3, 4, 6, 8, 10, 15, 20, 30, 50];

% Initialize structure to store the best parameters found
bestmodel.lr = 0;
bestmodel.epochs = 0;
bestmodel.lmd = 0;
bestmodel.score = 0;
bestmodel.components = 0;

% Initialize counters
i = 1;
j = 0; 
t = 0;

% Work only with the training set
split = (kCV-1)/kCV;
Index = ceil(size(data, 1) * split);
train_data = data(1:Index,:);
test_data = data(Index:end, :);

% Handle overlap
test_data(1,:) = [];

% Compute the number of observations
samples = size(train_data, 1);

% Perform Grid Search, dividing between Validation and Train
max = kCV-2;
best_score = -Inf;

for component_idx = 1:length(parameters.components)

    k = parameters.components(component_idx);
    
    % Isolate the target feature
    X = train_data(:, 1:end-1);
    Y = train_data(:, end);

    X_test = test_data(:, 1:end-1);
    Y_test = test_data(:, end);
    
    % Compute covariance matrix
    covariance_matrix = (X' * X) / (samples - 1);
    
    % Perform SVD
    [U, ~, ~] = svd(covariance_matrix);

    % Transform space
    X_pca_train = X * U(:, 1:k);
    X_pca_test = X_test * U(:, 1:k);
    pca_train_data = [X_pca_train Y];
    pca_test_data = [X_pca_test Y_test];
    
    % Reconstruct dataset
    pca_data = [pca_train_data; pca_test_data];
    
    % Print current cycle
    fprintf('\nCycle: %d | 6\n', t);
    fprintf('Number of components: %.0f\n', k)
    t = t + 1;
        
    % Isolate test set
    % Define fold size
    samples = size(pca_data, 1);
    fold_size = ceil(samples / kCV);
        
    % Split input and output
    X = pca_data(:, 1:end-1);
    Y = pca_data(:, end);
        
    % Fixed test set
    split = (kCV-1)/kCV; % (5-1)/5 = 0.8
    MaxValidationIndex = ceil(size(pca_data, 1) * split);
        
    X_test = X(MaxValidationIndex:end, :);
    y_test = Y(MaxValidationIndex:end);
        
    X = X(1:MaxValidationIndex, :);
    Y = Y(1:MaxValidationIndex, :);
        
    best_temp = -Inf;
    
    for lr_idx = 1:length(parameters.lr)
        lr = parameters.lr(lr_idx);
        
        for epochs_idx = 1:length(parameters.epochs)
            epochs = parameters.epochs(epochs_idx);
        
            for lmd_idx = 1:length(parameters.lmd)
                lmd = parameters.lmd(lmd_idx);
                    
                % Store R^2 scores from cross-validation
                r2TOT = [];
                for rep = 1:kCV-2
        
                    % Call cross-validation function
                    [X_train, y_train, X_val, y_val] = CV(X, Y, j, ...
                        fold_size, max);
                    j = rep;
                        
                    i = i+1;
                    linearRegression = LinearRegression(lr, ...
                        epochs, lmd);
                    linearRegression = linearRegression.fit...
                        (X_train, y_train, X_val, y_val);
                    r2_ = linearRegression.computeScore(X_test, ...
                        y_test);

                    r2TOT = [r2TOT r2_];
                end
        
                r2 = mean(r2TOT);
                    
                if r2 > best_temp
                    best_temp = r2;
                end
    
                if r2 > best_score && r2 <= 1
                    best_score = r2;
                    bestmodel.lr = parameters.lr(lr_idx);
                    bestmodel.epochs = parameters.epochs(epochs_idx);
                    bestmodel.lmd = parameters.lmd(lmd_idx);
                    bestmodel.score = best_score;
                    bestmodel.components = parameters.components...
                        (component_idx);
                end
            end
        end
    end

    fprintf('Best score with these components: %.5f\n', best_temp)

end

disp('')
fprintf('Total combinations analyzed: %d\n', i);

% Set output format to shortG
format shortG

% Print best model parameters
fprintf('\nThe best combination of values found is as follows: \n')
disp(bestmodel)

lr = bestmodel.lr;
epochs = bestmodel.epochs;
lmd = bestmodel.lmd;
components = bestmodel.components;

% Reset output format
format("default")

end