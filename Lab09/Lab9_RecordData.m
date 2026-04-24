% File: Lab9_RecordData.m
% Purpose: Send a step input from the DAQ analog output to the Butterworth
%          low-pass filter and simultaneously record the filter output.
%          Collects 30 independent datasets using the readwrite command.
% Author: Sean Balbale
% Date: Spring 2026

clear; clc;

%% 1. Setup Parameters
fs         = 100000;       % 100,000 samples per second
duration   = 1.0;          % 1 second total per run (0.5 s high, 0.5 s low)
n_samples  = fs * duration; % Total samples per run
n_runs     = 30;            % Number of independent step-response datasets
task_label = 'StepResponse';

%% 2. Generate Step Output Signal
% DAQ ao0 sends 1 V for the first 0.5 s, then 0 V for the next 0.5 s.
% This creates a single voltage step that excites the first-order system.
half_n     = n_samples / 2;
step_signal = [ones(half_n, 1); zeros(half_n, 1)];   % [V]

fprintf('--- Lab 9: Step Response Data Collection ---\n');
fprintf('Signal: 1 V for %.3f s, then 0 V for %.3f s\n', duration/2, duration/2);
fprintf('Total samples per run: %d  |  Sampling rate: %d Hz\n', n_samples, fs);
fprintf('Number of independent runs: %d\n\n', n_runs);

%% 3. Initialize DAQ  (Analog Input + Analog Output)
fprintf('Initializing NI DAQ...\n');
dq = daq("ni");

% Analog input — records filter output (connect filter Eo -> ai0)
addinput(dq, "Dev1", "ai0", "Voltage");

% Analog output — sends step signal to filter input (connect ao0 -> filter Ei)
addoutput(dq, "Dev1", "ao0", "Voltage");

dq.Rate = fs;
fprintf('DAQ initialized. Rate set to %d Hz.\n\n', fs);

%% 4. Wiring Reminder
fprintf('=== WIRING CHECK ===\n');
fprintf('  DAQ ao0  --->  Filter Input  (Ei)\n');
fprintf('  Filter Output (Eo)  --->  DAQ ai0\n');
fprintf('  Ensure ±15 V rails are ON before proceeding.\n');
fprintf('====================\n\n');

%% 5. Create Data Directory
if ~exist('data', 'dir')
    mkdir('data');
    fprintf('Created directory: data/\n');
end

input('Circuit ready? Press Enter to begin data collection...');
fprintf('\n');

%% 6. Data Collection Loop — 30 Independent Runs
for i = 1:n_runs
    fprintf('--- Run %d of %d ---\n', i, n_runs);
    fprintf('Sending step and recording response...\n');

    % readwrite simultaneously outputs step_signal on ao0 and reads ai0.
    % The DAQ clocks both channels at the same rate (fs), ensuring
    % time-aligned input/output with no offset.
    data = readwrite(dq, step_signal);

    % Extract time vector and filter output voltage
    t     = data.Time;
    v_out = data.Dev1_ai0;   % Filter output voltage [V]

    % Save dataset — unique filename per run
    base_filename = sprintf('StepResponse_Run%02d_fs%d_%s_raw.mat', i, fs, task_label);
    filename      = fullfile('data', base_filename);
    save(filename, 't', 'step_signal', 'v_out', 'fs');

    fprintf('Saved: %s\n\n', base_filename);
end

% Zero the analog output after the last run to leave the circuit in a safe state
write(dq, 0);

fprintf('============================================\n');
fprintf('Data collection complete!\n');
fprintf('%d datasets saved to the data/ directory.\n', n_runs);
fprintf('Run Lab9_Analysis.m to extract tau and generate plots.\n');