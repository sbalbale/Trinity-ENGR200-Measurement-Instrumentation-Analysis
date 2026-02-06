% File: recordData.m
% Purpose: Collect voltage data from Arduino via Serial, save to CSV, and provide a quick
% visualization of the collected data.
% Author: Sean Balbale
% Date: 02/06/2026

clear; clc;

if ~isempty(serialportfind)
    delete(serialportfind); % Close any open existing ports to avoid conflicts
end

% 1. Configuration
% CHECK THIS: Change to your actual Arduino port (e.g., 'COM3', 'COM4')
serialPortName = 'COM4';
baudRate = 9600; % Must match Arduino Serial.begin

% Sampling Parameters
numSamples = 300; % Change N as required (e.g., 50, 200, 300)
filename = 'Lab3_Data_Stable_N300.csv'; % Name of the file to save

% 2. Connect to Arduino
fprintf('Connecting to Arduino on %s...\n', serialPortName);

try
    s = serialport(serialPortName, baudRate);
    configureTerminator(s, "CR/LF"); % Standard Arduino line ending
    flush(s); % Clear old data from the buffer
catch ME
    error('Failed to connect. Check port name and ensure Arduino IDE Serial Monitor is CLOSED.');
end

% 3. Collect Data
dataLog = zeros(numSamples, 2); % Pre-allocate array: [Time, ADC_Value]
fprintf('Collecting %d samples...\n', numSamples);

for i = 1:numSamples
    % Read one line of text from the serial port
    line = readline(s);

    % Convert text "Time,Value" to numbers
    % Extracts comma-separated numbers into a 1x2 array
    vals = str2double(split(line, ','));

    if length(vals) == 2
        dataLog(i, :) = vals;
    else
        % Handle errors if a partial line is read
        dataLog(i, :) = [NaN, NaN];
    end

end

% 4. Save and Cleanup
% Close the serial connection immediately
clear s;
fprintf('Data collection complete.\n');

% Remove any rows with NaN errors (clean data)
dataLog = rmmissing(dataLog);

% Save to CSV
writematrix(dataLog, filename);
fprintf('Data saved to %s\n', filename);

% 5. Quick Preview Plot
% Converts ADC (0-1023) to Voltage (0-5V) for preview
voltages = (dataLog(:, 2) / 1023) * 5.0;
plot(dataLog(:, 1), voltages);
xlabel('Time (ms)');
ylabel('Voltage (V)');
title(['Data Preview: ' filename]);
grid on;
