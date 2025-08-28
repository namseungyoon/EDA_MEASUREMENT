clear all
close all

load("Ids_data/Ids_data_008.mat");
Ids = Ids_data.Ids;
Vin = Ids_data.Vin;
Vout = Ids_data.Vout;
DAC_value = Ids_data.DAC_value;
Vgs = Ids_data.Vgs;
Rfeed = Ids_data.Rfeed;

% Moving average function
windowSize = 5; % You can change the window size
movingAvg = @(data, windowSize) filter(ones(1, windowSize) / windowSize, 1, data);

NMSEs = [];
alphas = [];
init_alpha = abs(min(Ids));
idx = 1:1:300;
for i = idx
    alpha = (i*0.001)+init_alpha;
    alphas(i,1) = alpha;
    Ids_a = Ids + alpha;
    
    ln_Ids_a = log(Ids_a);
    v = Vgs;
    
    X = [v.*v.*v.*v.*v.*v, v.*v.*v.*v.*v, v.*v.*v.*v, v.*v.*v, v.*v, v, ones(length(v), 1)];
    coef = (X'*X)^-1*X'*ln_Ids_a;
    coefs(:,i) = coef;
    ln_Ids_a_ = X * coef;
    
    Ids_ = exp(ln_Ids_a_) - alpha;
    %%
    % for plot
    % figure();
    % NMSE 
    x=log10(Ids);
    y=log10(Ids_);
    NMSE=((x-y)'*(x-y))/(x'*x)
    NMSEs(i, 1) = NMSE;
    [min_NMSE, min_index] = min(NMSEs);

end


Ids = Ids + alphas(min_index);
Rds = Vin ./ Ids;

v = Vgs;
X = [v.*v.*v.*v.*v.*v, v.*v.*v.*v.*v, v.*v.*v.*v, v.*v.*v, v.*v, v, ones(length(v), 1)];

coef = coefs(:,min_index);
ln_Ids_a_ = X * coef;

Ids_ = exp(ln_Ids_a_); %uA
Rds_ = Vin ./ Ids_;    %Mohm
Rskin_max_ = 3.3 ./ Rds_;
Rskin_min_ = 0.5 ./ Rds_;

ADC_resolution = 16;
Vout_sensitivity = 3.3 / 2^ADC_resolution;
n_Vout_ROI = (3.3 - 0.5) / Vout_sensitivity;
Rskin_sensitivity_ = (Rskin_max_ - Rskin_min_) / n_Vout_ROI;
EDA_sensitivity_ = 1./Rskin_sensitivity_;

% figure(1);
% subplot(2,1,1);
% plot(Rds_, Rskin_sensitivity_);
% subplot(2,1,2);
% plot(Rds_, EDA_sensitivity_);
% 
% figure(2);
% subplot(2,2,[1,2])
% n = length(Rds_);
% for i = 1:n
%     plot([Rskin_max_(i), Rskin_min_(i)], [0.5, 3.3]);
%     hold on;
% end
% subplot(2,2,3);
% for i = 1:20
%     plot([Rskin_max_(i), Rskin_min_(i)], [0.5, 3.3]);
%     hold on;
% end
% subplot(2,2,4);
% for i = n-20:n
%     plot([Rskin_max_(i), Rskin_min_(i)], [0.5, 3.3]);
%     hold on;
% end


fontsize_val = 18;
figure(1);
subplot(2, 2, 1);
plot(Vgs,Ids, 'LineWidth', 2, 'LineStyle', '-');
hold on;
plot(Vgs,Ids_, 'LineWidth', 3, 'LineStyle', ':');
hold off;
title('Ids Comparison', 'FontSize', fontsize_val);xlabel('Vgs(V)', 'FontSize', fontsize_val);ylabel('Ids(uA)', 'FontSize', fontsize_val);
legend('Ids', 'Ids\_', 'FontSize', fontsize_val, 'Location', 'northwest');

subplot(2, 2, 2);
plot(Vgs,Rds, 'LineWidth', 2, 'LineStyle', '-');
hold on;
plot(Vgs,Rds_, 'LineWidth', 3, 'LineStyle', ':');
hold off;
title('Rds Comparison', 'FontSize', fontsize_val);xlabel('Vgs', 'FontSize', fontsize_val);ylabel('Rds', 'FontSize', fontsize_val);
legend('Rds', 'Rds\_', 'FontSize', fontsize_val, 'Location', 'best');

subplot(2, 2, 3);
plot(Vgs,log10(Ids), 'LineWidth', 2, 'LineStyle', '-');
hold on;
plot(Vgs,log10(Ids_), 'LineWidth', 3, 'LineStyle', ':');
hold off;
title('Ids Comparison', 'FontSize', fontsize_val);xlabel('Vgs(V)', 'FontSize', fontsize_val);ylabel('Ids(uA)', 'FontSize', fontsize_val);
legend('Ids', 'Ids\_', 'FontSize', fontsize_val, 'Location', 'northwest');

subplot(2, 2, 4);
plot(alphas(1:i),NMSEs, 'LineWidth', 2, 'LineStyle', '-');
hold on
scatter(alphas(min_index), min_NMSE, "*","LineWidth",2);
hold off
string_title = strcat('NMSE(minNMSE = ', string(min_NMSE), ', alpha = ', string(alphas(min_index)), ')');
title(string_title, 'FontSize', fontsize_val);xlabel('alpha', 'FontSize', fontsize_val);ylabel('NMSE', 'FontSize', fontsize_val);
legend('NMSE', 'FontSize', fontsize_val, 'Location', 'best');

Vout_ = Rfeed ./1000000 .* Ids_ + Vin;
MAX_Reda_ = (3.3 - Vin) ./ Ids_;
MIN_Reda_ = (0.5001 - Vin) ./ Ids_;

MAX_EDA_ = 1 ./ MIN_Reda_;
MAX_EDA_ = flip(MAX_EDA_);
MIN_EDA_ = 1 ./ MAX_Reda_;
MIN_EDA_ = flip(MIN_EDA_);
ADC_resolution_12 = 3.3 / 2^12;
num_BIT_12 = (3.3 - 0.5) / ADC_resolution_12;
EDA_resolution_12 = (MAX_EDA_-MIN_EDA_) ./ num_BIT_12;
ADC_resolution_16 = 3.3 / 2^16;
num_BIT_16 = (3.3 - 0.5) / ADC_resolution_16;
EDA_resolution_16 = (MAX_EDA_-MIN_EDA_) ./ num_BIT_16;

figure(2)
subplot(3,1,1)
plot(Vgs, MAX_Reda_)
subplot(3,1,2)
plot(Vgs, MIN_EDA_)
subplot(3,1,3)
plot(Vgs, EDA_resolution_12);
hold on
plot(Vgs, EDA_resolution_16);
hold on
yline(0.01)
hold off
ylim([0,0.02]);