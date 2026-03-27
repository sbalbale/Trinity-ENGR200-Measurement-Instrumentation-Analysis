% Script to convert all *_raw.mat files to CSV format

inputDir = 'data';
outputDir = 'csv';

% Create output directory if it doesn't exist
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Get a list of all .mat files ending with _raw.mat in the input directory
fileList = dir(fullfile(inputDir, '*_raw.mat'));

fprintf('Found %d files to convert.\n', length(fileList));

for i = 1:length(fileList)
    matFilename = fileList(i).name;
    matFilePath = fullfile(inputDir, matFilename);

    % Create CSV filename by replacing .mat with .csv
    [~, baseName, ~] = fileparts(matFilename);
    csvFilename = [baseName '.csv'];
    csvFilePath = fullfile(outputDir, csvFilename);

    fprintf('Processing %s...\n', matFilename);

    % Load the data into a structure
    data = load(matFilePath);

    % Check for 't' and 'v' variables
    if isfield(data, 't') && isfield(data, 'v')
        t = data.t;
        v = data.v;

        % Ensure 't' and 'v' are column vectors
        if isrow(t)
            t = t';
        end

        if isrow(v)
            v = v';
        end

        % Convert duration objects to seconds if necessary
        if isduration(t)
            t_sec = seconds(t);
        elseif isdatetime(t)
            % Handle case if t is datetime (less likely but possible)
            t_sec = seconds(t - t(1));
        else
            t_sec = t;
        end

        % Create a table with appropriate headers
        T = table(t_sec, v, 'VariableNames', {'Time_s', 'Voltage_V'});

        % Write the table to a CSV file
        writetable(T, csvFilePath);
        fprintf('  Saved to %s\n', csvFilename);
    else
        fprintf('  Skipping %s: Missing ''t'' or ''v'' variables.\n', matFilename);
    end

end

fprintf('All conversions complete.\n');
