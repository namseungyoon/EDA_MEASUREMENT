clear all
close all

x = (1:100)' ./ 10;
a = 0.1;
b = 0.2;
c = 0.3;

for i = 1:10
    exp1 = exp(a * x.^2 + b * x + c);
    c = c + 0.1;
    plot(x, exp1);
    hold on;
end
