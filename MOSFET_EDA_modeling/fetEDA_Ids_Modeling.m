clear all
close all

load("Ids_1.mat");

n = length(Ids_1);
Rds = 0.5 ./ Ids_1;
ln_Ids = log(Ids_1+1);
start_DAC_value = 0.7 / 3.3 * 4096;
i = (start_DAC_value:start_DAC_value+n-1)';
v = i / 4096 * 3.3;
X = [v.*v.*v.*v.*v.*v, v.*v.*v.*v.*v, v.*v.*v.*v, v.*v.*v, v.*v, v, ones(n, 1)];
coef = (X'*X)^-1*X'*ln_Ids;

Vth = 0.8;
start_DAC_value_2 = Vth / 3.3 * 4096;
n_2 = int16(start_DAC_value+n-1 - start_DAC_value_2);
i_2 = (start_DAC_value_2:start_DAC_value+n-1)';
v_2 = i_2 / 4096 * 3.3;
X_2 = [v_2.*v_2.*v_2.*v_2.*v_2.*v_2, v_2.*v_2.*v_2.*v_2.*v_2, v_2.*v_2.*v_2.*v_2, v_2.*v_2.*v_2, v_2.*v_2, v_2, ones(n_2, 1)];

ln_Ids_ = X_2 * coef;
Ids_ = exp(ln_Ids_)-1;
Rds_ = 0.5 ./ Ids_;

figure(1);
subplot(2,2,1);
plot(v_2, Ids_,'DisplayName','Ids_');
subplot(2,2,2);
plot(v, Ids,'DisplayName','Ids');
subplot(2,2,3:4);
plot(v, Ids,'DisplayName','Ids_');hold on;plot(v_2, Ids_2,'DisplayName','Ids_1');hold off;


figure(2);
subplot(2,2,1);
plot(v_2, Rds,'DisplayName','Ids_');
subplot(2,2,2);
plot(v_2, Rds_,'DisplayName','Ids');
subplot(2,2,3:4);
plot(v_2, Rds_,'DisplayName','Ids_');hold on;plot(v_2, Rds,'DisplayName','Ids');hold off;

