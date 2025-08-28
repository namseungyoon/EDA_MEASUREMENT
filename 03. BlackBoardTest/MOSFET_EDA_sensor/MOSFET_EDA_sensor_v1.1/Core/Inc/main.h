/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2024 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32f7xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define I2C1_SCL_AFE_IMU_Pin GPIO_PIN_8
#define I2C1_SCL_AFE_IMU_GPIO_Port GPIOB
#define SD_CHK_Pin GPIO_PIN_4
#define SD_CHK_GPIO_Port GPIOB
#define I2C1_SDL_AFE_IMU_Pin GPIO_PIN_9
#define I2C1_SDL_AFE_IMU_GPIO_Port GPIOB
#define EDA_MUX_SET1_Pin GPIO_PIN_10
#define EDA_MUX_SET1_GPIO_Port GPIOI
#define EDA_MUX_SET2_Pin GPIO_PIN_11
#define EDA_MUX_SET2_GPIO_Port GPIOI
#define USB_CHK_Pin GPIO_PIN_13
#define USB_CHK_GPIO_Port GPIOI
#define AFE_ADC_RDY_Pin GPIO_PIN_14
#define AFE_ADC_RDY_GPIO_Port GPIOI
#define SPI5_CS_Pin GPIO_PIN_6
#define SPI5_CS_GPIO_Port GPIOF
#define RGB_Blue_LED_Pin GPIO_PIN_6
#define RGB_Blue_LED_GPIO_Port GPIOJ
#define RGB_Red_LED_Pin GPIO_PIN_4
#define RGB_Red_LED_GPIO_Port GPIOJ
#define RGB_Green_LED_Pin GPIO_PIN_5
#define RGB_Green_LED_GPIO_Port GPIOJ
#define EDA_LPF_Pin GPIO_PIN_1
#define EDA_LPF_GPIO_Port GPIOA
#define EDA_DAC_Pin GPIO_PIN_4
#define EDA_DAC_GPIO_Port GPIOA
#define I2C3_SCL_SKT_Pin GPIO_PIN_7
#define I2C3_SCL_SKT_GPIO_Port GPIOH
#define EDA_HPF_Pin GPIO_PIN_5
#define EDA_HPF_GPIO_Port GPIOA
#define BAT_CHK3_Pin GPIO_PIN_2
#define BAT_CHK3_GPIO_Port GPIOJ
#define I2C2_SCL_ENV_Pin GPIO_PIN_10
#define I2C2_SCL_ENV_GPIO_Port GPIOB
#define I2C3_SDA_SKT_Pin GPIO_PIN_8
#define I2C3_SDA_SKT_GPIO_Port GPIOH
#define USB_V_Pin GPIO_PIN_1
#define USB_V_GPIO_Port GPIOB
#define BAT_V_Pin GPIO_PIN_0
#define BAT_V_GPIO_Port GPIOB
#define BAT_CHK1_Pin GPIO_PIN_0
#define BAT_CHK1_GPIO_Port GPIOJ
#define BAT_CHK2_Pin GPIO_PIN_1
#define BAT_CHK2_GPIO_Port GPIOJ
#define I2C2_SDA_ENV_Pin GPIO_PIN_11
#define I2C2_SDA_ENV_GPIO_Port GPIOB

/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
