clc; clear; close all;

% File names
inputFile  = 'results1_zeroed.xlsx';
outputFile = 'Summer_Daily_DSM.xlsx';

% Read data
T = readtable(inputFile);

% Extract columns
Actual   = T.Actual_MW;
Forecast = T.Forecast_MW;

% Error (MW)
ErrorMW = abs(Actual - Forecast);

% Deviation Percentage (against Installed/Contracted Capacity of 21.5 MW)
DeviationPercent = zeros(height(T),1);
idx = Actual > 0;
DeviationPercent(idx) = ErrorMW(idx) ./ (21.5) * 100;

% Deviation Energy (kWh for 15-min block)
DeviationEnergy = ErrorMW * 0.25 * 1000;

% Allocate variables
DSMCharge = zeros(height(T),1);
Violation = strings(height(T),1);

% DSM Calculation
for i = 1:height(T)
    p = DeviationPercent(i);
    e = DeviationEnergy(i);
    
    if Actual(i) == 0
        Violation(i) = "No Generation";
        DSMCharge(i) = 0;
    elseif p <= 7
        Violation(i) = "<=7%";
        DSMCharge(i) = 0;
    elseif p <= 15
        Violation(i) = "7-15%";
        % energy in 0-7% (exempt) + energy in 7-15% (penalized @ ₹0.25)
        energy_7_15 = e * (p - 7) / p;
        DSMCharge(i) = 0.25 * energy_7_15;
    elseif p <= 23
        Violation(i) = "15-23%";
        % Slabs breakdown:
        % 0-7%: exempt | 7-15%: @ ₹0.25 | 15-p%: @ ₹0.50
        energy_7_15  = e * (15 - 7) / p;
        energy_15_23 = e * (p - 15) / p;
        DSMCharge(i) = 0.25 * energy_7_15 + 0.50 * energy_15_23;
    else
        Violation(i) = ">23%";
        % Slabs breakdown:
        % 0-7%: exempt | 7-15%: @ ₹0.25 | 15-23%: @ ₹0.50 | >23%: @ ₹0.75
        energy_7_15  = e * (15 - 7) / p;   % 8/p of e
        energy_15_23 = e * (23 - 15) / p;  % 8/p of e
        energy_above_23 = e * (p - 23) / p;
        DSMCharge(i) = 0.25 * energy_7_15 + 0.50 * energy_15_23 + 0.75 * energy_above_23;
    end
end

% Add columns to table
T.Error_MW = ErrorMW;
T.Deviation_Percent = DeviationPercent;
T.Deviation_Energy_kWh = DeviationEnergy;
T.Violation_Slab = Violation;
T.DSM_Charge_Rs = DSMCharge;

% Write updated sheet
writetable(T, outputFile, 'Sheet', 'Sheet1');

% Overall Summary Table
Summary = table;
Summary.Total_DSM_Charge = sum(DSMCharge);
Summary.Total_Error_MW = sum(ErrorMW);
Summary.Total_Deviation_Energy_kWh = sum(DeviationEnergy);

Summary.Blocks_Below_7  = sum(Violation == "<=7%");
Summary.Blocks_7_to_15  = sum(Violation == "7-15%");
Summary.Blocks_15_to_23 = sum(Violation == "15-23%");
Summary.Blocks_Above_23 = sum(Violation == ">23%");

TotalBlocks = height(T);

Summary.Percent_Below_7  = 100 * Summary.Blocks_Below_7 / TotalBlocks;
Summary.Percent_7_to_15  = 100 * Summary.Blocks_7_to_15 / TotalBlocks;
Summary.Percent_15_to_23 = 100 * Summary.Blocks_15_to_23 / TotalBlocks;
Summary.Percent_Above_23 = 100 * Summary.Blocks_Above_23 / TotalBlocks;

Summary.Total_Violation_Blocks = Summary.Blocks_7_to_15 + ...
                                  Summary.Blocks_15_to_23 + ...
                                  Summary.Blocks_Above_23;

Summary.Total_Violation_Percent = 100 * Summary.Total_Violation_Blocks / TotalBlocks;

% Write summary sheet
writetable(Summary, outputFile, 'Sheet', 'Summary');

disp('Done! Corrected DSM calculation completed.');