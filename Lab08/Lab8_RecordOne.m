% File: Lab8_RecordOne.m
% Purpose: Acquire and save raw voltage data for a SINGLE frequency for Lab 8.
%          Useful for verifying circuit operation before a full sweep.
% Author: Sean Balbale
% Date: Spring 2026

clear; clc;

%% 1. Setup Parameters
fs = 100000; % 100,000 samples per second
duration = 5; % 5 seconds of data collection
wave_type = 'Sine';
vpp = 1.0; % 1 Vpp sine wave with no offset
task_label = 'ActiveFilter';

%% 2. User Input
fprintf('--- Lab 8: Single Frequency Test ---\n');
test_freq = input('Enter the frequency (in Hz) you want to test: ');

if isempty(test_freq) || test_freq <= 0
    error('Invalid frequency entered. Please run the script again.');
end

%% 3. Initialize DAQ for TWO Inputs
fprintf('Initializing DAQ...\n');
dq = daq("ni");
% Add input for the signal from the function generator (Ei)
addinput(dq, "Dev1", "ai0", "Voltage");
% Add input for the signal from the Op Amp output (Eo)
addinput(dq, "Dev1", "ai1", "Voltage");

dq.Rate = fs;

%% 4. Record Data
% Create data directory if it doesn't exist
if ~exist('data', 'dir')
    mkdir('data');
end

fprintf('\nPlease set your waveform generator to: %.2f Hz, 1.0 Vpp, 0 DC offset.\n', test_freq);
input('Press Enter when ready to record...');

fprintf('Recording %d seconds of data at %.2f Hz...\n', duration, test_freq);
data = read(dq, seconds(duration));

% Extract time and voltage arrays for saving
t = data.Time;
v_in = data.Dev1_ai0; % Input signal
v_out = data.Dev1_ai1; % Output signal

% Generate descriptive filename
base_filename = sprintf('%s_%.2fHz_%.1fVpp_fs%d_%s_raw.mat', wave_type, test_freq, vpp, fs, task_label);
filename = fullfile('data', base_filename);
save(filename, 't', 'v_in', 'v_out');

fprintf('\nSuccess! Saved: %s\n', filename);
