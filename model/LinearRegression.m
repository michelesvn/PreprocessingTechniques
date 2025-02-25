%% LINEAR REGRESSION
classdef LinearRegression
    
    % Definition of class properties
    properties
        
        learning_rate          % Learning rate
        epochs                 % Number of training steps
        lambda                 % Regularization factor
        weights                % Model weights
        cost_history           % Tracks training cost evolution
        cost_history_val       % Tracks validation cost evolution
        
    end
    
    % Definition of class methods
    methods
        
        % Constructor for initializing the object
        function obj = LinearRegression(learning_rate, epochs, lambda)
            
            obj.learning_rate = learning_rate;
            obj.epochs = epochs;
            obj.lambda = lambda;
            obj.weights = [];
            obj.cost_history = [];
            obj.cost_history_val = [];
            
        end
        
        % Fit function
        function obj = fit(obj, X_train, y_train, X_val, y_val)
            
            % Concatenate bias term
            X_train = [ones(size(X_train, 1), 1), X_train];
            X_val = [ones(size(X_val, 1), 1), X_val];
            
            % Track cost history
            cost_history_ = zeros(obj.epochs, 1);
            cost_history_val_ = zeros(obj.epochs, 1);
            
            % Number of samples and features
            [m, n_features] = size(X_train);
            m_val = size(X_val, 1);
            
            % Initialize weights and handle regularization factor
            rng(42); % Seed
            weights_ = rand(n_features, 1);
            
            % Perform Full Batch Gradient Descent
            for epoch = 1:obj.epochs
                
                % Compute predictions
                predictions = X_train * weights_;
                predictions_val = X_val * weights_;
                
                % Compute errors
                errors = predictions - y_train;
                errors_val = predictions_val - y_val;
                
                % Compute sum of squared weights for regularization
                squared_weights = weights_.^2;
                sum_squared_weights = sum(squared_weights);
                
                % Compute costs
                cost_history_(epoch) = (1 / (2 * m)) * (sum(errors.^2) + obj.lambda * sum_squared_weights);
                cost_history_val_(epoch) = (1 / (2 * m_val)) * (sum(errors_val.^2) + obj.lambda * sum_squared_weights);
                
                % Update weights
                weights_ = weights_ - (obj.learning_rate / m) * (sum(errors' * X_train) + obj.lambda * weights_);
            end
            
            % Update object properties
            obj.cost_history = cost_history_;
            obj.cost_history_val = cost_history_val_;
            obj.weights = weights_;
            
        end
        
        % Prediction function
        function predictions = predict(obj, X_test)
            
            X_test = [ones(size(X_test, 1), 1), X_test];
            % Matrix multiplication
            predictions = X_test * obj.weights;
            
        end
        
        % Compute R^2 score
        function r2 = compute_r2_score(obj, X_test, y_test)
            
            predictions = obj.predict(X_test);
            y_mean = mean(y_test);
            sst = sum((y_test - y_mean) .^ 2);
            ssr = sum((y_test - predictions) .^ 2);
            r2 = 1 - ssr / sst;
            
        end
        
        % Function to return model weights
        function weights = get_weights(obj)
            
            weights = obj.weights;
            
        end
        
        % Compute RMSE error
        function compute_rmse(obj, X_test, y_test)
            
            X_test = [ones(size(X_test, 1), 1), X_test];
            % Matrix multiplication
            predictions = X_test * obj.weights;
            temp = predictions - y_test;
            squared = temp.^2;
            average = sum(squared) / length(squared);
            RMSE = sqrt(average);
            fprintf('RMSE : %.4f', RMSE);
            
        end
        
        % Plot cost history
        function plot_cost_history(obj)
            
            epochs_vector = 1:obj.epochs;
            figure;
            plot(epochs_vector, obj.cost_history, 'r', 'LineWidth', 3)
            hold on
            plot(epochs_vector, obj.cost_history_val, 'b', 'LineWidth', 3)
            xlabel('Epochs')
            ylabel('Cost')
            title('Cost Evolution During Model Training')
            legend('Training', 'Validation')
            
        end
        
    end
    
end