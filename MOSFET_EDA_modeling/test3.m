clear all
close all

Vgs = [0.5:(1/2^12):3.3]';
n = length(Vgs);
t = linspace(0, 1, n); % 시간 축 생성

% 가우시안 파형 생성
mu = 0.5; % 중심 위치
sigma = 0.1; % 폭 조절
gaussian_waveform = exp(-((t - mu).^2) / (2 * sigma^2));
gaussian_waveform = gaussian_waveform';

% 음의 왜도를 가지는 파형 생성
% 감마 분포 기반 비대칭 파형
shape_param = 2; % 형상 파라미터
scale_param = 0.1; % 스케일 파라미터
neg_skew_waveform = (t.^(shape_param - 1)) .* exp(-t/scale_param);

neg_skew_waveform = neg_skew_waveform / max(abs(neg_skew_waveform));
neg_skew_waveform = neg_skew_waveform';
% 결과 시각화
figure;
subplot(3,1,1);
plot(t, gaussian_waveform);
title('Gaussian Waveform');
xlabel('Time');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, neg_skew_waveform);
title('Negative Skewness Waveform');
xlabel('Time');
ylabel('Amplitude');

subplot(3,1,3);
scatter(t, (gaussian_waveform+neg_skew_waveform));

