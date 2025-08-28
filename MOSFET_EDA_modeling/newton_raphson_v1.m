clear all
close all

load("coef.mat");
coef(7,1) = coef(7,1)+5;
% 5차 함수의 계수 정의 (예: f(x) = 2x^5 - 3x^4 + x^3 - x^2 + 4x - 5)
coefficients = coef;

% 함수 정의
f = @(x) polyval(coefficients, x);

% 도함수 정의
df = @(x) polyval(polyder(coefficients), x);

% 초기 추정값, 허용 오차, 최대 반복 횟수 설정
x0 = 1.5; % 초기 추정값
tol = 1e-6; % 허용 오차
max_iter = 1000; % 최대 반복 횟수

% 근 구하기
try
    root = newton_raphson(f, df, x0, tol, max_iter);
    fprintf('뉴턴-랩슨 방법으로 구한 근: %.6f\n', root);
catch ME
    disp(ME.message);
end

% 뉴턴-랩슨 방법 함수 정의
function root = newton_raphson(f, df, x0, tol, max_iter)
    x = x0;
    for iter = 1:max_iter
        x_new = x - f(x) / df(x);
        if abs(x_new - x) < tol
            root = x_new;
            return;
        end
        x = x_new;
    end
    error('최대 반복 횟수에 도달했습니다. 근을 찾지 못했습니다.');
end