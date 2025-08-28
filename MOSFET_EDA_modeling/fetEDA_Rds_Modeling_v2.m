clear all
close all

Ids = load("Ids.mat").Ids;
DAC_value = load("DAC_value.mat").DAC_value;
Vgs = load("Vgs.mat").Vgs;
Vin = load("Vin.mat").Vin;
Rds = Vin ./ Ids;

% temp = 10;%for log
% shift_Ids = Ids + temp;

% ln_shift_Ids = log(shift_Ids);
n_Rds = length(Rds);

% 
v = Vgs;
X = [v.*v.*v.*v.*v.*v, v.*v.*v.*v.*v, v.*v.*v.*v, v.*v.*v, v.*v, v, ones(n_Rds, 1)];
coef = (X'*X)^-1*X'*Rds;

Rds_ = X * coef;
% figure()
% plot(Vgs,Rds);
% hold on;
% plot(Vgs,Rds_);

Ids_ = Vin ./ Rds_;

Vth = 0.8;
roi_Vin = 0.5;
roi = Vgs>Vth & Ids_ < 10;
roi_Vgs = Vgs(roi);
roi_DAC_value = DAC_value(roi);
roi_Ids_ = Ids_(roi);
roi_Rds_ = roi_Vin ./ roi_Ids_;

start_DAC_value = roi_DAC_value(1);
end_DAC_value = roi_DAC_value(end);

% for plot
figure();
subplot(2, 2, 1);
plot(Vgs,Ids, 'LineWidth', 2, 'LineStyle', '-');
hold on;
plot(Vgs,Ids_, 'LineWidth', 1.5, 'LineStyle', '--');
hold off;
title('Ids Comparison');
xlabel('Vgs(V)');
ylabel('Ids(uA)');
legend('Ids', 'Ids\_');

subplot(2, 2, 2);
plot(Vgs,Rds, 'LineWidth', 2, 'LineStyle', '-');
hold on;
plot(Vgs,Rds_, 'LineWidth', 1.5, 'LineStyle', '--');
hold off;
% ylim([min(Rds_), max(Rds_)])
title('Rds Comparison');
xlabel('Vgs');
ylabel('Rds');
legend('Rds', 'Rds\_');

subplot(2, 2, 3);
plot(roi_Vgs,roi_Ids_, 'LineWidth', 3, 'LineStyle', ':');
title('roi\_Ids\_');
xlabel('Vgs');
ylabel('roi\_Ids\_');
legend('roi\_Ids\_');

subplot(2, 2, 4);
plot(roi_Vgs,roi_Rds_, 'LineWidth', 3, 'LineStyle', ':');
title('roi\_Rds\_ vs Vgs');
xlabel('Vgs');
ylabel('roi\_Rds\_');
legend('roi\_Rds\_');

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