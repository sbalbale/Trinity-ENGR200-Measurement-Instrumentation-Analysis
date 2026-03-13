% File: Lab5_Analysis.m
% Purpose: Load saved Lab 5 data, generate side-by-side time/frequency plots showing 5 cycles and Nyquist limits.
% Author: Sean Balbale
% Date: 03/13/2026

clear; clc; close all;

%% 1. Define Files to Analyze
% Uncomment the section corresponding to the task you want to analyze.

% --- Task 1: Sine Wave Frequency Sweeps (Select 4 across the range) ---
files_to_analyze = {
    'Sine_500Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_600Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_700Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_800Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_900Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_1000Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_1100Hz_5.000Vpp_fs2000_raw.mat';
    'Sine_1200Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_1300Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_1400Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_1500Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_1600Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_1700Hz_5.000Vpp_fs2000_raw.mat';
    'Sine_1800Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_1900Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_2000Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_2100Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_2200Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_2300Hz_5.000Vpp_fs2000_raw.mat';
    % 'Sine_2400Hz_5.000Vpp_fs2000_raw.mat';
    'Sine_2500Hz_5.000Vpp_fs2000_raw.mat'
};

% --- Task 2: Small Amplitude Resolution Test ---
% files_to_analyze = {
%     'Sine_100Hz_0.050Vpp_fs10000_raw.mat';
%     'Sine_100Hz_0.020Vpp_fs10000_raw.mat';
%     'Sine_100Hz_0.010Vpp_fs10000_raw.mat';
%     'Sine_100Hz_0.002Vpp_fs10000_raw.mat'
% };

% --- Task 3: Sampling Rate Effects on Saw Wave ---
% files_to_analyze = {
%     'Saw_173Hz_5.000Vpp_fs500_raw.mat';
%     'Saw_173Hz_5.000Vpp_fs1000_raw.mat';
%     'Saw_173Hz_5.000Vpp_fs2000_raw.mat';
%     'Saw_173Hz_5.000Vpp_fs5000_raw.mat'
% };


%% 2. Loop Through and Analyze Each File
for i = 1:length(files_to_analyze)
    base_filename = files_to_analyze{i};
    filename = fullfile('data', base_filename);
    
    % Check if file exists before proceeding
    if ~isfile(filename)
        fprintf('Warning: File %s not found. Skipping...\n', filename);
        continue;
    end
    
    load(filename); % Loads 't' and 'v'
    
    % Extract parameters from the filename for plot titles and calculations
    % Assumes format: WaveType_FreqHz_VppVpp_fs[fs]_raw.mat
    parsed = textscan(base_filename, '%[a-zA-Z]_%dHz_%fVpp_fs%d_raw.mat');
    wave_type = parsed{1}{1};
    freq = parsed{2};
    vpp = parsed{3};
    fs = parsed{4};
    
    % Convert duration array to double (seconds) to prevent xlim errors
    if exist('t', 'var') && isduration(t)
        t = seconds(t);
    end
    
    % Calculate Nyquist frequency
    nyquist_freq = fs / 2;
    
    %% 3. Create Side-by-Side Figure
    figure('Name', filename, 'Position', [100+(i*20), 100+(i*20), 1000, 400]); 
    
    % Subplot A: Time Domain (Limit to 5 cycles)
    subplot(1, 2, 1);
    plot(t, v, 'LineWidth', 1.5); 
    
    % Calculate time for 5 cycles of the input frequency
    time_for_5_cycles = 5 / freq; 
    xlim([0, time_for_5_cycles]); 
    
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Voltage (V)', 'FontWeight', 'bold');
    title(sprintf('Time Domain: %s %d Hz (fs = %d Hz)', wave_type, freq, fs)); 
    grid on;
    set(gca, 'FontSize', 12); 
    
    % Subplot B: Frequency Domain (Spectral Content via pwelch)
    subplot(1, 2, 2);
    [pxx, f_out] = pwelch(v, [], [], [], fs); 
    
    semilogy(f_out, pxx, 'LineWidth', 1.5); 
    
    % Limit frequency axis to the Nyquist frequency
    xlim([0, nyquist_freq]); 
    
    xlabel('Frequency (Hz)', 'FontWeight', 'bold');
    ylabel('Power Spectral Density', 'FontWeight', 'bold');
    title(sprintf('Spectral Content (Nyquist limit: %d Hz)', nyquist_freq)); 
    grid on;
    set(gca, 'FontSize', 12); 
    
    %% 4. Save Figure Automatically
    figDir = 'figures';
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end
    
    % Save as .fig for conversion script
    % Removes the '_raw.mat' from the filename for the output figure name
    figFilename = fullfile(figDir, [base_filename(1:end-8), '.fig']);
    savefig(gcf, figFilename);
    
    fprintf('Processed and generated plots for: %s\n', filename);
end

fprintf('\nAnalysis complete. Figures saved to the "figures" directory.\n');