clear all
close all

load("fitting_3d_sample_3.mat");
T = fitting_3d_sample.x;
Vgs = fitting_3d_sample.y;
Ids = fitting_3d_sample.z;

NMSEs = [];
alphas = [];
init_alpha = abs(min(min(Ids)));
idx = 1:1:300;
for i = idx
    alpha = (i*0.001)+init_alpha;
    alphas(i,1) = alpha;
    Ids_a = Ids + alpha;
    
    ln_Ids_a = log(Ids_a);
    
    x = T;
    y = Vgs;

    A = [x(:).^5, y(:).^5, x(:).^4, y(:).^4, x(:).^3, y(:).^3, x(:).^2, y(:).^2, x(:).*y(:), x(:), y(:), ones(numel(x),1)];
    coef = pinv(A) * ln_Ids_a(:);
    coefs(:,i) = coef;

    ln_Ids_a_ = reshape(A*coef, size(Ids));
    Ids_ = exp(ln_Ids_a_)-alpha;

    %%
    % for plot
    % figure();
    % NMSE 
    x=log10(Ids(:));
    y=log10(Ids_(:));
    NMSE=((x-y)'*(x-y))/(x'*x)
    NMSEs(i, 1) = NMSE;
    [min_NMSE, min_index] = min(NMSEs);

end


Ids = Ids + alphas(min_index);
Rds = 0.5 ./ Ids;
x = T;
y = Vgs;
A = [x(:).^5, y(:).^5, x(:).^4, y(:).^4, x(:).^3, y(:).^3, x(:).^2, y(:).^2, x(:).*y(:), x(:), y(:), ones(numel(x),1)];

coef = coefs(:,min_index);
ln_Ids_a_ = reshape(A*coef, size(Ids));

Ids_ = exp(ln_Ids_a_);
Ids_point = coef(1)*x^5 + coef(2)*y^5 + coef(3)*x^4 + coef(4)*y^4 + coef(5)*x^3 + coef(6)*y^3 + coef(7)*x^2 + coef(8)*y^2 + coef(9)*x*y + coef(10)*x + coef(11)*y + coef(12)*1;
Rds_ = 0.5 ./ Ids_;

% 결과 표시
figure(1);
surf(x, y, Ids);
hold on;
mesh(x, y, Ids_);
title('Proposed method');
legend('Original Data', 'Fitted Surface');
xlabel('Temperature (°C)');
ylabel('Vgs (V)');
zlabel('Ids (uA)');

figure(2);
surf(x, y, Rds);
hold on;
mesh(x, y, Rds_);
title('Least Squares Approximation');
legend('Original Data', 'Fitted Surface');
xlabel('Temperature (°C)');
ylabel('Vgs (V)');
zlabel('Rds (Mohm)');
zlim([0, 10])
ylim([1,1.4])

[EDA_Resolution, rangeEDA, maxEDA, minEDA] = getEDA_Resolution(Ids_, 16);
th1 = ones(31, 31) * 0.01;  % 1로 채워진 31x31 행렬
figure(3);
surf(x, y, EDA_Resolution);
hold on;
mesh(x, y, th1);
hold off
title('EDA Resolution');
legend('EDA Resolution', '0.01uS/bit');
xlabel('Temperature (°C)');
ylabel('Vgs (V)');
zlabel('EDA Resolution (uS/bit)');

max(maxEDA(EDA_Resolution<=0.01))
min(minEDA(EDA_Resolution<=0.01))

th2 = ones(31, 31) * 100;  % 1로 채워진 31x31 행렬
% figure;
% surf(x, y, rangeEDA);
figure(4);
surf(x, y, maxEDA);
hold on
mesh(x, y, th2)
% zlim([0,1200])
hold off
title('max EDA values');
legend('max EDA values', '100uS');
xlabel('Temperature (°C)');
ylabel('Vgs (V)');
zlabel('max EDA (uS)');
% figure;
% surf(x, y, minEDA);
