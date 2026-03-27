% File: Lab6_BatchAnalysis.m
% Purpose: Batch load Lab 6 data, calculate RMS and gain, output to results.txt
%          AND the command window, and visibly display all plots for examination.
% Author: Sean Balbale
% Date: 03/27/2026

clear; clc; close all;

%% 1. Define Resistor Values for Theoretical Calculations
% Input your measured or nominal resistor values here (in Ohms)
R1 = 1000; % Must be >= 1k Ohm
R2_Task1 = 1000;
R2_Task2 = 10000;
tolerance = 0.05; % 5 % tolerance

%% 2. Define Files to Analyze
% All tasks uncommented for batch processing
files_to_analyze = {
                    'Sine_200Hz_10.0Vpp_fs10000_Task1_Gain1_raw.mat';
                    'Sine_200Hz_10.0Vpp_fs10000_Task2_Gain10_Large_raw.mat';
                    'Sine_200Hz_0.5Vpp_fs10000_Task3_Gain10_Small_raw.mat';
                    'Sine_200Hz_0.5Vpp_fs10000_Task4_Supply_3pm_raw.mat';
                    'Sine_200Hz_0.5Vpp_fs10000_Task4_Supply_1pm_raw.mat';
                    'Sine_200Hz_0.5Vpp_fs10000_Task4_Supply_11am_raw.mat';
                    'Sine_200Hz_0.5Vpp_fs10000_Task4_Supply_9am_raw.mat';
                    };

%% 3. Setup Results Text File
results_file = 'results.txt';
fileID = fopen(results_file, 'w'); % Open file for writing ('w' overwrites existing)

fprintf(fileID, 'Lab 6 Batch Analysis Results\n');
fprintf(fileID, '============================\n\n');
fprintf('Batch processing started. Writing numerical results to %s...\n', results_file);

%% 4. Loop Through and Analyze Each File
for i = 1:length(files_to_analyze)
    base_filename = files_to_analyze{i};
    filename = fullfile('data', base_filename);

    if ~isfile(filename)
        fprintf('Warning: File %s not found in data/. Skipping...\n', filename);
        fprintf(fileID, 'Warning: File %s not found. Skipped.\n\n', filename);
        continue;
    end

    load(filename); % Loads 't', 'v_in', and 'v_out'

    % Convert duration array to double (seconds)
    if exist('t', 'var') && isduration(t)
        t = seconds(t);
    end

    % Extract parameters from filename
    tokens = regexp(base_filename, '([a-zA-Z]+)_(\d+)Hz_([\d.]+)Vpp_fs(\d+)_([a-zA-Z0-9_]+)_raw\.mat', 'tokens');
    wave_type = tokens{1}{1};
    freq = str2double(tokens{1}{2});
    vpp = str2double(tokens{1}{3});
    fs = str2double(tokens{1}{4});
    task_name = strrep(tokens{1}{5}, '_', ' ');

    %% Calculations: RMS and Empirical Gain
    rms_in = rms(v_in);
    rms_out = rms(v_out);
    empirical_gain = rms_out / rms_in;

    % Print to Command Window
    fprintf('\n--- Analysis for %s ---\n', task_name);
    fprintf('File: %s\n', base_filename);
    fprintf('Input RMS: %.3f V\n', rms_in);
    fprintf('Output RMS: %.3f V\n', rms_out);
    fprintf('Measured Gain (Magnitude): %.3f\n', empirical_gain);

    % Write to Results Text File
    fprintf(fileID, '--- Analysis for %s ---\n', task_name);
    fprintf(fileID, 'File: %s\n', base_filename);
    fprintf(fileID, 'Input RMS: %.3f V\n', rms_in);
    fprintf(fileID, 'Output RMS: %.3f V\n', rms_out);
    fprintf(fileID, 'Measured Gain (Magnitude): %.3f\n\n', empirical_gain);

    %% 5. Create Plots (Visible for Inspection)
    % Removed 'Visible', 'off'. Added a slight offset so windows cascade.
    fig = figure('Name', filename, 'Position', [100 + i * 20, 100 + i * 20, 1400, 450]);

    % Subplot A: Time Domain (Limit to 4 cycles)
    subplot(1, 3, 1);
    plot(t, v_in, 'b', 'LineWidth', 1.5); hold on;
    plot(t, v_out, 'r', 'LineWidth', 1.5); hold off;

    % Zoom to 4 cycles of the data
    time_for_4_cycles = 4 * (1 / freq);
    xlim([0, time_for_4_cycles]);

    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Voltage (V)', 'FontWeight', 'bold');
    title('Time Domain (4 Cycles)');
    legend('Input Signal', 'Amplified Output', 'Location', 'best');
    grid on;
    set(gca, 'FontSize', 12);

    % Subplot B: Spectral Content - Input Signal
    subplot(1, 3, 2);
    [pxx_in, f_out] = pwelch(v_in, [], [], [], fs);
    semilogy(f_out, pxx_in, 'b', 'LineWidth', 1.5);
    xlim([0, 1000]); % Limit x-axis to highlight the 200Hz peak and early harmonics
    xlabel('Frequency (Hz)', 'FontWeight', 'bold');
    ylabel('PSD', 'FontWeight', 'bold');
    title('Spectral Content: Input');
    grid on;
    set(gca, 'FontSize', 12);

    % Subplot C: Spectral Content - Output Signal
    subplot(1, 3, 3);
    [pxx_out, ~] = pwelch(v_out, [], [], [], fs);
    semilogy(f_out, pxx_out, 'r', 'LineWidth', 1.5);
    xlim([0, 1000]);
    xlabel('Frequency (Hz)', 'FontWeight', 'bold');
    ylabel('PSD', 'FontWeight', 'bold');
    title('Spectral Content: Output');
    grid on;
    set(gca, 'FontSize', 12);

    % Save Figures
    figDir = 'figures';

    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end

    % Strip the trailing '_raw.mat' for the image name
    clean_name = base_filename(1:end - 8);

    % Still save copies to the folder so you have them for the report
    savefig(fig, fullfile(figDir, [clean_name, '.fig']));
    saveas(fig, fullfile(figDir, [clean_name, '.png']));

end

%% 6. Cleanup
fclose(fileID); % Close the text file
fprintf('\nBatch analysis complete!\n');
fprintf(' - Figures saved to the "figures/" directory.\n');
fprintf(' - Numerical data saved to "%s".\n', results_file);
