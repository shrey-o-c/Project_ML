%% Zero out forecasts wherever actual power is zero
clear; clc;

inFile  = 'results1.xlsx';
outFile = 'results1_zeroed.xlsx';

% Read the table (keeps original headers and timestamps)
T = readtable(inFile, 'VariableNamingRule', 'preserve');

actual   = T.('Act. Power (MW)');
forecast = T.('Forecast');

% Set forecast to 0 where actual is 0
forecast(actual == 0) = 0;

% Optional: also clip negative forecasts to 0 (solar power can't be negative)
% forecast(forecast < 0) = 0;

T.('Forecast') = forecast;

% Write to a new Excel file
writetable(T, outFile, 'Sheet', 'Sheet1');

fprintf('Done. %d forecast values set to 0. Saved to %s\n', ...
    nnz(actual == 0), outFile);