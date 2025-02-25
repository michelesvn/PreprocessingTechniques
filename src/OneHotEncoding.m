%% ONE-HOT ENCODING
function data = OneHotEncoding(data)

% Note: The input dataset includes an additional first row 
% (added in the previous function) consisting only of 0s and 1s.

data = table2array(data);

% Iterate through all columns except the output column
for col = 1:(size(data, 2) - 1)

    % Check if the feature is categorical 
    % (using the first row: if the value is 1, it's categorical; otherwise, it's not)
    if data(1, col) == 1

        col_data = data(:, col);

        % Perform one-hot encoding using the 'dummyvar' function
        col_encoded = dummyvar(categorical(col_data));

        % Update the dataset with the encoded columns
        data = [data(:,1:(col-1)), col_encoded, data(:,(col+1):end)];

    end

end

% Remove the first row, as it is no longer needed
data = data(2:end, :);

data = array2table(data);

end