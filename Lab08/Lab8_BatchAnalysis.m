% File: Lab8_BatchAnalysis.m
% Purpose: Batch load Lab 8 data, calculate magnitude (dB) and phase (deg),
%          save results to a text file, plot specific frequency time domains,
%          and construct a Bode Plot.
% Author: Sean Balbale
% Date: Spring 2026

clear; clc; close all;

%% 1. Define Directories & Setup
fc = 75; % Update this to your designed cutoff frequency in Hz
specific_freqs = [fc/10, fc, 10*fc]; 

dataDir = 'data';
figDir = 'figures';

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

% Initialize Results Text File
results_file = 'results_lab8.txt';
fileID = fopen(results_file, 'w');
fprintf(fileID, 'Lab 8 Active Filter Bode Plot Analysis Results\n');
fprintf(fileID, '==============================================\n\n');
fprintf(fileID, 'Designed Cutoff Frequency (fc): %.2f Hz\n', fc);
fprintf(fileID, '----------------------------------------------\n\n');

% Get list of all relevant files in the data directory
filePattern = fullfile(dataDir, 'Sine_*Hz_1.0Vpp_*_ActiveFilter_raw.mat');
matFiles = dir(filePattern);

if isempty(matFiles)
    error('No data files found. Ensure you have run the Lab8_RecordData script.');
end

numFiles = length(matFiles);
freqs_recorded = zeros(numFiles, 1);
mag_dB = zeros(numFiles, 1);
phase_deg = zeros(numFiles, 1);

%% 2. Process Each File for Bode Plot Data
for i = 1:numFiles
    base_filename = matFiles(i).name;
    filename = fullfile(dataDir, base_filename);
    load(filename, 't', 'v_in', 'v_out');

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
        t_in_peak = locs_in(1);
        idx_out = find(locs_out > t_in_peak, 1);

        if ~isempty(idx_out)
            dt = locs_out(idx_out) - t_in_peak;
            % Phase shift in degrees: delta_t * f * 360.
            calc_phase = -(dt * freq * 360);

            % Adjust phase for inverting amplifier wrap-around
            if calc_phase > 0
                calc_phase = calc_phase - 360;
            end
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
fprintf('Results saved to %s\n', results_file);

%% 3. Plot the 3 Specific Frequencies (Task 3)
% Create separate figures as requested by the lab manual
for p = 1:length(specific_freqs)
    target_freq = specific_freqs(p);
    
    % Find the closest recorded frequency to our target
    [~, closest_idx] = min(abs(freqs_recorded - target_freq));
    actual_freq = freqs_recorded(closest_idx);
    
    % Load the data for this specific plot
    load(fullfile(dataDir, matFiles(sortIdx(closest_idx)).name), 't', 'v_in', 'v_out');
    if isduration(t), t = seconds(t); end

    fig_time = figure('Name', sprintf('Time Domain at %.2f Hz', actual_freq), 'Position', [100+(p*50), 100+(p*50), 700, 450]);
    plot(t, v_in, 'k', 'LineWidth', 1.5); hold on;
    plot(t, v_out, 'b', 'LineWidth', 1.5); hold off;

    % Zoom to 3 cycles of the data
    time_for_3_cycles = 3 * (1 / actual_freq);
    xlim([0, time_for_3_cycles]);

    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Signals (V)', 'FontWeight', 'bold');
    title(sprintf('Filter Response at %.2f Hz', actual_freq));
    legend('Input Wave (E_i)', 'Output Wave (E_o)', 'Location', 'best');
    grid on;
    set(gca, 'FontSize', 12);
    
    % Save each figure
    fig_name = sprintf('Lab8_TimeDomain_%.1fHz', actual_freq);
    savefig(fig_time, fullfile(figDir, [fig_name, '.fig']));
    saveas(fig_time, fullfile(figDir, [fig_name, '.png']));
end

%% 4. Plot the Full Bode Plot (Task 4)
fig_bode = figure('Name', 'Empirical Bode Plot', 'Position', [800, 100, 800, 800]);

% --- Magnitude Subplot ---
subplot(2, 1, 1);
semilogx(freqs_recorded, mag_dB, 'ks-', 'MarkerFaceColor', 'b', 'MarkerSize', 6, 'LineWidth', 1.2); hold on;

% Add expected theoretical markers
xline(fc, '--k', sprintf('f_c = %.1f Hz', fc), 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
passband_mag = mean(mag_dB(1:5)); % Estimate passband from lowest frequencies
yline(passband_mag - 3, ':r', '-3dB Cutoff Threshold', 'HandleVisibility', 'off');

xlabel('Frequency, f (Hz)', 'FontWeight', 'bold');
ylabel('Magnitude (dB)', 'FontWeight', 'bold');
title('Bode Plot: Magnitude');
grid on;
set(gca, 'FontSize', 12, 'XScale', 'log');

% --- Phase Subplot ---
subplot(2, 1, 2);
semilogx(freqs_recorded, phase_deg, 'ks-', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'LineWidth', 1.2); hold on;
xline(fc, '--k', sprintf('f_c = %.1f Hz', fc), 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');

xlabel('Frequency, f (Hz)', 'FontWeight', 'bold');
ylabel('Phase (degrees)', 'FontWeight', 'bold');
title('Bode Plot: Phase');
grid on;
set(gca, 'FontSize', 12, 'XScale', 'log');

% Save Bode Plot
savefig(fig_bode, fullfile(figDir, 'Lab8_BodePlot.fig'));
saveas(fig_bode, fullfile(figDir, 'Lab8_BodePlot.png'));

fprintf('Figures generated and saved to the "%s/" directory.\n', figDir);