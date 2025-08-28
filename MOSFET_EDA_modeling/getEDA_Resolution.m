function [EDA_Resolution, rangeEDA, maxEDA, minEDA] = getEDA_Resolution(Ids, bit)
Ids = Ids / 1000000;%A
ADC_Resolution = 3.3 / 2^bit;

Vin = 0.5;

maxVout = 3.3;
minVout = Vin+ADC_Resolution;
% bit = 16;
n_bit = int32((maxVout - minVout) / ADC_Resolution);

minEDA = Ids ./ (maxVout-Vin) * 1000000;%uS
maxEDA = Ids ./(minVout-Vin) * 1000000;%uS
rangeEDA = maxEDA - minEDA;%uS
EDA_Resolution = (maxEDA - minEDA) / double(n_bit);%uS/bit

% th1 = ones(31, 31) * 0.01;  % 1로 채워진 31x31 행렬
% th2 = ones(31, 31) * 0.05;  % 1로 채워진 31x31 행렬
% th3 = ones(31, 31) * 0.1;  % 1로 채워진 31x31 행렬

% figure
% surf(EDA_Resolution)
% hold on
% mesh(th1)
% hold on
% mesh(th2)
% hold on
% mesh(th3)
% hold off
% xlim([1,31])
% ylim([1,31])