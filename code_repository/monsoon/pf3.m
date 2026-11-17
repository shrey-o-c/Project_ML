%% Day-wise error metrics: MAE, RMSE, R^2, MAPE, MBE
clear; clc;

inFile  = 'results1_zeroed.xlsx';      % output of the previous script
outFile = 'daywise_metrics.xlsx';

T = readtable(inFile, 'VariableNamingRule', 'preserve');

ts       = T.('TimeStamp');
actual   = T.('Act. Power (MW)');
forecast = T.('Forecast');

% Segregate by calendar day
dayKey  = dateshift(ts, 'start', 'day');
days    = unique(dayKey);
nDays   = numel(days);

% Preallocate
MAE  = zeros(nDays,1);
RMSE = zeros(nDays,1);
R2   = zeros(nDays,1);
MAPE = zeros(nDays,1);
MBE  = zeros(nDays,1);
N    = zeros(nDays,1);

for d = 1:nDays
    idx = (dayKey == days(d));
    a = actual(idx);
    f = forecast(idx);
    err = f - a;                       % forecast - actual

    N(d)    = numel(a);
    MAE(d)  = mean(abs(err));
    RMSE(d) = sqrt(mean(err.^2));
    MBE(d)  = mean(err);               % positive = over-forecast

    % R^2 = 1 - SS_res / SS_tot
    SSres = sum(err.^2);
    SStot = sum((a - mean(a)).^2);
    if SStot > 0
        R2(d) = 1 - SSres/SStot;
    else
        R2(d) = NaN;                   % undefined if actual is constant
    end

    % MAPE (%): only over points where actual ~= 0 (avoids division by zero)
    nz = abs(a) > 1e-6;
    if any(nz)
        MAPE(d) = mean(abs(err(nz) ./ a(nz))) * 100;
    else
        MAPE(d) = NaN;
    end
end

Date = days;
Results = table(Date, N, MAE, RMSE, R2, MAPE, MBE);

% Overall metrics across all test days (last row)
errAll = forecast - actual;
nzAll  = abs(actual) > 1e-6;
overall = table(NaT, numel(actual), mean(abs(errAll)), sqrt(mean(errAll.^2)), ...
    1 - sum(errAll.^2)/sum((actual-mean(actual)).^2), ...
    mean(abs(errAll(nzAll)./actual(nzAll)))*100, mean(errAll), ...
    'VariableNames', Results.Properties.VariableNames);
Results = [Results; overall];

disp(Results);
writetable(Results, outFile, 'Sheet', 'DayWiseMetrics');
fprintf('Saved to %s\n', outFile);