%% SEGMENT DATASET
function [model_data, unseen_data] = SegmentDataset(data)

% Convert the data table into a matrix
data = table2array(data);

% Find the first NaN value in SalePrice
target_variable = data(:, end);
for sample = 1:size(data, 1)
    if isnan(target_variable(sample))
        break
    end
end

% Split the data matrix into two separate matrices: one for training the model
% and another for applying the model
model_data = data(1:sample-1, :);
unseen_data = data(sample:end, :);

end