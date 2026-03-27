% File: Lab6_RecordData.m
% Purpose: Acquire and save raw voltage data for both input and output signals for Lab 6.
% Author: Sean Balbale
% Date: 03/27/2026

%% 1. Setup Parameters
% --- UPDATE THESE PARAMETERS FOR EACH SPECIFIC RUN ---

% --- Task 1 Parameters (Gain = 1) ---
fs = 10000; % High enough to resolve 200 Hz smoothly
duration = 4; % Record 4 seconds of data
wave_type = 'Sine';
freq = 200; % 200 Hz
vpp = 10; % 10 Vpp
offset = 0;
task_label = 'Task1_Gain1';

% --- Task 2 Parameters (Gain = 10, Large Signal) ---
% fs = 10000;
% duration = 4;
% wave_type = 'Sine';
% freq = 200;
% vpp = 10;
% offset = 0;
% task_label = 'Task2_Gain10_Large';

% --- Task 3 Parameters (Gain = 10, Small Signal) ---
% fs = 10000;
% duration = 4;
% wave_type = 'Sine';
% freq = 200;
% vpp = 0.5;        % 0.5 Vpp
% offset = 0;
% task_label = 'Task3_Gain10_Small';

% --- Task 4 Parameters (Variable Supply Voltage) ---
% fs = 10000;
% duration = 4;
% wave_type = 'Sine';
% freq = 200;
% vpp = 0.5;
% offset = 0;
% supply_state = '3pm'; % Change to '3pm', '1pm', '11am', '9am'
% task_label = sprintf('Task4_Supply_%s', supply_state);

%% 2. Initialize DAQ for TWO Inputs
dq = daq("ni");
% Add input for the signal from the function generator (Ei)
addinput(dq, "Dev1", "ai0", "Voltage");
% Add input for the signal from the Op Amp output (Eo)
addinput(dq, "Dev1", "ai1", "Voltage");

dq.Rate = fs;

%% 3. Record Data
fprintf('Recording %d seconds of %s wave data at %d Hz for %s...\n', duration, wave_type, freq, task_label);
data = read(dq, seconds(duration));

% Extract time and voltage arrays for saving
t = data.Time;
v_in = data.Dev1_ai0; % Input signal
v_out = data.Dev1_ai1; % Output signal

%% 4. Save Raw Data
% Create data directory if it doesn't exist
if ~exist('data', 'dir')
    mkdir('data');
end

% Generate descriptive filename
base_filename = sprintf('%s_%dHz_%.1fVpp_fs%d_%s_raw.mat', wave_type, freq, vpp, fs, task_label);
filename = fullfile('data', base_filename);
save(filename, 't', 'v_in', 'v_out');

fprintf('Success! Raw data saved to: %s\n\n', filename);
