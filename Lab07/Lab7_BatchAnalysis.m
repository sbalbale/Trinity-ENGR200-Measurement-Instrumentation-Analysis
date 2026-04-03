% File: Lab7_BatchAnalysis.m
% Purpose: Batch load Lab 7 data, calculate magnitude (dB) and phase (deg),
%          plot 3 arbitrary frequency time domains, and construct a Bode Plot.
% Author: Sean Balbale
% Date: 04/03/2026

clear; clc; close all;

%% 1. Define Directories & Setup
dataDir = 'data';
figDir = 'figures';

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

results_file = 'results_lab7.txt';
fileID = fopen(results_file, 'w');
fprintf(fileID, 'Lab 7 Bode Plot Analysis Results\n');
fprintf(fileID, '================================\n\n');

% Get list of all relevant files in the data directory
filePattern = fullfile(dataDir, 'Sine_*_1.0Vpp_*_BodePlot_raw.mat');
matFiles = dir(filePattern);

if isempty(matFiles)
    error('No data files found. Ensure you have run the recording script.');
end

numFiles = length(matFiles);
freqs_recorded = zeros(numFiles, 1);
mag_dB = zeros(numFiles, 1);
phase_deg = zeros(numFiles, 1);

%% 2. Process Each File for Bode Plot Data
for i = 1:numFiles
    base_filename = matFiles(i).name;
    filename = fullfile(dataDir, base_filename);
    load(filename); % Loads 't', 'v_in', 'v_out'

    if isduration(t)
        t = seconds(t);
    end

    % Extract frequency from filename
    tokens = regexp(base_filename, 'Sine_([\d.]+)Hz', 'tokens');
    freq = str2double(tokens{1}{1});
    freqs_recorded(i) = freq;

    %% Magnitude Calculation
    rms_in = rms(v_in);
    rms_out = rms(v_out);
    % Calculate magnitude in dB: 20 * log10(Vout/Vin)
    mag_dB(i) = 20 * log10(rms_out / rms_in);

    %% Phase Calculation
    % Use findpeaks to locate signal peaks. MinPeakDistance prevents noise ripples.
    min_dist = 0.8 * (1 / freq);
    [~, locs_in] = findpeaks(v_in, t, 'MinPeakDistance', min_dist);
    [~, locs_out] = findpeaks(v_out, t, 'MinPeakDistance', min_dist);

    if length(locs_in) >= 2 && length(locs_out) >= 2
        % Find the time delay between the first peak of input and subsequent peak of output
        % For an inverting amp, output peak comes after input peak (delay)
        t_in_peak = locs_in(1);
        % Find the first output peak that occurs AFTER the first input peak
        idx_out = find(locs_out > t_in_peak, 1);

        if ~isempty(idx_out)
            dt = locs_out(idx_out) - t_in_peak;
            % Phase shift in degrees: delta_t * f * 360.
            % Output is delayed, so phase is negative.
            calc_phase =- (dt * freq * 360);

            % Normalize phase to standard -180 to 180 or 0 to -360 bounds if needed,
            % but standard raw delay calculation is robust for inverting.
            phase_deg(i) = calc_phase;
        else
            phase_deg(i) = NaN;
        end

    else
        phase_deg(i) = NaN;
    end

    % Log to file
    fprintf(fileID, 'Freq: %8.2f Hz | RMS In: %.3f V | RMS Out: %.3f V | Mag: %6.2f dB | Phase: %6.2f deg\n', ...
        freq, rms_in, rms_out, mag_dB(i), phase_deg(i));
end

fclose(fileID);

% Sort data by frequency in case files were read out of order
[freqs_recorded, sortIdx] = sort(freqs_recorded);
mag_dB = mag_dB(sortIdx);
phase_deg = phase_deg(sortIdx);

fprintf('Batch analysis complete! Extracted %d points.\n', numFiles);

%% 3. Plot 3 Arbitrary Frequencies (Low, Mid, High)
% Pick 3 indices: 1st point (lowest freq), middle point, and last point (highest freq)
indices_to_plot = [1, floor(numFiles / 2), numFiles];

fig_time = figure('Name', 'Selected Time Domain Responses', 'Position', [100, 100, 1500, 450]);

for p = 1:3
    idx = indices_to_plot(p);
    load(fullfile(dataDir, matFiles(sortIdx(idx)).name));
    if isduration(t), t = seconds(t); end

    current_freq = freqs_recorded(idx);

    subplot(1, 3, p);
    plot(t, v_in, 'k', 'LineWidth', 1.5); hold on;
    plot(t, v_out, 'b', 'LineWidth', 1.5); hold off;

    % Zoom to 3 cycles of the data
    time_for_3_cycles = 3 * (1 / current_freq);
    xlim([0, time_for_3_cycles]);

    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Signals (V)', 'FontWeight', 'bold');
    title(sprintf('Input vs Output at %.2f Hz', current_freq));
    legend('Input Sine', 'Output from System', 'Location', 'best');
    grid on;
    set(gca, 'FontSize', 12);
end

savefig(fig_time, fullfile(figDir, 'Lab7_TimeDomain_Samples.fig'));
saveas(fig_time, fullfile(figDir, 'Lab7_TimeDomain_Samples.png'));

%% 4. Plot the Full Bode Plot
fig_bode = figure('Name', 'Empirical Bode Plot', 'Position', [100, 600, 800, 600]);

% Magnitude Subplot
subplot(2, 1, 1);
% Use semilogx and distinct filled markers as requested
semilogx(freqs_recorded, mag_dB, 'ks', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
ylim([0, 40]); % Span 0 to 40 dB
xlabel('Frequency, f (Hz)', 'FontWeight', 'bold');
ylabel('Magnitude (dB)', 'FontWeight', 'bold');
title('Bode Plot');
grid on;
set(gca, 'FontSize', 12, 'XScale', 'log');

% Phase Subplot
subplot(2, 1, 2);
semilogx(freqs_recorded, phase_deg, 'ks', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
xlabel('Frequency, f (Hz)', 'FontWeight', 'bold');
ylabel('Phase (degrees)', 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 12, 'XScale', 'log');

savefig(fig_bode, fullfile(figDir, 'Lab7_BodePlot.fig'));
saveas(fig_bode, fullfile(figDir, 'Lab7_BodePlot.png'));

fprintf('Figures generated and saved to the "figures/" directory.\n');
