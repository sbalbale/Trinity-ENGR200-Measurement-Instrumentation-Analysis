% Script to save all .fig files in the 'figures' directory to .png format

% Define the directory containing the figures
figuresDir = 'figures';
outputDir = 'pictures';

% Create output directory if it doesn't exist
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Get a list of all .fig files in the directory
fileList = dir(fullfile(figuresDir, '*.fig'));

% Loop through each file
for i = 1:length(fileList)
    % Get the full path to the figure file
    figFile = fullfile(figuresDir, fileList(i).name);
    
    % Open the figure
    % 'invisible' prevents the figure from popping up on the screen
    h = openfig(figFile, 'invisible');
    
    % Construct the output filename
    [~, name, ~] = fileparts(fileList(i).name);
    outputFilename = fullfile(outputDir, [name '.png']);
    
    % Save the figure as a PNG
    fprintf('Saving %s to %s...\n', fileList(i).name, outputFilename);
    saveas(h, outputFilename, 'png');
    
    % Close the figure
    close(h);
end

fprintf('All figures saved successfully.\n');
