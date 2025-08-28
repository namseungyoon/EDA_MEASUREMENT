clear all
close all

load("test2.mat")
Vgs = test2(:,1);
Ids = test2(:,2);
Ids_ = test2(:,3);

figure
plot(Vgs, Ids, 'LineWidth', 4, 'Color', 'r');
hold on
plot(Vgs, Ids_, 'LineWidth', 4, 'Color', 'g', 'LineStyle','--');
legend('Ids(uA)', 'LSM Ids(uA)');
