%% HANDLE OUTLIERS
function model_data = HandleOutliers(model_data, option, on_off)

% on = 1
% off = 0
if on_off == 1
    % Display a boxplot of the data including outliers
    figure() 
    title('Boxplot of the dataset (including outliers)')
    boxplot(model_data(:, 1:end-1));
    warning('off');
end
    
manual_mode = true;
if manual_mode == false
    % Set the maximum number of outliers per row before considering it an outlier
    threshold = 1; 

    % Set the step size for computing the non-outlier zone limits
    stepSize = 2; 

    % Set the minimum number of unique values required in a column 
    % to apply outlier removal
    unique_values_limit = 5;
else
    threshold = input("Enter the minimum number of outliers per row " + ...
        "to justify handling the example: ");
    stepSize = input("Enter the stepSize to consider in IQR calculation: ");
    unique_values_limit = input("Enter the minimum number of unique values " + ...
        "a column must have to be included in the analysis: ");
    
    fprintf('Set threshold: %.3f\n', threshold);
    fprintf('Set stepSize: %.3f\n', stepSize);
    fprintf('Set unique values limit: %.3f\n', unique_values_limit);
end

% Identify columns to exclude based on the unique values limit
excluded_columns = [];

for col = 1:size(model_data, 2)-1
    if length(unique(model_data(:,col))) <= unique_values_limit
        excluded_columns = [excluded_columns col];
    end
end

% Include the target feature as an excluded column
output_index = size(model_data,2);
excluded_columns = [excluded_columns output_index];

% Identify columns to be considered for outlier handling
columns_to_process = setdiff(1:size(model_data,2), excluded_columns);

% Split data into processable and excluded parts
data_to_process = model_data(:,columns_to_process);
data_excluded = model_data(:, excluded_columns); 

% Compute non-outlier zone limits
Q1 = prctile(data_to_process, 25);
Q3 = prctile(data_to_process, 75);
IQR = Q3 - Q1;
lim_inf = Q1 - stepSize * IQR;
lim_sup = Q3 + stepSize * IQR;
    
% Identify outliers
outliers = data_to_process < lim_inf | data_to_process > lim_sup;
% (Returns a matrix of 1s and 0s, where 1 indicates an outlier)

% Count the number of outliers in each column
outliers_count_col = sum(outliers, 1);

% Remove columns with more than 50 outliers
columns_to_keep = [];

for col = 1:size(data_to_process, 2)
    if outliers_count_col(col) < 50
        columns_to_keep = [columns_to_keep col];
    end           
end

% Update the dataset to retain only columns with fewer than 50 outliers
% (Columns with excessive outliers are complex to handle and deemed unstable,
% so for simplicity, they are completely removed)
data_to_process = data_to_process(:, columns_to_keep);
model_data = [data_to_process data_excluded];

% Modify the outliers matrix to exclude columns with more than 50 outliers
outliers = outliers(:, columns_to_keep);

% Count the number of outliers in each row
outliers_count = sum(outliers, 2);

% Handle row-wise outliers based on the chosen option
if strcmpi(option, 'elimination')
    outliers_rows = outliers_count > threshold; % e.g., threshold = 3 -> remove rows with 4+ outliers
    model_data(outliers_rows, :) = [];
        
elseif strcmpi(option, 'substitution')
    % Use stored column indices and outliers matrix to identify and replace outliers
    for idx_col = 1:length(columns_to_keep)
        col = columns_to_keep(idx_col);
        for row = 1:size(outliers, 1)
            if outliers(row, idx_col) == 1
                model_data(row, col) = mean(model_data(:,col));
            end
        end
    end
end

% Handle empty rows due to combined outlier handling and one-hot encoding
columns = [];

for col = 1:size(model_data, 2)
    column_data = model_data(:, col);
    column_sum = sum(column_data);

    if column_sum <= 1
        columns = [columns col];
    end
end

model_data(:, columns) = [];

end