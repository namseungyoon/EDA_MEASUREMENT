clear all
close all

% 데이터 생성 (예제 데이터)
load("fitting_3d_sample.mat");
x = fitting_3d_sample.x;
y = fitting_3d_sample.y;
z = fitting_3d_sample.z;
a = abs(min(min(z)))+0.1;
z = log(z+a);

% 선형 회귀 모델 피팅 (예제 코드의 의미를 살리기 위해 추가)
X = [ones(numel(x), 1), x(:), y(:), x(:).^2, x(:).*y(:), y(:).^2];
% coeff = X \ z(:); % 최소 제곱법으로 계수 계산
p_X = pinv(X);
z_ = z(:);
coeff = p_X * z_; % 최소 제곱법으로 계수 계산
con = 0;
for i = 1:length(z_)
    con = con + p_X(1,i) * z_(i);
    fprintf('%d. p_X(1,%d) = %f, z_(%d) = %f, con = %f\r\n', i, i, p_X(1,i), i, z_(i), con);
    if con == Inf
        i
    end
end

% 근사된 z 값 계산
z_fit = reshape(X * coeff, size(z));

% 결과 시각화
figure;
surf(x, y, z);
hold on;
mesh(x, y, z_fit);
title('Least Squares Approximation');
legend('Original Data', 'Fitted Surface');

% 축 라벨 추가
xlabel('Temperature (°C)');
ylabel('Vgs (V)');
zlabel('log(Ids)');