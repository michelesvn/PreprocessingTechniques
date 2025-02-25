%% CONVERT CATEGORICAL FEATURES
function data = ConvertCategoricalFeatures(data)

indices = [];

% Loop through each column of the dataset
for col = 1:size(data, 2)

    % Check if the column is a cell array and contains string data, 
    % meaning it is a categorical feature
    if iscell(data{:, col}) && ...
            ischar(data.Properties.VariableNames{col})

        % Track categorical features
        indices = [indices 1];
                    
        column_data = data{:, col};

        % Track unique values in the column
        unique_values = unique(column_data);

        % Check if the column contains 'NA' values
        if any(strcmp(data{:,col}, 'NA'))

            % Remove 'NA' from the list of unique values
            unique_values(strcmp(unique_values, 'NA')) = [];

            % Append 'NA' to the end of the list of unique values
            unique_values = cat(1, unique_values, 'NA');

            % Create an empty variable with the same size as the column
            numeric_column = zeros(size(column_data));

            % Loop through each row in the column
            for i = 1:numel(column_data)

                % Check if the current value is 'NA'
                if strcmp(column_data{i}, 'NA')
                        
                    % Assign NaN to the current position
                    numeric_column(i) = NaN;

                else

                    % Find the index of the unique value corresponding 
                    % to the current element
                    idx = find(strcmp(unique_values, column_data{i}));

                    % Assign the index to the current position
                    numeric_column(i) = idx;
                        
                end

            end

        % If there are no 'NA' values in the column
        else

            % Create an empty variable with the same size as the column
            numeric_column = zeros(size(column_data));

            % Loop through each row in the column
            for i = 1:numel(column_data)

                % Find the index of the unique value corresponding 
                % to the current element
                idx = find(strcmp(unique_values, column_data{i}));

                % Assign the index to the current position
                numeric_column(i) = idx;
                    
            end

        end

        % Replace the column with the new numeric column
        data.(data.Properties.VariableNames{col}) = numeric_column;

    else
        
        indices = [indices 0];

    end

end

data = table2array(data);

data = [indices; data]; 

data = array2table(data);

end