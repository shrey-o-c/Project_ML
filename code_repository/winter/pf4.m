% Data extracted from the provided dataset
dates = datetime({'08-02-26', '09-02-26', '10-02-26', '11-02-26', '12-02-26', '13-02-26', '14-02-26'}, ...
                 'InputFormat', 'dd-MM-yy');
MAE  = [0.739409; 0.369303; 1.111813; 0.692907; 0.523799; 0.533321; 0.785381];
RMSE = [1.377854; 0.733249; 1.896175; 1.266639; 1.051002; 0.990705; 1.374064];

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
xtickformat('dd-MMM'); % Displays as '08-Feb', '09-Feb', etc. (no year)
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
print('MAE_RMSE', '-dpng', '-r300');


