clear all
close all

load('EDA_DATA.mat')

raw_EDA = EDA_DATA(:,1);
lpf_EDA = EDA_DATA(:,2);
ma_EDA = EDA_DATA(:,3);

plot(raw_EDA)
hold on
plot(lpf_EDA(100:end,1))
hold on
plot(ma_EDA)
hold off
legend()
