% Engineering 200 - Lab 2: Data Analysis & Visualization
% Generates 3 separate figures with Mean and +/- 3 Sigma overlays
% Author: Sean Balbale
% Date: 1/30/2026

clear; clc; close all;

% File Setup
filenames = {'dataset_fixed.csv', 'dataset_fast.csv', 'dataset_random.csv'};
plotTitles = {'Dataset 1: Fixed-Rate Sampling', ...
              'Dataset 2: High-Rate Sampling', ...
              'Dataset 3: Random Sampling'};

% Loop through each dataset to create a separate figure
for i = 1:length(filenames)
    
    % 1. Import Data
    if ~isfile(filenames{i})
        fprintf('Error: %s not found. Run the data collection first.\n', filenames{i});
        continue;
    end
    data = readmatrix(filenames{i});
    
    % 2. Compute Statistics (Required for the lines)
    mu = mean(data);
    sigma = std(data);
    
    % 3. Create Figure
    figure(i);
    clf; hold on;
    
    % -- Requirement: Normalized Histogram (PDF Estimate) --
    h = histogram(data, 'Normalization', 'pdf', ...
                  'FaceColor', [0.7 0.7 0.7], ...
                  'EdgeColor', 'k', ...
                  'DisplayName', 'PDF Estimate');
    
    % -- Requirement: Vertical Line Indicating Mean --
    xline(mu, '-r', 'LineWidth', 2, 'DisplayName', 'Mean');
    
    % -- Requirement: Vertical Dashed Lines for +/- 3 Sigma --
    xline(mu + 3*sigma, '--b', 'LineWidth', 1.5, 'DisplayName', '+3\sigma');
    xline(mu - 3*sigma, '--b', 'LineWidth', 1.5, 'DisplayName', '-3\sigma');
    
    % -- Requirement: Figure Formatting --
    title(plotTitles{i}, 'FontSize', 14);    % Title
    xlabel('ADC Value (0-1023)', 'FontSize', 12);  % X-axis label
    ylabel('Probability Density', 'FontSize', 12); % Y-axis label
    
    % -- Requirement: Legend --
    legend('show', 'Location', 'best');
    
    grid on;
    hold off;
    
    % Optional: Print stats to command window for your table
    fprintf('Stats for %s:\n Mean: %.2f\n StdDev: %.2f\n Var: %.2f\n\n', ...
            plotTitles{i}, mu, sigma, var(data));
end