% File: Lab7_RecordOneData.m
% Purpose: Acquire and save one raw voltage dataset for Lab 7 at a user-specified frequency.
% Author: Sean Balbale
% Date: 04/03/2026

clear; clc;

%% 1. Setup Parameters
fs = 100000;          % 100,000 samples per second
duration = 5;         % 5 seconds of data capture
wave_type = 'Sine';
vpp = 1.0;            % 1 Vpp with no offset
task_label = 'BodePlot';

%% 2. Ask User for Frequency
freq = input('Enter waveform generator frequency in Hz (e.g., 1000): ');

if isempty(freq) || ~isnumeric(freq) || ~isscalar(freq) || ~isfinite(freq) || freq <= 0
    error('Frequency must be a single positive numeric value in Hz.');
end

%% 3. Initialize DAQ for TWO Inputs
fprintf('Initializing DAQ for Lab 7 Single-Point Data Collection...\n');
dq = daq("ni");
addinput(dq, "Dev1", "ai0", "Voltage"); % Input signal (Ei)
addinput(dq, "Dev1", "ai1", "Voltage"); % Output signal (Eo)
dq.Rate = fs;

%% 4. Record One Dataset
if ~exist('data', 'dir')
    mkdir('data');
end

fprintf('Set waveform generator to %.2f Hz, %.1f Vpp, 0 V offset.\n', freq, vpp);
input('Press Enter when ready to record...');

fprintf('Recording %d seconds of data at %.2f Hz...\n', duration, freq);
data = read(dq, seconds(duration));

% Extract time and voltage arrays for saving
t = data.Time;
v_in = data.Dev1_ai0;
v_out = data.Dev1_ai1;

% Generate descriptive filename and save (same naming scheme as Lab7_RecordData.m)
base_filename = sprintf('%s_%.2fHz_%.1fVpp_fs%d_%s_raw.mat', ...
    wave_type, freq, vpp, fs, task_label);
filename = fullfile('data', base_filename);
save(filename, 't', 'v_in', 'v_out');

fprintf('Saved: %s\n', filename);
fprintf('Single-point data collection complete.\n');
