%% Z-SCORE STANDARDIZATION
function standardized_data = ZScoreStandardization(data, kCV)

% Set the safety threshold
manual_mode = true;
if manual_mode == false
    threshold = 4;
else
    threshold = input(['Enter the minimum numeric threshold of unique values' ...
        ' required to justify standardizing a feature: ']);
end

% Split Train and Test (binary features are reattached at the end)
split = (kCV-1)/kCV;
Index = ceil(size(data, 1) * split);
train_data = data(1:Index, :);
test_data = data(Index:end, :);

% Handle overlap
test_data(1, :) = [];

% Identify columns to leave unchanged
invariant_columns_idx = [];

for col = 1:size(train_data, 2) - 1
    if length(unique(train_data(:, col))) <= threshold
        invariant_columns_idx = [invariant_columns_idx col];
    end
end

output_index = size(train_data, 2);
invariant_columns_idx = [invariant_columns_idx output_index];
invariant_columns_count = length(invariant_columns_idx);

% Define columns to standardize
columns_to_standardize = setdiff(1:size(train_data, 2), invariant_columns_idx);

% Construct datasets for standardizable and non-standardizable columns
invariant_data = train_data(:, invariant_columns_idx);
invariant_data_test = test_data(:, invariant_columns_idx);
standardizable_data = train_data(:, columns_to_standardize);
standardizable_data_test = test_data(:, columns_to_standardize);

% Fit phase
Mean = mean(standardizable_data);
StandardDeviation = std(standardizable_data);

% Transform phase
train_standardized = (standardizable_data - Mean) ./ StandardDeviation;
test_standardized = (standardizable_data_test - Mean) ./ StandardDeviation;

% Reconstruct dataset
train_data = [train_standardized, invariant_data];
test_data = [test_standardized, invariant_data_test];
standardized_data = [train_data; test_data];

total_columns = size(data, 2);
standardized_columns_count = length(columns_to_standardize);
fprintf('Total standardized features: %d | %d\n', standardized_columns_count, total_columns);
fprintf('Total invariant features: %d | %d\n', invariant_columns_count, total_columns);

end
