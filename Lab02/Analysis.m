% Lab 2: Probability and Statistics in Data Analysis
% Part 4 & 5: Data Analysis and Visualization

clear; clc; close all;

% List of dataset filenames to process
files = {'dataset_fixed.csv', 'dataset_fast.csv', 'dataset_random.csv'};
titles = {'Dataset 1: Fixed-Rate', 'Dataset 2: High-Rate', 'Dataset 3: Random'};

for i = 1:length(files)
    filename = files{i};
    
    % 1. Import Data
    % Check if file exists to prevent errors
    if ~isfile(filename)
        fprintf('Error: %s not found. Run the data collection step first.\n', filename);
        continue;
    end
    
    data = readmatrix(filename); % Import as column vector
    
    % 2. Compute Statistics 
    mu = mean(data);           % Mean
    sigma = std(data);         % Standard Deviation
    variance = var(data);      % Variance
    N = length(data);          % Number of samples
    
    % Display Numerical Results in Command Window
    fprintf('--------------------------------------------------\n');
    fprintf('Statistics for %s (%s)\n', titles{i}, filename);
    fprintf('--------------------------------------------------\n');
    fprintf('Number of Samples (N): %d\n', N);
    fprintf('Mean:                  %.4f\n', mu);
    fprintf('Standard Deviation:    %.4f\n', sigma);
    fprintf('Variance:              %.4f\n', variance);
    fprintf('\n');
    
    % 3. Generate Normalized Histogram (PDF Estimate) 
    figure(i);
    clf; hold on;
    
    % Histogram with normalization to estimate Probability Density Function
    h = histogram(data, 'Normalization', 'pdf', 'FaceColor', [0.8 0.8 0.8]);
    
    % 4. Overlay Lines for Mean and +/- 3 Sigma
    % Mean line (Vertical, distinct color/style)
    xline(mu, '-r', 'LineWidth', 2, 'DisplayName', 'Mean');
    
    % +3 Sigma line (Vertical dashed)
    xline(mu + 3*sigma, '--b', 'LineWidth', 1.5, 'DisplayName', '+3\sigma');
    
    % -3 Sigma line (Vertical dashed)
    xline(mu - 3*sigma, '--b', 'LineWidth', 1.5, 'DisplayName', '-3\sigma');
    
    % Formatting
    title(titles{i});
    xlabel('ADC Value (0-1023)');
    ylabel('Probability Density');
    legend('show');
    grid on;
    hold off;
end