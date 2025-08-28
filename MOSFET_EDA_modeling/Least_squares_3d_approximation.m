clear all
close all

% 데이터 생성
% [x, y] = meshgrid(-5:0.5:5, -5:0.5:5);
% z = 2*x.^2 + 3*y.^2 + rand(size(x));
load("fitting_3d_sample.mat");
x = fitting_3d_sample.x;
y = fitting_3d_sample.y;
z = fitting_3d_sample.z;

a = min(min(z));
z_a = z + abs(a)+0.1;
log_z_a = log(z_a);

% 최소 제곱 근사
A = [x(:).^5, y(:).^5, x(:).^4, y(:).^4, x(:).^3, y(:).^3, x(:).^2, y(:).^2, x(:).*y(:), x(:), y(:), ones(numel(x),1)];
% A = [x(:).^4, y(:).^4, x(:).^3, y(:).^3, x(:).^2, y(:).^2, x(:).*y(:), x(:), y(:), ones(numel(x),1)];
% A = [x(:).^3, y(:).^3, x(:).^2, y(:).^2, x(:).*y(:), x(:), y(:), ones(numel(x),1)];
% A = [x(:).*y(:), x(:), y(:), ones(numel(x),1)];
p_A = pinv(A);
coeff = pinv(A) * log_z_a(:);

log_z_fit = reshape(A*coeff, size(z));
z_fit = exp(log_z_fit)-abs(a)-0.1;


o = z(:);
f = z_fit(:);
NMSE=((o-f)'*(o-f))/(o'*o)
% 결과 표시
figure;
surf(x, y, z);
hold on;
mesh(x, y, z_fit);
title('Least Squares Approximation');
legend('Original Data', 'Fitted Surface');
xlabel('Temperature (°C)');
ylabel('Vgs (V)');
zlabel('Ids (A)');