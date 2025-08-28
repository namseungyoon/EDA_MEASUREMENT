clear all
close all

fetEDA = load("fetEDA.mat").fetEDA;
fetVgs = load("fetVgs.mat").fetVgs;
fetDAC = load("fetDAC.mat").fetDAC;

nomaEDA = load("nomaEDA.mat").nomaEDA;
nomaEDA_sync = load("nomaEDA_sync.mat").nomaEDA_sync;

fs = 50;

start_idx = 1 * 60 * fs;
end_idx = 6 * 60 * fs - 1;
fetEDA = fetEDA(start_idx:end_idx);
nomaEDA = nomaEDA(nomaEDA_sync>3);
cutoff = 0.5;

% 이동 평균 필터 계수 계산
filter_length = 2*fs/cutoff + 1;  % 필터 길이 계산 (오드 길이로 만듦)
b = ones(1, filter_length) / filter_length;  % 이동 평균 필터 계수 계산
% [b, a] = butter(cutoff, 1/(fs/2), 'low');
% lpf_fetEDA = filtfilt(b, a, fetEDA);

lpf_fetEDA = filter(b, 1, fetEDA);
% lpf_fetEDA = lpf_fetEDA(6001:end);
lpf_nomaEDA = filter(b, 1, nomaEDA);
% lpf_nomaEDA = lpf_nomaEDA(6001:end);

norm_fetEDA = (lpf_fetEDA(4000:end) - min(lpf_fetEDA(4000:end))) / (max(lpf_fetEDA(4000:end)) - min(lpf_fetEDA(4000:end)));
norm_nomaEDA = (lpf_nomaEDA(4000:end) - min(lpf_nomaEDA(4000:end))) / (max(lpf_nomaEDA(4000:end)) - min(lpf_nomaEDA(4000:end)));
% 첫 번째 서브플롯
subplot(2,1,1);
plot(lpf_nomaEDA(4000:end), 'DisplayName', 'NomadixEDA', 'LineWidth', 2); % 선 굵기 2로 설정
hold on;
plot(lpf_fetEDA(4000:end), 'DisplayName', 'muxEDA', 'LineWidth', 2);   % 선 굵기 2로 설정
hold off;
legend('FontSize', 12);  % 범례 글자 크기 12로 설정
title('EDA Comparison', 'FontSize', 14); % 제목 글자 크기 14로 설정
xlabel('Sample', 'FontSize', 12);  % x축 라벨 글자 크기 12로 설정
ylabel('EDA(uS)', 'FontSize', 12);  % y축 라벨 글자 크기 12로 설정

% 두 번째 서브플롯
subplot(2,1,2);
plot(norm_nomaEDA, 'DisplayName', 'Norm-NomadixEDA', 'LineWidth', 2);  % 선 굵기 2로 설정
hold on;
plot(norm_fetEDA, 'DisplayName', 'Norm-muxEDA', 'LineWidth', 2);    % 선 굵기 2로 설정
hold off;
legend('FontSize', 12);  % 범례 글자 크기 12로 설정
title('Normalized EDA Comparison', 'FontSize', 14); % 제목 글자 크기 14로 설정
xlabel('Sample', 'FontSize', 12);  % x축 라벨 글자 크기 12로 설정
ylabel('Normalized EDA(uS)', 'FontSize', 12);  % y축 라벨 글자 크기 12로 설정

% 전체 그래프의 글자 크기를 설정
set(gca, 'FontSize', 12);
