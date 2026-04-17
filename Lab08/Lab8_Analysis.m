% File: Lab8_AnalyseOne.m
% Purpose: Load a single raw .mat file from Lab 8, calculate gain/phase,
%          and plot the time-domain waveform.
% Author: Sean Balbale
% Date: Spring 2026

clear; clc; close all;

%% 1. Setup Parameters (Must match Record script)
fs = 100000;
wave_type = 'Sine';
vpp = 1.0;
task_label = 'ActiveFilter';

%% 2. Target File Selection
fprintf('--- Lab 8: Single File Analysis ---\n');
test_freq = input('Enter the frequency (in Hz) of the file you want to analyze: ');

% Reconstruct the expected filename
base_filename = sprintf('%s_%.2fHz_%.1fVpp_fs%d_%s_raw.mat', wave_type, test_freq, vpp, fs, task_label);
filename = fullfile('data', base_filename);

if ~isfile(filename)
    error('File not found: %s\nPlease ensure you ran RecordOne for this frequency.', filename);
end

%% 3. Load and Process Data
fprintf('Loading %s...\n', base_filename);
load(filename, 't', 'v_in', 'v_out');

% Convert timetable duration to seconds if necessary
if isduration(t)
    t_sec = seconds(t);
else
    t_sec = t;
end

% --- Calculate Magnitude ---
amp_in = (max(v_in) - min(v_in)) / 2;
amp_out = (max(v_out) - min(v_out)) / 2;
gain = amp_out / amp_in;
mag_dB = 20 * log10(gain);

% --- Calculate Phase ---
search_window = t_sec < (3 / test_freq);
[~, locs_in] = findpeaks(v_in(search_window), fs);
[~, locs_out] = findpeaks(v_out(search_window), fs);

phase = NaN; % Default if peaks aren't found

if ~isempty(locs_in) && ~isempty(locs_out)
    tp1 = locs_in(1);

    % Find corresponding output peak
    valid_out_locs = locs_out(locs_out >= tp1 - (1 / test_freq) / 2);

    if ~isempty(valid_out_locs)
        tp2 = valid_out_locs(1);
    else
        tp2 = locs_out(1);
    end

    dt = tp1 - tp2;
    phase = dt * test_freq * 360;

    % Adjust phase for inverting amplifier wrap-around
    if phase > 0
        phase = phase - 360;
    end

end

%% 4. Command Window Report
fprintf('\n--- Analysis Results for %.2f Hz ---\n', test_freq);
fprintf('Input Amplitude:  %.3f V\n', amp_in);
fprintf('Output Amplitude: %.3f V\n', amp_out);
fprintf('Linear Gain (G):  %.3f\n', gain);
fprintf('Magnitude (dB):   %.2f dB\n', mag_dB);
fprintf('Phase Shift:      %.2f degrees\n', phase);
fprintf('------------------------------------\n');

%% 5. Time-Domain Plot
figure('Name', sprintf('Time Domain at %.2f Hz', test_freq));
plot(t_sec, v_in, 'b', 'LineWidth', 1.5); hold on;
plot(t_sec, v_out, 'r', 'LineWidth', 1.5);

% Restrict x-axis to show exactly 3 cycles
xlim([0, 3 / test_freq]);

title(sprintf('Filter Response at %.2f Hz', test_freq), 'FontSize', 14);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Voltage (V)', 'FontSize', 12);
legend('Input Wave (E_i)', 'Output Wave (E_o)', 'Location', 'best');
grid on;
