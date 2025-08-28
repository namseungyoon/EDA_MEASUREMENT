clear all
close all


% 데이터 생성
% [x, y] = meshgrid(linspace(-5, 5, 10), linspace(-5, 5, 10));
% z = peaks(x, y);
load("fitting_3d_sample.mat");
x = fitting_3d_sample.x;
y = fitting_3d_sample.y;
z = fitting_3d_sample.z;

% 라플라스 스무딩
lambda = 0.5; % 스무딩 강도 (0에 가까울수록 강하게 스무딩)
z_smooth = z - lambda * del2(z);

% 결과 표시
figure;
surf(x, y, z);
hold on;
mesh(x, y, z_smooth);
title('Laplacian Smoothing');
legend('Original Data', 'Smoothed Surface');