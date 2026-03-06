% File: Lab4_Analysis.m
% Purpose: Load saved waveform data, calculate metrics, and generate paired time/frequency plots.
% Author: Sean Balbale
% Date: 03/06/2026

%% 1. Define file to load (update this for each of your 8 files)
filename = 'Sine_7Hz_5.0Vpp_0.0Voffset_raw.mat'; 
load(filename); % This loads your saved 't' and 'v' arrays

% Parameters (Update these to match the loaded file)
wave_type = 'Sine';
freq = 7; 
fs = 2000; % Sampling frequency used during collection

%% 2. Calculations
mean_v = mean(v); 
rms_v = rms(v); 
dc_offset = mean_v; % DC offset is represented by the mean voltage

fprintf('--- Analysis for %s ---\n', filename);
fprintf('Mean Voltage: %.4f V\n', mean_v);
fprintf('RMS Voltage: %.4f V\n', rms_v);
fprintf('DC Offset: %.4f V\n\n', dc_offset);

%% 3. Create Side-by-Side Figure
figure('Position', [100, 100, 1000, 400]); % Makes the window wide for side-by-side plots

% Subplot A: Time Domain
subplot(1, 2, 1);
plot(t, v, 'LineWidth', 2); % Thick line for visibility
time_for_3_cycles = 3 / freq; 
xlim([0, time_for_3_cycles]); % Set x-limits to show exactly 3 complete cycles
xlabel('Time (s)', 'FontWeight', 'bold');
ylabel('Voltage (V)', 'FontWeight', 'bold');
title(sprintf('Time Domain: %s Wave (%d Hz)', wave_type, freq)); 
grid on;
set(gca, 'FontSize', 12); % Ensure text is large enough

% Subplot B: Frequency Domain (Spectral Content)
subplot(1, 2, 2);
[pxx, f_out] = pwelch(v, [], [], [], fs); 

% Note: Change 'semilogy' to 'plot' if you decide a linear y-axis looks better for your analysis
semilogy(f_out, pxx, 'LineWidth', 2); 
xlim([0, freq * 10]); % x-axis limited to 10 times higher than the wave frequency
xlabel('Frequency (Hz)', 'FontWeight', 'bold');
ylabel('Power Spectral Density', 'FontWeight', 'bold');
title(sprintf('Spectral Content: %s Wave', wave_type)); 
grid on;
set(gca, 'FontSize', 12); % Ensure text is large enough