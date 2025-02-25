%% HANDLE MISSING VALUES
function data = HandleMissingValues(data)
    
% Set the option to automate threshold selection
manual_mode = true;

if manual_mode == true
    threshold = input(['Enter the maximum percentage threshold of ' ...
                    'NaN values beyond which a feature should be discarded: ']);
else
    threshold = 5;
end

% Compute the percentage of NaN values per column
nan_percentage_per_column = sum(isnan(table2array(data)), 1) / ...
    size(data,1) * 100;

% Create a histogram of NaN values per column
bar(nan_percentage_per_column, 'stacked');
xlabel('Column');
ylabel('Number of NaN values');
title('Number of NaN values per column');

% Add a horizontal line at the threshold value on the y-axis
hold on
yline(threshold, '--r', 'LineWidth', 1.5);
hold off

% Initialize the list of columns to be removed
columns_to_remove = [];

for col = 1:(size(data, 2) - 1)

    % Compute the number of NaN values in the column
    n_nan = sum(isnan(data{:, col}));

    % Compute the percentage of NaN values in the column
    p_nan = n_nan / height(data) * 100;

    % Add the column to the removal list if the percentage exceeds the threshold
    if p_nan > threshold
        columns_to_remove = [columns_to_remove col];
    end

end

% Remove selected columns
data(:,columns_to_remove) = [];

% Identify rows with more than 4 NaN values
rows_to_remove = [];

for row = 1:(size(data, 1))
    % Count the number of NaN values in the row
    n_nan = sum(isnan(data{row, :}));

    % Add the row to the removal list if the count exceeds 4
    if n_nan > 4
        rows_to_remove = [rows_to_remove row];
    end
end   

% Remove rows with more than 4 NaN values
data(rows_to_remove,:) = [];

% Identify rows corresponding to NaN values in categorical features
rows_to_remove = [];

for col = 1:(size(data, 2) - 1)
    if data{1, col} == 1
        for row = 1:(size(data, 1))
            if isnan(data{row, col})
                rows_to_remove = [rows_to_remove row];
            end
        end
    end
end

% Remove rows corresponding to NaN values in categorical features
data(rows_to_remove,:) = [];

% Replace remaining NaN values with the column mean
for col = 1:(size(data, 2) - 1)
    % Count the number of NaN values in the column
    n_nan = sum(isnan(data{:, col}));

    if n_nan > 0
        column_data = table2array(data(:,col));
        mean_col = mean(column_data,'all',"omitnan");

        for sample = 1:size(column_data, 1)
            if isnan(column_data(sample))
                data{sample, col} = mean_col;
            end
        end
    end
end

end