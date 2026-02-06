% File: multianalysis.m
% Purpose: Analyze voltage data from multiple CSV files, calculate uncertainties, and visualize results.
% Author: Sean Balbale
% Date: 02/06/2026

clear; clc; close all;

% List of files to process
files = { ...
    'Lab3_Data_Floating_N50.csv', ...
    'Lab3_Data_Floating_N200.csv', ...
    'Lab3_Data_Floating_N300.csv', ...
    'Lab3_Data_Stable_N200.csv', ...
    'Lab3_Data_Stable_N300.csv' ...
};

% System Parameters
V_ref = 5.0; % Reference voltage in Volts
ADC_max = 1023; % Max ADC count
resolution_voltage = V_ref / ADC_max; % Resolution

% Type B Uncertainty (Constant for all)
% u_B = resolution / sqrt(12)
u_type_B = resolution_voltage / sqrt(12);

% Open output file
fid = fopen('results.txt', 'w');

fprintf('--- Global Parameters ---\n');
fprintf(fid, '--- Global Parameters ---\n');
fprintf('ADC Resolution: %.5f V\n', resolution_voltage);
fprintf(fid, 'ADC Resolution: %.5f V\n', resolution_voltage);
fprintf('Resolution Uncertainty (u_B): %.5f V\n', u_type_B);
fprintf(fid, 'Resolution Uncertainty (u_B): %.5f V\n', u_type_B);
fprintf('-------------------------\n');
fprintf(fid, '-------------------------\n');

% Iterate through each file
for i = 1:length(files)
    filename = files{i};
    fprintf('\nProcessing File: %s\n', filename);
    fprintf(fid, '\nProcessing File: %s\n', filename);
    
    try
        data = readmatrix(filename);
        
        % Extract columns (assuming Column 1 is Time, Column 2 is ADC Value)
        adc_counts = data(:, 2);
        N = length(adc_counts); % Number of samples

        % Convert ADC counts to Voltage
        % Formula: Voltage = (ADC_Value / 1023) * V_ref
        voltages = (adc_counts / ADC_max) * V_ref;

        % Statistical Analysis (Type A Uncertainty)
        mean_voltage = mean(voltages);
        std_dev = std(voltages); 

        % Standard Uncertainty of the Mean (Type A)
        % u_A = s / sqrt(N)
        u_type_A = std_dev / sqrt(N);

        % Combined Uncertainty
        % Combine independent sources using root-sum-square
        u_combined = sqrt(u_type_A^2 + u_type_B^2);

        % Display Results
        fprintf('  Number of Samples (N): %d\n', N);
        fprintf(fid, '  Number of Samples (N): %d\n', N);
        fprintf('  Mean Voltage: %.4f V\n', mean_voltage);
        fprintf(fid, '  Mean Voltage: %.4f V\n', mean_voltage);
        fprintf('  Standard Deviation: %.4f V\n', std_dev);
        fprintf(fid, '  Standard Deviation: %.4f V\n', std_dev);
        fprintf('  Uncertainty of the Mean (u_A): %.5f V\n', u_type_A);
        fprintf(fid, '  Uncertainty of the Mean (u_A): %.5f V\n', u_type_A);
        fprintf('  Combined Standard Uncertainty (u_c): %.5f V\n', u_combined);
        fprintf(fid, '  Combined Standard Uncertainty (u_c): %.5f V\n', u_combined);

        % Visualization
        figure('Name', filename);
        plot(voltages, 'b.');
        hold on;
        yline(mean_voltage, 'r-', 'LineWidth', 2);
        xlabel('Sample Number');
        ylabel('Voltage (V)');
        title(['Measured Voltage: ' strrep(filename, '_', '\_')]);
        legend('Measured Data', 'Mean');
        grid on;
        
    catch ME
        fprintf('  Error processing file %s: %s\n', filename, ME.message);
        fprintf(fid, '  Error processing file %s: %s\n', filename, ME.message);
    end
end

fclose(fid);
