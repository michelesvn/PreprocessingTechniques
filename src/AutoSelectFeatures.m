%% AUTOMATIC FEATURE SELECTION
function modified_model_data = AutoSelectFeatures(model_data, ...
    threshold, kCV)

% Split train and test sets
split = (kCV-1)/kCV;
Index = ceil(size(model_data, 1) * split);
train_data = model_data(1:Index,:);
test_data = model_data(Index:end, :);

% Handle overlap
test_data(1,:) = [];

% Select the target variable column
target = train_data(:, end);

% Compute the correlation matrix between features and the target variable
% using only the training set
corr_matrix = corrcoef([train_data(:, 1:end-1), target]);

% Select columns with correlation greater than or equal to the threshold 
% concerning the target variable
selected_cols = find(abs(corr_matrix(1:end-1,end)) >= threshold);

selected_columns_count = size(selected_cols, 1);
total_columns = size(train_data, 2);

% Retrieve indexes of selected columns
selected_cols_indexes = [selected_cols', size(train_data, 2)];

% Convert to string for formatted printing
indexes_string = num2str(selected_cols_indexes, '%.0f ');

fprintf('Selected columns: %d | %d\n', selected_columns_count, ...
    total_columns);
fprintf('\nIndexes of selected columns:\n')
fprintf('%s\n', indexes_string);

% Retain only selected columns in the dataset
train_data = train_data(:, unique([selected_cols; size(train_data, 2)]));
test_data = test_data(:, unique([selected_cols; size(test_data, 2)]));

modified_model_data = [train_data; test_data];

end