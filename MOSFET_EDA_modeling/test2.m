% 데이터 준비
x = linspace(0.5, 3.3, 30); % x값을 0.5에서 3.3 사이의 값으로 30개 생성
y = 2*x.^3 - 3*x.^2 + 4*x - 5; % y값을 3차 방정식 형태로 설정

% z값은 y값을 x축으로 1만큼 시프트한 값
z = 2*(x+1).^3 - 3*(x+1).^2 + 4*(x+1) - 5;

% 피팅을 위한 데이터 매트릭스 준비
[X, Y] = meshgrid(x, y);
Z = 2*X.^3 - 3*X.^2 + 4*X - 5; % 원래 데이터로부터 z 값을 계산

% 다항식 피팅을 위한 데이터 변환
x_data = X(:);
y_data = Y(:);
z_data = Z(:);

% 2차 다항식 피팅
% 여기서 다차원 다항식 피팅을 위해 fit 함수를 사용
sf = fit([x_data, y_data], z_data, 'poly22');

% 피팅된 모델
x_fit = linspace(min(x), max(x), 100);
y_fit = linspace(min(y), max(y), 100);
[X_fit, Y_fit] = meshgrid(x_fit, y_fit);
Z_fit = feval(sf, X_fit, Y_fit);

% 데이터와 피팅된 면 플로팅
figure;
scatter3(x_data, y_data, z_data, 'b', 'filled');
hold on;
surf(X_fit, Y_fit, Z_fit, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
legend('Data points', 'Fitted surface');
xlabel('x');
ylabel('y');
zlabel('z');
title('Surface Fitting using Least Squares');
grid on;

% 피팅된 모델 출력
disp('Fitted model coefficients:');
disp(coeffvalues(sf));