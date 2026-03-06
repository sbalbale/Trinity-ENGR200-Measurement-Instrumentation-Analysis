% File: Batch_Analysis.m
% Purpose: Batch analyze all .mat files in the directory locally
% Author: Sean Balbale
% Date: 03/06/2026

clear; clc;

% Open results file
outfile = 'results.txt';
fid = fopen(outfile, 'w');

% Get all .mat files in the current directory
files = dir('data/*.mat');

% Loop through each file
for i = 1:length(files)
    filename = files(i).name;
    
    try
        % Load the file
        data = load(filename);
        
        % Check if 'v' variable exists in the loaded file
        if isfield(data, 'v')
            v = data.v;
            
            % Calculations
            mean_v = mean(v);
            rms_v = rms(v);
            dc_offset = mean_v; % DC offset is represented by the mean voltage
            
            % Print results in the requested format
            fprintf('--- Analysis for %s ---\n', filename);
            fprintf('Mean Voltage: %.4f V\n', mean_v);
            fprintf('RMS Voltage: %.4f V\n', rms_v);
            fprintf('DC Offset: %.4f V\n\n', dc_offset);
            
            % Write to file
            fprintf(fid, '--- Analysis for %s ---\n', filename);
            fprintf(fid, 'Mean Voltage: %.4f V\n', mean_v);
            fprintf(fid, 'RMS Voltage: %.4f V\n', rms_v);
            fprintf(fid, 'DC Offset: %.4f V\n\n', dc_offset);
        else
            fprintf('Warning: Variable ''v'' not found in %s\n\n', filename);
        end
        
    catch ME
        fprintf('Error processing %s: %s\n\n', filename, ME.message);
    end
end

fclose(fid);
fprintf('Results saved to %s\n', outfile);
