% File: Lab5_AliasTable.m
% Purpose: Generate a table of alias frequencies for Lab 5, Task 1.
% Author: Sean Balbale
% Date: 03/13/2026

clear; clc;

% Define Parameters for Task 1
fs = 2000; % Sampling frequency in Hz
f_nyquist = fs / 2; % Nyquist frequency
f_signal = 500:100:2500; % Signal frequencies from 500 Hz to 2500 Hz

% Preallocate array for alias frequencies
f_alias = zeros(length(f_signal), 1);

% Calculate Alias Frequencies
for i = 1:length(f_signal)
    % The aliased frequency is folded back into the Nyquist range
    % Formula: f_alias = | f_signal - N * fs |
    % where N is the closest integer to (f_signal / fs)
    N = round(f_signal(i) / fs);
    f_alias(i) = abs(f_signal(i) - N * fs);
end

% Create a formatted table
fprintf('--- Lab 5: Task 1 Alias Frequency Table ---\n\n');
fprintf('%-20s %-20s %-20s %-20s\n', 'Function Freq (Hz)', 'Sampling Freq (Hz)', 'Nyquist Freq (Hz)', 'Alias Freq (Hz)');
fprintf('%s\n', repmat('-', 1, 85));

for i = 1:length(f_signal)
    fprintf('%-20d %-20d %-20d %-20d\n', f_signal(i), fs, f_nyquist, f_alias(i));
end

% Optional: Write to a text file
fileID = fopen('Task1_Alias_Table.txt', 'w');
fprintf(fileID, '%-20s %-20s %-20s %-20s\n', 'Function Freq (Hz)', 'Sampling Freq (Hz)', 'Nyquist Freq (Hz)', 'Alias Freq (Hz)');

for i = 1:length(f_signal)
    fprintf(fileID, '%-20d %-20d %-20d %-20d\n', f_signal(i), fs, f_nyquist, f_alias(i));
end

fclose(fileID);
fprintf('\nTable successfully saved to Task1_Alias_Table.txt\n');
