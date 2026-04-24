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

    % Check for 't', 'step_signal', and 'v_out' variables
    if isfield(data, 't') && isfield(data, 'step_signal') && isfield(data, 'v_out')
        t = data.t;
        v_in = data.step_signal;
        v_out = data.v_out;

        % Ensure 't' and 'v' are column vectors
        if isrow(t)
            t = t';
        end

        if isrow(v_in)
            v_in = v_in';
        end

        if isrow(v_out)
            v_out = v_out';
        end

        % Convert duration objects to seconds if necessary
        if isduration(t)
            t_sec = seconds(t);
        elseif isdatetime(t)
            t_sec = seconds(t - t(1));
        else
            t_sec = t;
        end

        % Create a table with appropriate headers (omitting the scalar fs)
        T = table(t_sec, v_in, v_out, 'VariableNames', {'Time_s', 'Input_Voltage_V', 'Output_Voltage_V'});

        % Write the table to a CSV file
        writetable(T, csvFilePath);
        fprintf('  Saved to %s\n', csvFilename);
    else
        fprintf('  Skipping %s: Missing ''t'', ''step_signal'', or ''v_out'' variables.\n', matFilename);
    end

end

fprintf('All conversions complete.\n');