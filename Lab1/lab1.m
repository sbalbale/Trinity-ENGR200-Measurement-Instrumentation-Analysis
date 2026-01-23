%step 1

%import testdata1.csv
% our vectors as t, x, y, and z
data = csvread('testdata1.csv', 0, 0);
t = data(:, 1);
x = data(:, 2);
y = data(:, 3);
z = data(:, 4);

% plot x, y, and z vs t in a single figure with 3 subplots
figure; % create a new figure window
plot(t, x, 'k-', 'LineWidth', 2); % x data: black solid line
hold on; % hold on to add more plots
plot(t, y, 'r--', 'LineWidth', 2); % y data: red dashed line
plot(t, z, 'b:', 'LineWidth', 2); % z data: blue dotted line
hold off; % release hold
legend('x', 'y', 'z', 'Location', 'southeast'); % add legend
xlim([3.5 4]); % set x-axis limits
xlabel('time (seconds)');
ylabel('voltage');
set(gca, 'FontSize', 14);

%step 2

% import testdata2.csv
% our vectors as f, p1, p2, and p3
data2 = csvread('testdata2.csv', 0, 0);
f = data2(:, 1);
p1 = data2(:, 2);
p2 = data2(:, 3);
p3 = data2(:, 4);

% plot p1, p2, and p3 vs f in a single figure with semilogy
figure; % create a new figure window
semilogy(f, p1, 'k-', 'LineWidth', 1.5); % p1 data: black solid line
hold on; % hold on to add more plots
semilogy(f, p2, 'r--', 'LineWidth', 1.5); % p2 data: red dashed line
semilogy(f, p3, 'b:', 'LineWidth', 1.5); % p3 data: blue dotted line
hold off; % release hold
grid on; % turn the grid on
legend('p1', 'p2', 'p3', 'Location', 'northeast'); % add legend
xlim([0 500]); % set x-axis limits
xlabel('frequency (hertz)');
ylabel('power spectrum');
set(gca, 'FontSize', 13);

%step 3

% plot p1, p2, and p3 vs f in a single figure with loglog
figure; % create a new figure window
loglog(f, p1, 'k-', 'LineWidth', 1.5); % p1 data: black solid line
hold on; % hold on to add more plots
loglog(f, p2, 'r--', 'LineWidth', 1.5); % p2 data: red dashed line
loglog(f, p3, 'b:', 'LineWidth', 1.5); % p3 data: blue dotted line
hold off; % release hold
grid on; % turn the grid on
legend('p1', 'p2', 'p3', 'Location', 'northeast'); % add legend
xlabel('frequency (hertz)');
ylabel('power spectrum');
set(gca, 'FontSize', 13);
