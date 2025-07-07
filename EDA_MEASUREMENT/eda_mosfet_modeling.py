import numpy as np
import matplotlib.pyplot as plt
plt.rcParams['font.family'] = 'Malgun Gothic'
plt.rcParams['axes.unicode_minus'] = False

# 1. Vds 값 생성 (0.5 ~ 255.5, 8비트 해상도, 1000개)
vds_min = 0.5
vds_max = 1.5
num_points = 1000
Vds = np.linspace(vds_min, vds_max, num_points)

# 2. Ids 값 생성 (노이즈가 섞인 exponential, 12비트 해상도)
A = 0.5  # 임의 상수
B = 0.02  # 임의 상수
np.random.seed(42)  # 재현성
Ids_clean = A * np.exp(B * Vds)
noise = np.random.normal(0, 0.05 * np.max(Ids_clean), num_points)
Ids_noisy = Ids_clean + noise

# 12비트 해상도 (0~4095)로 양자화
Ids_noisy = np.clip(Ids_noisy, 0, None)  # 음수 방지
Ids_quantized = np.round(Ids_noisy / np.max(Ids_noisy) * 4095)

# 3. 5차 다항식 least square fitting
poly_degree = 5
coefs = np.polyfit(Vds, Ids_quantized, poly_degree)

# 결과 출력 (계수)
print('5차 다항식 계수:', coefs)

# 4. 그래프 출력
fit_poly = np.poly1d(coefs)
Ids_fitted = fit_poly(Vds)

plt.figure(figsize=(10,6))
plt.scatter(Vds, Ids_quantized, s=10, color='blue', label='Measured (Quantized)')
plt.plot(Vds, Ids_fitted, color='red', linewidth=2, label='5th Order Fit')
plt.xlabel('Vds')
plt.ylabel('Ids (Quantized)')
plt.title('Vds-Ids MOSFET 측정 및 5차 다항식 피팅')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show() 