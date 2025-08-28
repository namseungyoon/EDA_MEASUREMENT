clear all
close all

Ids = load("Ids.mat").Ids;
Rds = load("Rds.mat").Rds;
Vgs = load("Vgs.mat").Vgs;
Vout_min = 0.5001;
Vout_max = 3.3;
Vin = 0.5;

Rds_max = max(Rds);
Rds_min = min(Rds);


for i = 1:length(Rds)
    Rskin_min = ( (Vout_min/Vin) - 1) * Rds(i);
    Rskin_max = ( (Vout_max/Vin) - 1) * Rds(i);
    EDA_max(i,1) = 1/Rskin_min;
    EDA_min(i,1) = 1/Rskin_max;
    EDA_minmax = EDA_max(i,1) - EDA_min(i,1);
    EDA_resolution(i,1) = EDA_minmax / 65536;
    % disp(['EDA_min = ', string(EDA_min), 'EDA_max = ', string(EDA_max)]);
end

figure();
plot(Vgs, EDA_max);
hold on;
plot(Vgs, EDA_min);
xlim([0.8, 0.9]);
ylim([-0.01, 300]);


