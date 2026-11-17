%% ========================================================================
%  Day-ahead Solar Power Forecast (Linear Regression)
%  Same style / workflow as Winter.m and Winter_2.m
%    1) Actual vs Forecast with DSM +/-7% band (each day + 7-day view)
%    2) Performance metrics: MAE, RMSE, MAPE, MBE, R2 (overall + daily)
%    3) Error distribution (histogram + Gaussian fit)
%    4) Feature-selection summary (feature_selection.csv)
% ========================================================================
clc; clear; close all;

%% ---------------- User settings ----------------
xlsxFile    = 'results1_zeroed.xlsx';
% featFile    = 'feature_selection.csv';
Capacity    = 21.5;                 % plant capacity (MWp)
DSM_limit   = 0.07 * Capacity;      % +/-7 % band (MW)  [Winter.m: 0.07*21.5]
interactive = false;                % true -> pause so you can adjust legend before saving
dpi         = '-r400';

%% ---------------- Load data ----------------
% Columns are read by POSITION (1 = TimeStamp, 2 = Actual, 3 = Forecast),
% so this works on older MATLAB versions regardless of header renaming.
T  = readtable(xlsxFile, 'Sheet', 'Sheet1');
ts = T{:,1};
if iscell(ts) || isstring(ts) || ischar(ts)
    ts = datetime(ts);
elseif isnumeric(ts)
    ts = datetime(ts, 'ConvertFrom', 'excel');
end

Actual   = double(T{:,2});
Forecast = double(T{:,3});

dayID = dateshift(ts, 'start', 'day');
days  = unique(dayID);
nDays = numel(days);

%% ---------------- Performance metrics (overall) ----------------
idx   = Actual ~= 0;                       % daytime samples for MAPE
Error = Actual - Forecast;                 % same sign convention as Winter_2.m

MAE_LR  = mean(abs(Error));
RMSE_LR = sqrt(mean(Error.^2));
MAPE_LR = mean(abs(Error(idx)) ./ Actual(idx)) * 100;
MBE_LR  = mean(Error);
R2_LR   = 1 - sum(Error.^2) / sum((Actual - mean(Actual)).^2);

fprintf('\n================ LR (overall, %d days) ================\n', nDays);
fprintf('MAE  = %.4f MW\n', MAE_LR);
fprintf('RMSE = %.4f MW\n', RMSE_LR);
fprintf('MAPE = %.4f %%\n', MAPE_LR);
fprintf('MBE  = %.4f MW\n', MBE_LR);
fprintf('R2   = %.4f\n',    R2_LR);

%% ---------------- Daily metrics ----------------
dMAE = zeros(nDays,1); dRMSE = dMAE; dMAPE = dMAE; dMBE = dMAE; dR2 = dMAE;
for k = 1:nDays
    m  = (dayID == days(k));
    a  = Actual(m);  f = Forecast(m);  e = a - f;  ix = a ~= 0;
    dMAE(k)  = mean(abs(e));
    dRMSE(k) = sqrt(mean(e.^2));
    dMAPE(k) = mean(abs(e(ix)) ./ a(ix)) * 100;
    dMBE(k)  = mean(e);
    dR2(k)   = 1 - sum(e.^2) / sum((a - mean(a)).^2);
end
dailyTbl = table(days, dMAE, dRMSE, dMAPE, dMBE, dR2, ...
    'VariableNames', {'Date','MAE','RMSE','MAPE','MBE','R2'});
disp(' '); disp('================ DAILY METRICS ================'); disp(dailyTbl);

writetable(dailyTbl, 'daily_metrics_matlab.csv');
writetable(table(MAE_LR,RMSE_LR,MAPE_LR,MBE_LR,R2_LR, ...
    'VariableNames',{'MAE','RMSE','MAPE','MBE','R2'}), 'overall_metrics_matlab.csv');

[~, bestK]  = min(dMAE);
[~, worstK] = max(dMAE);
fprintf('Best day : %s (MAE = %.4f)\n', datestr(days(bestK),'yyyy-mm-dd'),  dMAE(bestK));
fprintf('Worst day: %s (MAE = %.4f)\n', datestr(days(worstK),'yyyy-mm-dd'), dMAE(worstK));

%% ================= FIGURES: Actual vs Forecast, one per day =================
% (replicates Winter.m: DSM band, 96 time blocks, bold fonts, 6x4 in, 400 dpi)
for k = 1:nDays
    m = (dayID == days(k));
    A = Actual(m);  F = Forecast(m);
    x = 1:length(A);

    upper = A + DSM_limit;
    lower = A - DSM_limit;

    figure;
    fill([x fliplr(x)], [upper' fliplr(lower')], ...
         [0.90 0.90 0.90], 'EdgeColor','none');
    hold on
    plot(x, A, 'Color', [0.93 0.69 0.13], 'LineWidth', 1.5);
    plot(x, F, 'Color', [0.9 0.2 0.2],   'LineWidth', 2);

    ylim([0 23]);  set(gca, 'YTick', 0:5:20);
    xlim([0 97]);  set(gca, 'XTick', [1:8:96 96]);

    legend('DSM \pm7% band','Actual','LR forecast', ...
           'Orientation','vertical','FontWeight','bold','FontSize',11);
    xlabel('Time block (15-min interval)');
    ylabel('Power (MW)');
    title(datestr(days(k),'yyyy-mm-dd'));
    box off;

    ax = gca;
    ax.XAxis.FontSize = 14;  ax.XAxis.FontWeight = 'bold';
    ax.YAxis.FontSize = 14;  ax.YAxis.FontWeight = 'bold';
    ax.XAxis.Label.FontSize = 14;  ax.XAxis.Label.FontWeight = 'bold';

    set(gcf, 'Units', 'inches', 'Position', [1, 1, 6, 4]);
    set(gcf, 'PaperPositionMode', 'auto');
    if interactive
        uiwait(msgbox('Adjust the legend manually, then close this message to save the figure.'));
    end
    print(sprintf('Forecast_Day%d', k), '-dpng', dpi);
end

%% ================= FIGURE: 7-day continuous Actual vs Forecast =================
figure;
xAll = 1:numel(Actual);
fill([xAll fliplr(xAll)], [(Actual+DSM_limit)' fliplr((Actual-DSM_limit)')], ...
     [0.90 0.90 0.90], 'EdgeColor','none');
hold on
plot(xAll, Actual,   'Color', [0.93 0.69 0.13], 'LineWidth', 1.2);
plot(xAll, Forecast, 'Color', [0.9 0.2 0.2],   'LineWidth', 1.5);
ylim([0 23]);  set(gca, 'YTick', 0:5:20);
xlim([0 numel(Actual)+1]);
set(gca, 'XTick', 48:96:numel(Actual), 'XTickLabel', 1:nDays);
for k = 1:nDays-1
    line([96*k 96*k], [0 23], 'LineStyle',':', 'Color',[0.6 0.6 0.6]);
end
legend('DSM \pm7% band','Actual','LR forecast', ...
       'Orientation','horizontal','FontWeight','bold','FontSize',11, 'Location','northoutside');
xlabel('Day');  ylabel('Power (MW)');
box off;
ax = gca;
ax.XAxis.FontSize = 14;  ax.XAxis.FontWeight = 'bold';
ax.YAxis.FontSize = 14;  ax.YAxis.FontWeight = 'bold';
ax.XAxis.Label.FontSize = 14;  ax.XAxis.Label.FontWeight = 'bold';
set(gcf, 'Units', 'inches', 'Position', [1, 1, 12, 4]);
set(gcf, 'PaperPositionMode', 'auto');
if interactive
    uiwait(msgbox('Adjust the legend manually, then close this message to save the figure.'));
end
print('Forecast_7Days', '-dpng', dpi);

%% ================= FIGURE: Daily metrics (MAE, RMSE, MAPE, R2) =================
% figure;
% mets   = {dMAE, dRMSE, dMAPE, dR2};
% labels = {'MAE (MW)','RMSE (MW)','MAPE (%)','R^2'};
% for p = 1:4
%     subplot(2,2,p);
%     plot(1:nDays, mets{p}, '-o', 'Color',[0.9 0.2 0.2], 'LineWidth',1.5, ...
%          'MarkerFaceColor',[0.9 0.2 0.2]);
%     xlabel('Day');  ylabel(labels{p});  set(gca, 'XTick', 1:nDays);  box off;
%     ax = gca;
%     ax.XAxis.FontSize = 12;  ax.XAxis.FontWeight = 'bold';
%     ax.YAxis.FontSize = 12;  ax.YAxis.FontWeight = 'bold';
% end
% set(gcf, 'Units', 'inches', 'Position', [1, 1, 9, 6]);
% set(gcf, 'PaperPositionMode', 'auto');
% print('Daily_Metrics', '-dpng', dpi);

%% ================= FIGURE: Error distribution (replicates Winter_2.m) =================
% Left: all samples (incl. night)   Right: daytime samples only (Actual ~= 0)
gauss = @(x,mu,s) exp(-0.5*((x-mu)./s).^2) ./ (s*sqrt(2*pi));   % no toolbox needed

sets   = {Error, Error(idx)};
titles = {'All samples','Daytime samples'};
cols   = {[0.90 0.20 0.20], [0.25 0.68 0.88]};

xmin = min(Error);  xmax = max(Error);
edges = (floor(xmin/0.5)*0.5 - 0.25) : 0.5 : (ceil(xmax/0.5)*0.5 + 0.25);
xg = linspace(xmin, xmax, 500);

figure;
for p = 1:2
    E = sets{p};
    subplot(1,2,p)
    histogram(E, 'BinEdges',edges, 'Normalization','pdf', ...
        'FaceColor',cols{p}, 'EdgeColor','k');
    hold on
    mu = mean(E);  sigma = std(E);
    plot(xg, gauss(xg,mu,sigma), 'k', 'LineWidth',1.5)
    yl = ylim;  plot([0 0], yl, '--b', 'LineWidth',1);  ylim(yl);

    text(0.05, 0.70, sprintf('\\mu = %.4f MW\n\\sigma = %.4f MW', mu, sigma), ...
        'Units','normalized','FontSize',10,'FontWeight','bold', ...
        'BackgroundColor','w','EdgeColor','none','Margin',4);

    xlabel('Forecast error (MW)');  ylabel('Probability density');
    grid off;  box off;
    ax = gca;
    ax.XAxis.FontSize = 14;  ax.XAxis.FontWeight = 'bold';
    ax.YAxis.FontSize = 14;  ax.YAxis.FontWeight = 'bold';
    ax.XAxis.Label.FontSize = 14;  ax.XAxis.Label.FontWeight = 'bold';
    legend(['LR (' titles{p} ')'], 'Gaussian fit', 'Zero error', ...
        'Orientation','vertical','FontWeight','bold','FontSize',9);

    fprintf('%s: Mean = %.4f  Std = %.4f  min = %.3f  max = %.3f\n', ...
        titles{p}, mu, sigma, min(E), max(E));
end
set(gcf, 'Units','inches', 'Position',[1 1 9 4]);
set(gcf, 'PaperPositionMode','auto');
if interactive
    uiwait(msgbox('Adjust the legend manually, then close this message to save the figure.'));
end
print('Error_Distribution', '-dpng', dpi);

%% ================= Feature selection summary (fixed) =================
% Column access by POSITION (1 = Feature Set, 2 = No. of Features, 3 = R2_val),
% so it does not depend on how MATLAB renames the headers.
% if exist(featFile, 'file') == 2
%     F  = readtable(featFile);
%     [~, ord] = sort(F{:,3}, 'descend');
%     F  = F(ord,:);
% 
%     bestSet = char(F{1,1});
%     bestN   = F{1,2};
%     bestR2  = F{1,3};
%     fprintf('\nBest feature set (%d features, R2_val = %.6f):\n  %s\n', ...
%         bestN, bestR2, bestSet);
% 
%     top = min(10, height(F));
%     figure;
%     bar(F{1:top,3}, 'FaceColor',[0.9 0.2 0.2], 'EdgeColor','k');
%     ylim([min(F{1:top,3})-2e-5, max(F{1:top,3})+2e-5]);
%     xlabel('Feature set rank');  ylabel('Validation R^2');
%     box off;
%     ax = gca;
%     ax.XAxis.FontSize = 14;  ax.XAxis.FontWeight = 'bold';
%     ax.YAxis.FontSize = 14;  ax.YAxis.FontWeight = 'bold';
%     set(gcf, 'Units','inches', 'Position',[1 1 7 4]);
%     set(gcf, 'PaperPositionMode','auto');
%     print('Feature_Selection', '-dpng', dpi);
% end
% 
% fprintf('\nDone. Figures and metric tables saved in the current folder.\n');

%% ================= FIGURE: Day-wise Actual vs Forecast Scatter (Goodness of Fit) =================
figure;
% Calculate total subplots needed and layout dimensions (e.g., 3 columns)
nCols = 3;
nRows = ceil(nDays / nCols);

for k = 1:nDays
    m = (dayID == days(k));
    A = Actual(m); 
    F = Forecast(m);

    subplot(nRows, nCols, k);

    % 1. Scatter plot of Actual vs Forecast
    scatter(A, F, 25, [0.9 0.2 0.2], 'filled', 'MarkerFaceAlpha', 0.7);
    hold on;

    % 2. 1:1 Reference Line (y = x)
    plot([0 23], [0 23], '--k', 'LineWidth', 1.2);

    % Formatting and labels
    xlim([0 23]); ylim([0 23]);
    set(gca, 'XTick', 0:5:20, 'YTick', 0:5:20);
    xlabel('Actual (MW)');
    ylabel('Forecast (MW)');
    title(sprintf('%s (R^2 = %.4f)', datestr(days(k), 'yyyy-mm-dd'), dR2(k)));
    grid off; box off;

    % Axis property formatting matching previous figures
    ax = gca;
    ax.XAxis.FontSize = 10; ax.XAxis.FontWeight = 'bold';
    ax.YAxis.FontSize = 10; ax.YAxis.FontWeight = 'bold';
    ax.XAxis.Label.FontSize = 11; ax.XAxis.Label.FontWeight = 'bold';
    ax.YAxis.Label.FontSize = 11; ax.YAxis.Label.FontWeight = 'bold';
    ax.Title.FontSize = 11; ax.Title.FontWeight = 'bold';

    if k == 1
        legend('Data Points', '1:1 Line (y=x)', ...
            'Location', 'northwest', 'FontWeight', 'bold', 'FontSize', 8);
    end
end

% Adjust canvas dimensions proportionally based on layout rows
set(gcf, 'Units', 'inches', 'Position', [1, 1, 10, 3 * nRows]);
set(gcf, 'PaperPositionMode', 'auto');

if interactive
    uiwait(msgbox('Adjust the legend/layout manually, then close this message to save the figure.'));
end

print('Forecast_Scatter_Daywise', '-dpng', dpi);