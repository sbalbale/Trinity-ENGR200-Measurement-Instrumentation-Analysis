% File: analysis.m
% Purpose: Analyze voltage data collected from Arduino, calculate uncertainties, and visualize results.
% Author: Sean Balbale
% Date: 02/06/2026

clear; clc; close all;

% 1. Import Data and Convert to Voltage 
% Replace 'dataset_name.csv' with your specific filename 
filename = 'Lab3_Data_Floating_N300.csv'; 
data = readmatrix(filename);

% Extract columns (assuming Column 1 is Time, Column 2 is ADC Value)
adc_counts = data(:, 2);
N = length(adc_counts); % Number of samples

% System Parameters
V_ref = 5.0; % Reference voltage in Volts
ADC_max = 1023; % Max ADC count

% Convert ADC counts to Voltage
% Formula: Voltage = (ADC_Value / 1023) * V_ref
voltages = (adc_counts / ADC_max) * V_ref;

% 2. Statistical Analysis (Type A Uncertainty)
mean_voltage = mean(voltages);
std_dev = std(voltages); 

% Standard Uncertainty of the Mean (Type A)
% u_A = s / sqrt(N)
u_type_A = std_dev / sqrt(N);

fprintf('--- Statistical Results (Type A) ---\n');
fprintf('Number of Samples (N): %d\n', N);
fprintf('Mean Voltage: %.4f V\n', mean_voltage);
fprintf('Standard Deviation: %.4f V\n', std_dev);
fprintf('Uncertainty of the Mean (u_A): %.5f V\n', u_type_A);

% 3. Instrument Uncertainty (Type B)
% Uncertainty due to ADC resolution.
% Resolution is the voltage change corresponding to 1 ADC count.
resolution_voltage = V_ref / ADC_max; 

% Assuming a rectangular (uniform) distribution for digital resolution
% u_B = resolution / sqrt(12)
u_type_B = resolution_voltage / sqrt(12);

fprintf('\n--- Instrument Uncertainty (Type B) ---\n');
fprintf('ADC Resolution: %.5f V\n', resolution_voltage);
fprintf('Resolution Uncertainty (u_B): %.5f V\n', u_type_B);

% 4. Combined Uncertainty
% Combine independent sources using root-sum-square
u_combined = sqrt(u_type_A^2 + u_type_B^2);

fprintf('\n--- Total Uncertainty ---\n');
fprintf('Combined Standard Uncertainty (u_c): %.5f V\n', u_combined);

% 5. Visualization (Optional but recommended)
figure;
plot(voltages, 'b.');
hold on;
yline(mean_voltage, 'r-', 'LineWidth', 2);
xlabel('Sample Number');
ylabel('Voltage (V)');
title(['Measured Voltage (N = ' num2str(N) ')']);
legend('Measured Data', 'Mean');
grid on;