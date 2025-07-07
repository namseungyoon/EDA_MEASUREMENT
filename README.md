# EDA_MEASUREMENT

"""
# 실험 목적
MOSFET의 Vds-Ids 특성을 측정하고, 5차 다항식으로 피팅한다.

## 실험 과정
1. MOSFET 기반(?) EDA 측정회로를 준비
2. Ids 측정 방법
 2.1. EDA 전극과 병렬로 1Mohm, 100kohm 저항을 연결
  2.1.1. 1Mohm으로 연결 -> Vds : Vth(Vds = 0.5v) ~ Vout_max(Vout = 3.3v) 에 해당하는 Vds를 순차적으로 인가하여 Ids 측정
  2.1.2. 100kohm으로 연결 -> Vds : Vth(Vds = 0.5v) ~ Vout_max(Vout = 3.3v) 에 해당하는 Vds를 순차적으로 인가하여 Ids 측정
 2.2. 
## 실험 과정
1. 
2. Ids 값 생성 (노이즈 포함, 12비트 양자화)
3. 5차 다항식 피팅
4. 결과 시각화
"""
import numpy as np

