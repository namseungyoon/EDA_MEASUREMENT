clear all
close all

init_Ids = load("Ids.mat").Ids;
init_Rds = 0.5 ./ init_Ids;
init_DAC_value = load("DAC_value.mat").DAC_value;
init_Vgs = load("Vgs.mat").Vgs;

init_shift_Ids = init_Ids + Ids_level_shift;

ln_init_Ids = log(init_shift_Ids);
n_init = length(init_shift_Ids);

% 
v = init_Vgs;
X = [v.*v.*v.*v.*v.*v, v.*v.*v.*v.*v, v.*v.*v.*v, v.*v.*v, v.*v, v, ones(n_init, 1)];
coef = (X'*X)^-1*X'*ln_init_Ids;

ln_init_Ids_ = X * coef;
init_shift_Ids_ = exp(ln_init_Ids_);
init_Ids_ = init_shift_Ids_ - Ids_level_shift;
init_Rds_ = 0.5 ./ init_Ids_;

Vth = 0.7;
new_Vgs = init_Vgs(init_Vgs>Vth & init_Ids_ < 10);
new_DAC_value = init_DAC_value(init_Vgs>Vth & init_Ids_ < 10);
new_Ids_ = init_Ids_(init_Vgs>Vth & init_Ids_ < 10);
new_Rds_ = 0.5 ./ new_Ids_;

start_DAC_value = new_DAC_value(1);
end_DAC_value = new_DAC_value(end);

% for plot
figure();
subplot(2, 2, 1);
plot(init_Vgs,init_Ids);
hold on;
plot(init_Vgs,init_Ids_);
hold on;
plot(new_Vgs,new_Ids_);
hold off;

subplot(2, 2, 2);
plot(init_Vgs,init_Rds);
hold on;
plot(init_Vgs,init_Rds_);
hold on;
plot(new_Vgs,new_Rds_);
hold off;

subplot(2, 2, 3);
plot(init_Vgs,init_Ids_);
hold on;
plot(new_Vgs,new_Ids_);
subplot(2, 2, 4);
plot(init_Vgs,init_Rds_);
hold on;
plot(new_Vgs,new_Rds_);


