% File: Lab4_RecordData.m
% Purpose: Acquire and save raw voltage data from the function generator via DAQ.
% Author: Sean Balbale
% Date: 03/06/2026

%% 1. Setup Parameters
fs = 2000;          % Sampling frequency in Hz
duration = 10;      % Duration in seconds

% --- CHANGE THESE FOR EACH RUN ---
wave_type = 'Sine'; % Options: 'Sine', 'Square', 'Ramp_100', 'Ramp_50'
freq = 7;           % Frequency in Hz (7 or 25)
vpp = 5;            % Peak-to-Peak Amplitude in Volts (5 or 0.3)
offset = 0;         % DC Offset in Volts (0 or 0.2)
% ---------------------------------

%% 2. Initialize DAQ
dq = daq("ni");
addinput(dq, "Dev1", "ai0", "Voltage");
dq.Rate = fs;

%% 3. Record Data
fprintf('Recording %d seconds of %s wave data at %d Hz...\n', duration, wave_type, freq);
data = read(dq, seconds(duration));

% Extract time and voltage arrays for saving
t = data.Time;
v = data.Dev1_ai0;

%% 4. Save Raw Data
% This automatically generates a descriptive filename
filename = sprintf('%s_%dHz_%.1fVpp_%.1fVoffset_raw.mat', wave_type, freq, vpp, offset);
save(filename, 't', 'v');

fprintf('Success! Raw data saved to: %s\n\n', filename);