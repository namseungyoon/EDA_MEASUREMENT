clear all
close all

load("fitting_3d_sample.mat");
x = fitting_3d_sample.x;
y = fitting_3d_sample.y;
z = fitting_3d_sample.z;

% 다항식 근사 (2차 다항식)
X = [ones(numel(x), 1), x(:), y(:), x(:).*y(:), x(:).^2, y(:).^2];
b = X \ z(:); % 다항식 계수 계산
z_fit = reshape(X * b, size(z));

% 결과 표시
figure;
surf(x, y, z);
hold on;
mesh(x, y, z_fit);
title('Polynomial Approximation');
legend('Original Data', 'Fitted Surface');