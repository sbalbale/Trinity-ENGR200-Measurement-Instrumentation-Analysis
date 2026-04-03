% File: Lab7_RecordData.m
% Purpose: Acquire and save raw voltage data for both input and output signals for Lab 7.
%          Guides user through 30 logarithmically spaced frequencies.
% Author: Sean Balbale
% Date: 04/03/2026

clear; clc;

%% 1. Setup Parameters
% --- Lab 7 specific parameters ---
fs = 100000; % 100,000 samples per second
duration = 5; % 5 seconds ensures at least 5 cycles for the 1 Hz low-end
wave_type = 'Sine';
vpp = 1.0; % 1 Vpp sine wave with no offset
task_label = 'BodePlot';

% Calculate 30 logarithmically spaced frequencies between 1 Hz (10^0) and 10,000 Hz (10^4)
num_points = 30;
freqs = logspace(0, 4, num_points);

%% 2. Initialize DAQ for TWO Inputs
fprintf('Initializing DAQ for Lab 7 Data Collection...\n');
dq = daq("ni");
% Add input for the signal from the function generator (Ei)
addinput(dq, "Dev1", "ai0", "Voltage");
% Add input for the signal from the Op Amp output (Eo)
addinput(dq, "Dev1", "ai1", "Voltage");

dq.Rate = fs;

%% 3. Record Data Loop
% Create data directory if it doesn't exist
if ~exist('data', 'dir')
    mkdir('data');
end

fprintf('Lab 7 Data Collection: %d Log-Spaced Frequencies\n', num_points);
fprintf('Ensure Waveform Generator is set to 1 Vpp, 0 DC offset.\n\n');

for i = 1:num_points
    current_freq = freqs(i);

    % Prompt user to set the generator
    fprintf('--- Trial %d of %d ---\n', i, num_points);
    fprintf('Please set your waveform generator to: %.2f Hz\n', current_freq);
    input('Press Enter when ready to record...');

    fprintf('Recording %d seconds of data at %.2f Hz...\n', duration, current_freq);
    data = read(dq, seconds(duration));

    % Extract time and voltage arrays for saving
    t = data.Time;
    v_in = data.Dev1_ai0; % Input signal
    v_out = data.Dev1_ai1; % Output signal

    % Generate descriptive filename
    base_filename = sprintf('%s_%.2fHz_%.1fVpp_fs%d_%s_raw.mat', wave_type, current_freq, vpp, fs, task_label);
    filename = fullfile('data', base_filename);
    save(filename, 't', 'v_in', 'v_out');

    fprintf('Saved: %s\n\n', filename);
end

fprintf('Data collection complete! All files saved to the data/ directory.\n');
