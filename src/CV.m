%% CROSS VALIDATION
function [X_train, y_train, X_val, y_val] = CV(X, Y, j, fold_size, max)
    
    % Create a vector of indices from 1 to end (row-wise), advancing by 1 per step
    indices_row = linspace(1, size(X,1), size(X,1))';
    indices_row = indices_row / 10; % (MATLAB limit)

    X = [indices_row, X];
    Y = [indices_row, Y];
    
    % Identify the start and end indices for the validation set
    startVal = j * fold_size + 1;
    endVal = (j+1) * fold_size;
    
    % Handle the initial index 1
    if j == max
        % Hard fix for end index due to rounding (and +1)
        endVal = size(X,1);
    end

    % Define validation sets
    X_val = X(startVal:endVal, :);
    y_val = Y(startVal:endVal, :);

    % Use the setdiff function to find rows in A that are not present in B
    Xrows_to_keep = setdiff(1:size(X,1), find(ismember(X,X_val,'rows')));
    X_train = X(Xrows_to_keep, 2:end);
    
    Yrows_to_keep = setdiff(1:length(Y), find(ismember(Y,y_val,'rows')));
    y_train = Y(Yrows_to_keep, 2);
    
    X_val = X_val(:, 2:end);
    y_val = y_val(:, 2);

end