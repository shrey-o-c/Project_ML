% Data extracted from the provided dataset
dates = datetime({'08-06-26', '09-06-26', '10-06-26', '11-06-26', '12-06-26', '13-06-26', '14-06-26'}, ...
    'InputFormat', 'dd-MM-yy');
MAE  = [0.891073609; 1.080644814; 1.181676823; 0.784132527; 0.797052939; 1.307386726; 1.688166497];
RMSE = [1.61809249; 1.77734594; 2.01197248; 1.60456099; 1.45200588; 2.65728655; 2.90605631];

% Create Figure
figure;

% --- Left Axis (Primary Y-Axis: MAE) ---
yyaxis left
plot(dates, MAE, '-o', 'LineWidth', 2, 'MarkerSize', 6);
ylabel('MAE (MW)', 'FontWeight', 'bold', 'FontSize', 12);

% --- Right Axis (Secondary Y-Axis: RMSE) ---
yyaxis right
plot(dates, RMSE, '-s', 'LineWidth', 2, 'MarkerSize', 6);
ylabel('RMSE (MW)', 'FontWeight', 'bold', 'FontSize', 12);

% --- Axes Customization ---
ax = gca;
% Turn off top/right plot frame box border line
box off;

% Format X-Axis ticks and remove the extra year label
xtickformat('dd-MMM'); % Displays as '08-Jun', '09-Jun', etc. (no year)
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.XAxis.SecondaryLabel.Visible = 'off'; % Removes the automatic '2026' year label

% Make BOTH Y-Axes tick labels bold (1 = Left/Primary, 2 = Right/Secondary)
ax.YAxis(1).FontSize = 12;
ax.YAxis(1).FontWeight = 'bold';
ax.YAxis(2).FontSize = 12;
ax.YAxis(2).FontWeight = 'bold';

% Labels and Title
xlabel('Day', 'FontWeight', 'bold', 'FontSize', 12);
title('Daily MAE and RMSE Comparison', 'FontSize', 14, 'FontWeight', 'bold');

% Legend
legend({'MAE (MW)', 'RMSE (MW)'}, 'Location', 'northeast', 'FontSize', 10, 'FontWeight', 'bold');

set(gcf, 'Units', 'inches');
set(gcf, 'Position', [1, 1, 6, 4]); 
set(gcf, 'PaperPositionMode', 'auto');
uiwait(msgbox('Adjust the legend/layout manually, then close this message to save the figure.'));
print('MAE_RMSE', '-dpng', '-r300');