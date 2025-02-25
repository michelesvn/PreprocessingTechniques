%% SPLIT DATASET
function [X_train, y_train, X_val, y_val, X_test, y_test] = ...
    SplitDataset(data)

% Compute indices for dataset splitting
MaxValidationIndex = ceil(size(data, 1) * 0.80);
MaxTrainIndex = ceil(MaxValidationIndex * 0.75);

% Split the dataset into training, validation, and test sets
X_train = data(1 : MaxTrainIndex, 1:end-1);
y_train = data(1 : MaxTrainIndex, end);

X_val = data(MaxTrainIndex + 1 : MaxValidationIndex, 1:end-1);
y_val = data(MaxTrainIndex + 1 : MaxValidationIndex, end);

X_test = data(MaxValidationIndex + 1 : end, 1:end-1);
y_test = data(MaxValidationIndex + 1 : end, end);

end