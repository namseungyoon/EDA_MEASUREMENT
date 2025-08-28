clear all
close all


% 데이터 생성
% [x, y] = meshgrid(linspace(-5, 5, 10), linspace(-5, 5, 10));
% z = peaks(x, y);
load("fitting_3d_sample.mat");
x = fitting_3d_sample.x;
y = fitting_3d_sample.y;
z = fitting_3d_sample.z;

% B-스플라인 근사
sp = spap2({4,4}, [5 5], {x(1,:), y(:,1)'}, z);
z_fit = fnval(sp, {x(1,:), y(:,1)'});

% 결과 표시
figure;
surf(x, y, z);
hold on;
mesh(x, y, z_fit);
title('B-Spline Surface Approximation');
legend('Original Data', 'Fitted Surface');