% Data extracted from daywise_metrics.xlsx
dates = datetime({'08-10-25', '09-10-25', '10-10-25', '11-10-25', '12-10-25', '13-10-25', '14-10-25'}, ...
    'InputFormat', 'dd-MM-yy');
MAE  = [1.448790802; 1.801551232; 1.020491534; 1.488266213; 1.503882974; 1.281100833; 1.332093035];
RMSE = [2.595690935; 2.967109710; 1.974953982; 2.403170962; 2.437037211; 2.123568722; 2.152416913];

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
xtickformat('dd-MMM'); % Displays as '08-Oct', '09-Oct', etc.
ax.XAxis.FontSize = 12;
ax.XAxis.FontWeight = 'bold';
ax.XAxis.SecondaryLabel.Visible = 'off'; % Removes the automatic year label

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