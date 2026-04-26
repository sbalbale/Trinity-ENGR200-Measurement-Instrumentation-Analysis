% File: Lab9_Analysis.m
% Purpose: Load all 30 step-response datasets from Lab 9.
%          Extract the time constant tau using three methods (95% threshold,
%          99.3% threshold, and exponential curve fit), report mean & std dev,
%          compare to the Lab 8 cutoff frequency, and generate all required plots.
% Author: Sean Balbale
% Date: Spring 2026

clear; clc; close all;

%% 1. Setup Parameters
fs         = 100000;           % Sampling rate [Hz]
R1         = 50.842e3;         % Measured input resistor [Ohm]
R2         = 50.850e3;         % Measured feedback resistor [Ohm]
C1         = 50.0e-9;          % Measured feedback capacitor [F]

% Measurement uncertainty assumptions from instrument resolution
dR1        = 1.0;              % +/- 1 Ohm
dR2        = 1.0;              % +/- 1 Ohm
dC1        = 0.1e-9;           % +/- 0.1 nF

gain_mag   = R2 / R1;          % |DC gain| of inverting active low-pass
gain_unc   = gain_mag * sqrt((dR1 / R1)^2 + (dR2 / R2)^2);

fc         = 1 / (2*pi*R2*C1); % Cutoff frequency from measured components
fc_unc     = fc * sqrt((dR2 / R2)^2 + (dC1 / C1)^2);
tau_exp    = 1 / (2*pi*fc);   % Expected time constant: tau = 1/(2*pi*fc) [s]
tau_exp_unc = tau_exp * (fc_unc / fc);
n_runs     = 30;
task_label = 'StepResponse';
dataDir    = 'data';
figDir     = 'figures';

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

fprintf('==============================================\n');
fprintf('  Lab 9: First-Order System Transient Analysis\n');
fprintf('==============================================\n');
fprintf('Measured R1  : %.3f kOhm\n', R1/1000);
fprintf('Measured R2  : %.3f kOhm\n', R2/1000);
fprintf('Measured C1  : %.1f nF\n', C1*1e9);
fprintf('Assumed dR1  : +/- %.1f Ohm\n', dR1);
fprintf('Assumed dR2  : +/- %.1f Ohm\n', dR2);
fprintf('Assumed dC1  : +/- %.1f nF\n', dC1*1e9);
fprintf('|Gain| (R2/R1): %.6f +/- %.6f\n', gain_mag, gain_unc);
fprintf('Calculated fc: %.2f Hz\n', fc);
fprintf('Calculated fc uncertainty: +/- %.3f Hz\n', fc_unc);
fprintf('Expected tau : %.4f ms  (1 / 2*pi*fc)\n', tau_exp * 1000);
fprintf('Expected tau uncertainty: +/- %.4f ms\n\n', tau_exp_unc * 1000);

%% 2. Allocate Storage
tau_method1    = NaN(n_runs, 1);   % 95% threshold  -> t = 3*tau
tau_method2    = NaN(n_runs, 1);   % 99.3% threshold -> t = 5*tau
tau_method3    = NaN(n_runs, 1);   % Exponential curve fit
V0_runs        = NaN(n_runs, 1);   % Steady-state output (for measured gain)
response_data  = cell(n_runs, 1);  % Full datasets for plotting

%% 3. Load and Process Each Dataset
fprintf('Loading and processing %d datasets...\n\n', n_runs);

for i = 1:n_runs
    base_filename = sprintf('StepResponse_Run%02d_fs%d_%s_raw.mat', i, fs, task_label);
    filename      = fullfile(dataDir, base_filename);

    if ~isfile(filename)
        error('File not found: %s\nPlease run Lab9_RecordData.m first.', base_filename);
    end

    load(filename, 't', 'v_out', 'fs');
    v_out = -v_out;
    
    % Convert timetable duration to seconds if necessary
    if isduration(t)
        t_sec = seconds(t);
    else
        t_sec = t;
    end

    % --- Isolate the rising edge (first 0.5 s of the 1-second record) ---
    % The step goes from 0 to 1 V at t = 0.  Use only the high period.
    high_samples = round(0.5 * fs);
    t_rise  = t_sec(1:high_samples);
    v_rise  = v_out(1:high_samples);

    % Align time so the rising edge starts at t = 0
    t_rise = t_rise - t_rise(1);

    % Steady-state voltage: mean of the last 10 % of the high period
    ss_start = round(0.90 * high_samples);
    V0 = mean(v_rise(ss_start:end));

    % Cache for plotting
    response_data{i}.t    = t_rise;
    response_data{i}.v    = v_rise;
    response_data{i}.V0   = V0;
    V0_runs(i)            = V0;

    % ---------------------------------------------------------------
    % Method 1: Time to reach 95 % of V0  (theory: t95 = 3*tau)
    % ---------------------------------------------------------------
    thresh_95 = 0.95 * V0;
    idx_95    = find(v_rise >= thresh_95, 1, 'first');
    if ~isempty(idx_95)
        tau_method1(i) = t_rise(idx_95) / 3;
    end

    % ---------------------------------------------------------------
    % Method 2: Time to reach 99.3 % of V0  (theory: t993 = 5*tau)
    % ---------------------------------------------------------------
    thresh_993 = 0.993 * V0;
    idx_993    = find(v_rise >= thresh_993, 1, 'first');
    if ~isempty(idx_993)
        tau_method2(i) = t_rise(idx_993) / 5;
    end

    % ---------------------------------------------------------------
    % Method 3: Exponential Curve Fit  y(t) = V0 * (1 - exp(-t/tau))
    % Fit range: t = 0 to approximately 5*tau_exp (estimated from design)
    % ---------------------------------------------------------------
    t_fit_end = min(5 * tau_exp, t_rise(end));
    fit_mask  = t_rise <= t_fit_end;
    t_fit     = t_rise(fit_mask);
    v_fit     = v_rise(fit_mask);

    ft = fittype('a * (1 - exp(-x / tau))', ...
        'independent', 'x', ...
        'coefficients', {'a', 'tau'});
    opts             = fitoptions(ft);
    opts.StartPoint  = [V0,   tau_exp];
    opts.Lower       = [0,    0      ];
    opts.Upper       = [2,    0.1    ];
    opts.Display     = 'off';

    try
        fitted           = fit(t_fit, v_fit, ft, opts);
        tau_method3(i)   = fitted.tau;
    catch
        warning('Curve fit failed for run %d. Stored as NaN.', i);
    end
end

%% 4. Compute Mean and Standard Deviation for Each Method
tau1_mean = mean(tau_method1, 'omitnan');
tau1_std  = std( tau_method1, 'omitnan');
tau2_mean = mean(tau_method2, 'omitnan');
tau2_std  = std( tau_method2, 'omitnan');
tau3_mean = mean(tau_method3, 'omitnan');
tau3_std  = std( tau_method3, 'omitnan');
gain_meas_mean = mean(V0_runs, 'omitnan');   % Vin step is 1 V
gain_meas_std  = std( V0_runs, 'omitnan');

%% 5. Command Window Report
fprintf('--- Time Constant (tau) Results (%d runs) ---\n', n_runs);
fprintf('Method 1 | 95%% threshold (t = 3*tau):\n');
fprintf('         Mean = %.4f ms  |  Std Dev = %.4f ms\n\n', tau1_mean*1000, tau1_std*1000);
fprintf('Method 2 | 99.3%% threshold (t = 5*tau):\n');
fprintf('         Mean = %.4f ms  |  Std Dev = %.4f ms\n\n', tau2_mean*1000, tau2_std*1000);
fprintf('Method 3 | Exponential curve fit:\n');
fprintf('         Mean = %.4f ms  |  Std Dev = %.4f ms\n\n', tau3_mean*1000, tau3_std*1000);
fprintf('Measured steady-state gain from data (V0/Vin, Vin=1V):\n');
fprintf('         Mean = %.4f  |  Std Dev = %.4f\n\n', gain_meas_mean, gain_meas_std);

% Compare measured tau to cutoff frequency
fprintf('--- Comparison: tau vs. fc ---\n');
fprintf('Expected tau (1/2*pi*fc = 1/2*pi*%.1f): %.4f ms\n', fc, tau_exp*1000);
fprintf('Method 1 fc from tau: %.2f Hz  (omega_c = %.2f rad/s)\n', ...
    1/(2*pi*tau1_mean), 1/tau1_mean);
fprintf('Method 2 fc from tau: %.2f Hz  (omega_c = %.2f rad/s)\n', ...
    1/(2*pi*tau2_mean), 1/tau2_mean);
fprintf('Method 3 fc from tau: %.2f Hz  (omega_c = %.2f rad/s)\n', ...
    1/(2*pi*tau3_mean), 1/tau3_mean);
fprintf('Note: tau [s] = 1/omega_c [rad/s]. To convert: omega_c = 2*pi*fc.\n');

%% 6. Save Results to Text File
results_file = 'results_lab9.txt';
fileID       = fopen(results_file, 'w');
fprintf(fileID, 'Lab 9: First-Order System Transient Response - Analysis Results\n');
fprintf(fileID, '================================================================\n\n');
fprintf(fileID, 'Measured R1         : %.3f kOhm\n', R1/1000);
fprintf(fileID, 'Measured R2         : %.3f kOhm\n', R2/1000);
fprintf(fileID, 'Measured C1         : %.1f nF\n', C1*1e9);
fprintf(fileID, 'Assumed dR1         : +/- %.1f Ohm\n', dR1);
fprintf(fileID, 'Assumed dR2         : +/- %.1f Ohm\n', dR2);
fprintf(fileID, 'Assumed dC1         : +/- %.1f nF\n', dC1*1e9);
fprintf(fileID, 'Calculated |Gain|   : %.6f +/- %.6f\n', gain_mag, gain_unc);
fprintf(fileID, 'Calculated fc       : %.2f Hz\n', fc);
fprintf(fileID, 'Calculated fc unc.  : +/- %.3f Hz\n', fc_unc);
fprintf(fileID, 'Expected tau        : %.4f ms   [tau = 1 / (2*pi*fc)]\n', tau_exp*1000);
fprintf(fileID, 'Expected tau unc.   : +/- %.4f ms\n\n', tau_exp_unc*1000);
fprintf(fileID, 'Method 1 | 95%% threshold  (t = 3*tau):\n');
fprintf(fileID, '  Mean tau = %.4f ms  |  Std Dev = %.4f ms\n', tau1_mean*1000, tau1_std*1000);
fprintf(fileID, '  Derived fc = %.2f Hz\n\n', 1/(2*pi*tau1_mean));
fprintf(fileID, 'Method 2 | 99.3%% threshold  (t = 5*tau):\n');
fprintf(fileID, '  Mean tau = %.4f ms  |  Std Dev = %.4f ms\n', tau2_mean*1000, tau2_std*1000);
fprintf(fileID, '  Derived fc = %.2f Hz\n\n', 1/(2*pi*tau2_mean));
fprintf(fileID, 'Method 3 | Exponential Curve Fit:\n');
fprintf(fileID, '  Mean tau = %.4f ms  |  Std Dev = %.4f ms\n', tau3_mean*1000, tau3_std*1000);
fprintf(fileID, '  Derived fc = %.2f Hz\n\n', 1/(2*pi*tau3_mean));
fprintf(fileID, 'Measured Gain (V0/Vin, Vin=1V):\n');
fprintf(fileID, '  Mean gain = %.4f  |  Std Dev = %.4f\n\n', gain_meas_mean, gain_meas_std);
fprintf(fileID, '----------------------------------------------------------------\n');
fprintf(fileID, 'Per-Run Values:\n');
fprintf(fileID, '%-6s  %-12s  %-12s  %-12s\n', 'Run', 'tau_M1 (ms)', 'tau_M2 (ms)', 'tau_M3 (ms)');
for i = 1:n_runs
    fprintf(fileID, '%-6d  %-12.4f  %-12.4f  %-12.4f\n', ...
        i, tau_method1(i)*1000, tau_method2(i)*1000, tau_method3(i)*1000);
end
fclose(fileID);
fprintf('\nResults saved to: %s\n', results_file);

%% 7. Task 4a - Three Response Curves: 0 <= t <= 6*tau
% Use the Method 3 (curve-fit) mean tau as the best estimate for axis limits.
tau_plot = tau3_mean;
t_6tau   = 6 * tau_plot;
t_5tau   = 5 * tau_plot;
t_4tau   = 4 * tau_plot;

plot_runs = [1, 15, 30];                           % Three representative runs
colors    = {'b', 'r', [0.10 0.65 0.10]};          % Blue, Red, Green

fig1 = figure('Name', 'Lab 9: Step Response (0 to 6tau)', ...
    'Position', [100, 100, 800, 500]);
hold on;

% Track plotted amplitudes in the 0..6*tau window to set a sensible y-range
y_main_max = -inf;

for k = 1:length(plot_runs)
    run_idx = plot_runs(k);
    t_run = response_data{run_idx}.t;
    v_run = response_data{run_idx}.v;

    plot(t_run * 1000, v_run, ...
        'Color', colors{k}, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Run %d', run_idx));

    in_main_window = t_run <= t_6tau;
    if any(in_main_window)
        y_main_max = max(y_main_max, max(v_run(in_main_window)));
    end
end

hold off;
xlim([0, t_6tau * 1000]);
if isfinite(y_main_max)
    ylim([0, 1.05 * y_main_max]);
else
    ylim([0, 1.15]);
end
xlabel('Time (ms)', 'FontWeight', 'bold');
ylabel('Output Voltage (V)', 'FontWeight', 'bold');
title('First-Order Step Response - Three Independent Runs  (0 \leq t \leq 6\tau)', ...
    'FontSize', 13);
legend('Location', 'southeast', 'FontSize', 11);
grid on;
set(gca, 'FontSize', 12);

savefig(fig1, fullfile(figDir, 'Lab9_StepResponse_0to6tau.fig'));
saveas(fig1,  fullfile(figDir, 'Lab9_StepResponse_0to6tau.png'));
fprintf('Figure saved: Lab9_StepResponse_0to6tau.png\n');

%% 8. Task 4b - Zoomed View: 4*tau <= t <= 6*tau with t=5*tau marker
fig2 = figure('Name', 'Lab 9: Step Response Zoomed (4tau to 6tau)', ...
    'Position', [150, 150, 800, 500]);
hold on;

% Track amplitudes only in the zoom window for a tighter y-range
y_zoom_min = inf;
y_zoom_max = -inf;

for k = 1:length(plot_runs)
    run_idx = plot_runs(k);
    t_sec   = response_data{run_idx}.t;
    v       = response_data{run_idx}.v;

    plot(t_sec * 1000, v, 'Color', colors{k}, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Run %d', run_idx));

    % Mark the amplitude at t = 5*tau for each run
    idx_5tau = find(t_sec >= t_5tau, 1, 'first');
    if ~isempty(idx_5tau)
        x_5tau_ms = t_sec(idx_5tau) * 1000;
        y_5tau    = v(idx_5tau);

        plot(x_5tau_ms, y_5tau, 'o', ...
            'MarkerSize', 10, ...
            'MarkerFaceColor', colors{k}, ...
            'MarkerEdgeColor', 'k', ...
            'LineWidth', 1.2, ...
            'HandleVisibility', 'off');

        text(x_5tau_ms + 0.06, y_5tau, sprintf('%.3f V', y_5tau), ...
            'Color', colors{k}, 'FontSize', 10, 'FontWeight', 'bold');
    end

    in_zoom_window = (t_sec >= t_4tau) & (t_sec <= t_6tau);
    if any(in_zoom_window)
        y_zoom_min = min(y_zoom_min, min(v(in_zoom_window)));
        y_zoom_max = max(y_zoom_max, max(v(in_zoom_window)));
    end
end

% Vertical dashed line at t = 5*tau
xline(t_5tau * 1000, '--k', 't = 5\tau', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'left', ...
    'FontSize', 11, 'LineWidth', 1.2, ...
    'HandleVisibility', 'off');

hold off;
xlim([t_4tau * 1000, t_6tau * 1000]);
if isfinite(y_zoom_min) && isfinite(y_zoom_max)
    y_span = max(y_zoom_max - y_zoom_min, 0.01);
    y_pad  = 0.12 * y_span;
    ylim([y_zoom_min - y_pad, y_zoom_max + y_pad]);
end
xlabel('Time (ms)', 'FontWeight', 'bold');
ylabel('Output Voltage (V)', 'FontWeight', 'bold');
title('Step Response - Zoomed View  (4\tau \leq t \leq 6\tau)', 'FontSize', 13);
legend('Location', 'best', 'FontSize', 11);
grid on;
set(gca, 'FontSize', 12);

savefig(fig2, fullfile(figDir, 'Lab9_StepResponse_4to6tau.fig'));
saveas(fig2,  fullfile(figDir, 'Lab9_StepResponse_4to6tau.png'));
fprintf('Figure saved: Lab9_StepResponse_4to6tau.png\n');

fprintf('\nAnalysis complete. All outputs saved.\n');
fprintf('==============================================\n');