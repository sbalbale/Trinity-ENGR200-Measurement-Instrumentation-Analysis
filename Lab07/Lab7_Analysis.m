% File: Lab7_SingleAnalysis.m
% Purpose: Analyze a single dataset from Lab 7 to calculate gain, magnitude (dB),
%          and phase (degrees), and display the time-domain plot.
% Author: Sean Balbale
% Date: 04/03/2026

clear; clc; close all;

%% 1. Define File to Analyze
dataDir = 'data';
% Replace this filename with the specific trial you want to analyze
filename = 'Sine_1.00Hz_1.0Vpp_fs100000_BodePlot_raw.mat';
full_path = fullfile(dataDir, filename);

if ~isfile(full_path)
    error('File %s not found. Please check the filename and directory.', full_path);
end

%% 2. Load Data
load(full_path); % Loads 't', 'v_in', 'v_out'

if isduration(t)
    t = seconds(t);
end

% Extract frequency from the filename automatically
tokens = regexp(filename, 'Sine_([\d.]+)Hz', 'tokens');

if ~isempty(tokens)
    freq = str2double(tokens{1}{1});
else
    % Fallback if the filename format is different
    freq = input('Could not extract frequency from filename. Enter frequency (Hz): ');
end

%% 3. Calculations
% RMS and Magnitude
rms_in = rms(v_in);
rms_out = rms(v_out);
mag_dB = 20 * log10(rms_out / rms_in);

% Phase Calculation
% Using 80% of the period as the minimum peak distance to ignore noise ripples
min_dist = 0.8 * (1 / freq);
[~, locs_in] = findpeaks(v_in, t, 'MinPeakDistance', min_dist);
[~, locs_out] = findpeaks(v_out, t, 'MinPeakDistance', min_dist);

if length(locs_in) >= 2 && length(locs_out) >= 2
    % Time of the first input peak
    t_in_peak = locs_in(1);

    % Find the first output peak that occurs AFTER the first input peak
    idx_out = find(locs_out > t_in_peak, 1);

    if ~isempty(idx_out)
        dt = locs_out(idx_out) - t_in_peak;
        % Convert time delay to degrees (negative because output is delayed)
        phase_deg =- (dt * freq * 360);
    else
        phase_deg = NaN;
        warning('Could not find a valid delayed output peak for phase calculation.');
    end

else
    phase_deg = NaN;
    warning('Not enough peaks found. Check your signal or sampling time.');
end

%% 4. Display Results
fprintf('--- Analysis for Single Trial: %.2f Hz ---\n', freq);
fprintf('File: %s\n', filename);
fprintf('Input RMS:   %.4f V\n', rms_in);
fprintf('Output RMS:  %.4f V\n', rms_out);
fprintf('Magnitude:   %.2f dB\n', mag_dB);
fprintf('Phase Shift: %.2f deg\n\n', phase_deg);

%% 5. Plot Data (3 Cycles)
figure('Name', sprintf('Single Trial Analysis - %.2f Hz', freq), 'Position', [200, 200, 800, 400]);

% Plot input in black, output in blue to match standard Bode plotting colors
plot(t, v_in, 'k', 'LineWidth', 1.5); hold on;
plot(t, v_out, 'b', 'LineWidth', 1.5); hold off;

% Zoom the x-axis to exactly 3 cycles
time_for_3_cycles = 3 * (1 / freq);
xlim([0, time_for_3_cycles]);

xlabel('Time (s)', 'FontWeight', 'bold');
ylabel('Signals (V)', 'FontWeight', 'bold');
title(sprintf('Input vs Output at %.2f Hz', freq));
legend('Input Sine', 'Output from System', 'Location', 'best');
grid on;
set(gca, 'FontSize', 12);
