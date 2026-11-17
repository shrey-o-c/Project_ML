% Full list of years/categories
years_all = {'2008-09', '2009-10', '2010-11', '2011-12', ...
             '2012-13', '2013-14', '2014-15', '2015-16', ...
             '2016-17', '2017-18', '2018-19', '2019-20', ...
             '2020-21', '2021-22', '2022-23', '2023-24', ...
             '2024-25', '2025-26', '2026-27 (till Sept)'};

% Capacity values in MW converted to GW (MW / 1000)
capacity_MW = [0, 8.07, 24.87, 906.09, 745.2, 945.52, 2246.92, 1883.97, ...
               5525.98, 9362.65, 6529.23, 6447.11, 5457.55, 13911.17, ...
               12783.8, 15033.26, 23832.87, 44614.25, 20790.76];
capacity_GW = capacity_MW / 1000;

% Create Figure
figure('Position', [100, 100, 900, 450]);

% Plot bar graph using numeric indices for precise tick control
b = bar(1:length(capacity_GW), capacity_GW, 'FaceColor', [0.15 0.55 0.82], 'EdgeColor', 'none');

% Define label spacing interval (e.g., step = 2 shows every second year, step = 3 shows every third)
step = 2; 
tick_indices = 1:step:length(years_all);

% Set X-ticks and Labels
xticks(tick_indices);
xticklabels(years_all(tick_indices));
xtickangle(35);

% Labels & Formatting
xlabel('Year', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Capacity (GW)', 'FontSize', 12, 'FontWeight', 'bold');

% Grid and Clean Layout
grid on;
ax = gca;
ax.GridAlpha = 0.2;
ax.FontSize = 10;
xlim([0.2, length(years_all) + 0.8]);

% Add grid lines for better readability
grid off;
box off;
ax = gca;
ax.GridAlpha = 0.3;

% Rotate x-axis ticks for clarity
xtickangle(45);
ax = gca;
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 12;
ax.YAxis.FontWeight = 'bold';
xlabel('Year', 'FontWeight', 'bold', 'FontSize', 12);
ylabel('Capacity (GW)', 'FontWeight', 'bold', 'FontSize', 12);
title('Solar Capacity Growth', 'FontSize', 14, 'FontWeight', 'bold');

set(gcf, 'Units', 'inches');
set(gcf, 'Position', [1, 1, 6, 5]); 
set(gcf, 'PaperPositionMode', 'auto');
% uiwait(msgbox('Adjust the legend manually, then close this message to save the figure.'));
print('Solar Trend', '-dpng', '-r300');