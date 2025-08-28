clear all
close all

fetEDA_time_idx = double(0);
fetEDA_movingAvg_EDA = double(0);
fetEDA_syncFlag = int8(0);
fetEDA_Vgs = double(0);

file_name = 'syncPIN_nomaEDA_2024-08-21T09_10_05.acq.mat';

nomadixEDA_EDA = load(file_name).EDA_signal';
nomadixEDA_syncFlag = load(file_name).syncFlag';

fetEDA = fetEDA_movingAvg_EDA(fetEDA_syncFlag==1);
nomadixEDA = nomadixEDA_EDA(nomadixEDA_syncFlag>3);
nomadixEDA = nomadixEDA(1:9000,:);
time_idx = fetEDA_time_idx(fetEDA_syncFlag==1)-60;

fetEDA_nomadixEDA.time = time_idx;
fetEDA_nomadixEDA.fetEDA = fetEDA;
fetEDA_nomadixEDA.nomadixEDA = nomadixEDA;

save_file_name = strcat('fetEDA_nomadixEDA_', file_name(17:end-8), '.mat');
save(save_file_name, 'fetEDA_nomadixEDA', '-mat');

figure()

% 첫 번째 서브플롯
subplot(4,1,1)
plot(time_idx, nomadixEDA, 'r-', 'LineWidth', 1.5) % 빨간색 실선
title('Nomadix EDA') % 제목 추가
xlabel('Time (s)') % x축 레이블 추가
ylabel('EDA Response') % y축 레이블 추가
grid on % 그리드 추가

% 두 번째 서브플롯
subplot(4,1,2)
plot(time_idx, fetEDA, 'b--', 'LineWidth', 1.5) % 파란색 점선
title('FET EDA') % 제목 추가
xlabel('Time (s)') % x축 레이블 추가
ylabel('EDA Response') % y축 레이블 추가
grid on % 그리드 추가

% 세 번째 서브플롯
subplot(4,1,3)
plot(time_idx, fetEDA, 'b--', 'LineWidth', 1.5) % 파란색 점선
hold on
plot(time_idx, nomadixEDA, 'r-', 'LineWidth', 1.5) % 빨간색 실선
hold off

title('Comparison of FET and Nomadix EDA') % 제목 추가
xlabel('Time (s)') % x축 레이블 추가
ylabel('EDA Response') % y축 레이블 추가
legend('FET EDA', 'Nomadix EDA') % 범례 추가
grid on % 그리드 추가

norm_fetEDA = normalize(fetEDA,"range");
norm_nomadixEDA = normalize(nomadixEDA,"range");
subplot(4,1,4)
plot(time_idx, norm_fetEDA, 'b--', 'LineWidth', 1.5) % 파란색 점선
hold on
plot(time_idx, norm_nomadixEDA, 'r-', 'LineWidth', 1.5) % 빨간색 실선
hold off
title('Comparison of norm FET and norm Nomadix EDA') % 제목 추가
xlabel('Time (s)') % x축 레이블 추가
ylabel('norm EDA Response') % y축 레이블 추가
legend('norm FET EDA', 'norm Nomadix EDA') % 범례 추가
grid on % 그리드 추가

R = corrcoef(norm_fetEDA, norm_nomadixEDA);
[crossCorr, lags] = xcorr(norm_fetEDA, norm_nomadixEDA);
C = cov(norm_fetEDA, norm_nomadixEDA);