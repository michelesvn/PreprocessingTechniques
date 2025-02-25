%% MIN-MAX NORMALIZATION
function normalized_data = MinMaxNormalization(data, kCV)

% Set the safety threshold
manual_mode = true;
if manual_mode == false
    threshold = 2;
else
    threshold = input(['Enter the minimum numeric threshold of unique values' ...
        ' required to justify feature normalization: ']);
end

% Check the threshold
binary_cols = [];
for col = 1:size(data, 2) - 1
    if length(unique(data(:,col))) <= threshold 
        binary_cols = [binary_cols col];
    end  
end

% Include the target feature among the binary ones for convenience
output_index = size(data,2);
binary_cols = [binary_cols output_index];

% Define the columns to modify
non_binary_cols = setdiff(1:size(data,2), binary_cols);

% Construct binary and non-binary datasets
binary_data = data(:, binary_cols);
non_binary_data = data(:,non_binary_cols);

% Counter for unmodified columns
invariant_columns = length(binary_cols); % (includes the target feature)

% Split Train and Test for non-binary features (binary features are added at the end)
split = (kCV-1)/kCV;
Index = ceil(size(non_binary_data, 1) * split);
train_data = non_binary_data(1:Index,:);
test_data = non_binary_data(Index:end, :);
% (MATLAB indexing and ceil function cause one overlapping row)

% Identify indices of rows in test_data that match rows in train_data
idx = find(ismember(test_data, train_data, 'rows'));

% Remove overlapping rows from test_data
test_data(idx,:) = [];

% Fit phase
Minimum = min(train_data);
Maximum = max(train_data);

% Transform phase
train_data = (train_data - Minimum) ./ (Maximum - Minimum);
test_data = (test_data - Minimum) ./ (Maximum - Minimum);

% Reconstruct the normalized non-binary dataset
normalized_non_binary_data = [train_data; test_data];

% Reconstruct the fully normalized dataset
normalized_data = [normalized_non_binary_data binary_data];

total_columns = size(data, 2);
normalized_columns = length(non_binary_cols);

fprintf('Total normalized features: %d | %d\n', normalized_columns, ...
    total_columns);
fprintf('Total invariant features: %d | %d\n', invariant_columns, ...
    total_columns);

end