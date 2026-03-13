% File: Lab5_RecordData.m
% Purpose: Acquire and save raw voltage data from the function generator via DAQ for Lab 5.
% Author: Sean Balbale
% Date: 03/13/2026

%% 1. Setup Parameters
% --- UPDATE THESE PARAMETERS FOR EACH SPECIFIC RUN ---

% --- Task 1 Parameters ---
fs = 2000;
duration = 4;
wave_type = 'Sine';
freq = 500; % Change from 500 to 2500 in 100 Hz steps
vpp = 5;
offset = 0;

% --- Task 2 Parameters ---
% fs = 10000;
% duration = 2;
% wave_type = 'Sine';
% freq = 100;
% vpp = 0.05;         % Change to 0.05, 0.02, 0.01, 0.002 (50mV, 20mV, 10mV, 2mV)
% offset = 0;

% --- Task 3 Parameters ---
% fs = 500;           % Change to 500, 1000, 2000, 5000
% duration = 2;
% wave_type = 'Saw';  % Function generator uses a ramp with 0% symmetry
% freq = 173;
% vpp = 5;
% offset = 0;

%% 2. Initialize DAQ
dq = daq("ni");
addinput(dq, "Dev1", "ai0", "Voltage");
dq.Rate = fs;

%% 3. Record Data
fprintf('Recording %d seconds of %s wave data at %d Hz (fs = %d Hz)...\n', duration, wave_type, freq, fs);
data = read(dq, seconds(duration));

% Extract time and voltage arrays for saving
t = data.Time;
v = data.Dev1_ai0;

%% 4. Save Raw Data
% Create data directory if it doesn't exist
if ~exist('data', 'dir')
    mkdir('data');
end

% Automatically generates a descriptive filename based on parameters
base_filename = sprintf('%s_%dHz_%.3fVpp_fs%d_raw.mat', wave_type, freq, vpp, fs);
filename = fullfile('data', base_filename);
save(filename, 't', 'v');

fprintf('Success! Raw data saved to: %s\n\n', filename);
