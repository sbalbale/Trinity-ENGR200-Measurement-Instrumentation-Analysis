% Arduino Data Logger
% Autosaves Serial data to a CSV file
% Author: Sean Balbale
% Date: 1/30/2026
% ---------------------------------------------------------

clear; clc;

% --- CONFIGURATION ---
portName = "COM3";      % Arduino Port (e.g., "COM3" or "/dev/tty...")
baudRate = 9600;        % Match the Arduino baud rate
fileName = "dataset_fixed.csv"; % Change this for each dataset (dataset_fast.csv, dataset_random.csv, dataset_fixed.csv)
% ---------------------

% 1. Connect to Arduino
disp("Connecting to Arduino on " + portName + "...");
try
    s = serialport(portName, baudRate);
    configureTerminator(s, "CR/LF"); % Arduino println uses CR/LF
    flush(s); % Clear old data
    disp("Connected! capturing data...");
catch ME
    error("Failed to connect. Check if Arduino IDE Serial Monitor is CLOSED.");
end

% 2. Open File for Writing
fileID = fopen(fileName, 'w');
if fileID == -1
    error("Cannot create file. Check permissions.");
end

% 3. Collection Loop
% Collect until no data is received for 2 seconds (timeout)
s.Timeout = 2; 
dataCount = 0;
disp("Recording... (Data will autosave when transmission stops)");

while true
    try
        % Read one line of data
        line = readline(s);
        
        % Check if data stopped coming (empty line indicates timeout)
        if strlength(line) == 0
            break; 
        end
        
        % Convert to number to verify it's valid data
        numVal = str2double(line);
        if ~isnan(numVal)
            % Write to CSV file
            fprintf(fileID, '%d\n', numVal);
            
            % Print to Command Window so you can see it working
            fprintf('Sample %d: %d\n', dataCount+1, numVal);
            dataCount = dataCount + 1;
        end
    catch
        break; % Stop on any error or manual interruption
    end
end

% 4. Cleanup
fclose(fileID);
clear s;
disp("------------------------------------------------");
disp("Capture Complete.");
disp("Data saved to: " + fileName);
disp("Total samples: " + dataCount);