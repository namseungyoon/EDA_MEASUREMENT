clear all
close all

% Moving average function
windowSize = 5; % You can change the window size
movingAvg = @(data, windowSize) filter(ones(1, windowSize) / windowSize, 1, data);

Ids = load("Ids.mat").Ids;
Ids=[Ids(1:597);0.85/1.18835*Ids(598:end);];

% Ids = movingAvg(Ids, 10);
DAC_value = load("DAC_value.mat").DAC_value;
Vgs = load("Vgs.mat").Vgs;
% Vin = load("Vin.mat").Vin;
Vin = 0.5;
Rds = Vin ./ Ids;

alpha=0.001;
temp = Ids(1)+alpha;
shift_Ids = Ids + temp;

ln_shift_Ids = log(shift_Ids);
n_Ids = length(shift_Ids);

% 
v = Vgs;
X = [v.*v.*v.*v.*v.*v, v.*v.*v.*v.*v, v.*v.*v.*v, v.*v.*v, v.*v, v, ones(n_Ids, 1)];
coef = (X'*X)^-1*X'*ln_shift_Ids;

ln_shift_Ids_ = X * coef;
% figure()
% plot(Vgs,ln_shift_Ids);
% hold on;
% plot(Vgs,ln_shift_Ids_);

shift_Ids_ = exp(ln_shift_Ids_);
Ids_ = shift_Ids_ - temp;
Rds_ = Vin ./ Ids_;

% error=log10(abs(Ids-Ids_)./Ids);
% error = movingAvg(error, 200);
% temp_idx=1:length(Ids)-1;
% error_th=-1;
% error_idx=temp_idx(diff(sign(error-error_th))==-2);
% 
% 
% % 
% v = Vgs(1:error_idx);
% y=ln_shift_Ids(1:error_idx);
% 
% X = [v.*v.*v.*v.*v.*v, v.*v.*v.*v.*v, v.*v.*v.*v, v.*v.*v, v.*v, v, ones(length(v), 1)];
% coef = (X'*X)^-1*X'*y;
% est_y= X * coef;
% 
% ln_shift_Ids_(1:error_idx)=est_y;
% 
% % 
% v = Vgs(error_idx+1:end);
% y=ln_shift_Ids(error_idx+1:end);
% 
% X = [v.*v.*v.*v.*v.*v, v.*v.*v.*v.*v, v.*v.*v.*v, v.*v.*v, v.*v, v, ones(length(v), 1)];
% coef = (X'*X)^-1*X'*y;
% est_y= X * coef;
% 
% ln_shift_Ids_(error_idx+1:end)=est_y;
% 
% 
% shift_Ids_ = exp(ln_shift_Ids_);
% Ids_ = shift_Ids_ - temp;
% Rds_ = Vin ./ Ids_;

%%
Vth = 1;
roi_Vin = 0.5;
roi = Vgs>Vth & Ids_ < 10;
roi_Vgs = Vgs(roi);
roi_DAC_value = DAC_value(roi);
roi_Ids = Ids(roi);
roi_Ids_ = Ids_(roi);
roi_Rds = Rds(roi);
roi_Rds_ = roi_Vin ./ roi_Ids_;

start_DAC_value = roi_DAC_value(1);
end_DAC_value = roi_DAC_value(end);

% for plot
figure();
subplot(2, 2, 1);
plot(Vgs,Ids, 'LineWidth', 2, 'LineStyle', '-');
hold on;
plot(Vgs,Ids_, 'LineWidth', 3, 'LineStyle', ':');
hold off;
title('Ids Comparison');
xlabel('Vgs(V)');
ylabel('Ids(uA)');
legend('Ids', 'Ids\_');

subplot(2, 2, 2);
plot(Vgs,Rds, 'LineWidth', 2, 'LineStyle', '-');
hold on;
plot(Vgs,Rds_, 'LineWidth', 3, 'LineStyle', ':');
hold off;
ylim([0, 100])
% ylim([min(Rds_), max(Rds_)])
title('Rds Comparison');
xlabel('Vgs');
ylabel('Rds');
legend('Rds', 'Rds\_');

subplot(2, 2, 3);
plot(roi_Vgs,roi_Ids, 'LineWidth', 2, 'LineStyle', '-');
hold on;
plot(roi_Vgs,roi_Ids_, 'LineWidth', 3, 'LineStyle', ':');
title('roi\_Ids Comparison');
xlabel('Vgs');
ylabel('roi\_Ids\_');
legend('roi\_Ids', 'roi\_Ids\_');

subplot(2, 2, 4);
plot(roi_Vgs,roi_Rds, 'LineWidth', 2, 'LineStyle', '-');
hold on;
plot(roi_Vgs,roi_Rds_, 'LineWidth', 3, 'LineStyle', ':');
title('roi\_Rds Comparison');
xlabel('Vgs');
ylabel('roi\_Rds\_');
legend('roi\_Rds', 'roi\_Rds\_');
ylim([0, 100])

hold off
error=log10(abs(Ids-Ids_)./Ids);
plot(error)

% ylim([min(roi_Rds), max(roi_Rds)])
% figure()
% plot(Vgs(roi),Ids(roi), 'LineWidth', 2, 'LineStyle', '-');
% hold on;
% plot(Vgs(roi),Ids_(roi), 'LineWidth', 3, 'LineStyle', '--');
% hold off;
% title('Ids Comparison');
% xlabel('Vgs(V)');
% ylabel('Ids(uA)');
% legend('Ids', 'Ids\_');
% 
% figure()
% plot(Vgs(roi),Rds(roi), 'LineWidth', 2, 'LineStyle', '-');
% hold on;
% plot(Vgs(roi),Rds_(roi), 'LineWidth', 3, 'LineStyle', '--');
% hold off;
% % ylim([min(Rds_), max(Rds_)])
% title('Rds Comparison');
% xlabel('Vgs');
% ylabel('Rds');
% legend('Rds', 'Rds\_');