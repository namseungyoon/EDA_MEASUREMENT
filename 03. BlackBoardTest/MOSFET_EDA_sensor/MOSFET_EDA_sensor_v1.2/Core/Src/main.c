/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
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
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "adc.h"
#include "dac.h"
#include "dma.h"
#include "fatfs.h"
#include "i2c.h"
#include "spi.h"
#include "tim.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "math.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define fs					128//hz


/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */
float ms = 0;
uint8_t sec = 0;
uint16_t min = 0;
uint16_t ms_idx = 0;

/* ADC variables */
uint16_t ADC_value[4] = {0,};

/* DAC variables */
uint16_t DAC_value = 0;
uint16_t middle_DAC_value = 0;
uint16_t end_DAC_value = 0;
uint16_t start_DAC_value = 0;
uint16_t min_DAC_value = 0;
uint16_t max_DAC_value = 0;

/* Power variables */
float BAT_V_ADC = 0.0;
float USB_V_ADC = 0.0;

/* EDA variables */
// MOSFET
float Vgs = 0.0;
float Vth = 0.5;
float Ids_LUT[2][4096] = {0,};
int Ids_i = 0;
float Ids[8192] = {0,};
uint16_t Ids_len = 0;

// input ouput
float EDA_LPF_ADC = 0.0;
float EDA_HPF_ADC = 0.0;

float Vin = 0.5;
float Vout[2][4096] = {0.0, };

int Rfeed_i = 0;
float Rfeed[2] = {1000000, 100000};

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_SPI5_Init();
  MX_FATFS_Init();
  MX_ADC1_Init();
  MX_DAC_Init();
  MX_I2C1_Init();
  MX_I2C2_Init();
  MX_I2C3_Init();
  MX_TIM3_Init();
  MX_USART1_UART_Init();
  /* USER CODE BEGIN 2 */
  /* EDA initialization */

  while(1)
  {
	  EDA_Ids_calibration();
  }
//  HAL_TIM_Base_Start_IT(&htim3);

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE3);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI|RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 128;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 2;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV8;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_4) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */
int _write(int32_t file, uint8_t *ptr, int32_t len)
{
	HAL_UART_Transmit(&huart1, ptr, len, 20);

	return len;
}

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
	if(htim->Instance == TIM3)
	{
		ms = (float)ms_idx/fs;

		/* measure ADC value */
		HAL_ADC_Start_DMA(&hadc1, (uint32_t*)ADC_value, 4);

		/* Power ADC */
		BAT_V_ADC = ( (float)ADC_value[2] / 4096 ) * 3.3;
		USB_V_ADC = ( (float)ADC_value[3] / 4096 ) * 3.3;

		/* EDA value ADC */
		EDA_LPF_ADC  = ( (float)ADC_value[0] / 4096 ) * 3.3;
		EDA_HPF_ADC = ( (float)ADC_value[1] / 4096 ) * 3.3;

		printf("%dm %.3fs\tEDA_LPF_ADC = %f\tEDA_HPF_ADC = %f\r\n", min, sec+ms, EDA_LPF_ADC, EDA_HPF_ADC);
		if(ms_idx >= fs)
		{
			ms_idx = 0;
			sec++;

			if(sec >= 60)
			{
				sec = 0;
				min++;
			}
		}
		ms_idx++;
	}
}

void EDA_Ids_calibration(void)
{
	// 1) Measurement Ids for 1Mohm, 100kohm Rfeed
	for (Rfeed_i = 0; Rfeed_i<2; Rfeed_i++)
	{
		HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, 0);
		HAL_DAC_Start(&hdac, DAC_CHANNEL_1);
		HAL_Delay(1000);
		if (Rfeed_i == 0)
		{
			// 1Mohm
			HAL_GPIO_WritePin(EDA_MUX_SET1_GPIO_Port, EDA_MUX_SET1_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(EDA_MUX_SET2_GPIO_Port, EDA_MUX_SET2_Pin, GPIO_PIN_SET);
		}
	    else if (Rfeed_i == 1)
	    {
		    // 100kohm
		    HAL_GPIO_WritePin(EDA_MUX_SET1_GPIO_Port, EDA_MUX_SET1_Pin, GPIO_PIN_SET);
		    HAL_GPIO_WritePin(EDA_MUX_SET2_GPIO_Port, EDA_MUX_SET2_Pin, GPIO_PIN_SET);
	    }
	    for (DAC_value = 0; DAC_value < 4096; DAC_value++)
	    {
	    	HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, DAC_value);
	    	HAL_DAC_Start(&hdac, DAC_CHANNEL_1);
	    	HAL_Delay(2);
	    	Vgs = (float)DAC_value / 4096 * 3.3;

	    	/* measure ADC value */
	    	HAL_ADC_Start_DMA(&hadc1, (uint32_t*)ADC_value, 4);

	    	/* EDA value ADC */
	    	EDA_LPF_ADC  = ( (float)ADC_value[0] / 4096 ) * 3.3;
	    	Vout[Rfeed_i][DAC_value] = EDA_LPF_ADC;
	    	if (Vout[Rfeed_i][DAC_value] <= 3.25 & Rfeed_i == 0)
	    	{
	    		middle_DAC_value = DAC_value;
	    	}
	    	else if (Vout[Rfeed_i][DAC_value] <= 3.25 & Rfeed_i == 1)
	    	{
	    		end_DAC_value = DAC_value;
	    	}

	    	/* Calculation Ids(uA) */
	    	Ids_LUT[Rfeed_i][DAC_value] = (Vout[Rfeed_i][DAC_value] - Vin) * 1000000 / Rfeed[Rfeed_i];
	    	if (Ids_LUT[Rfeed_i][DAC_value] < 0)
			{
	    		Ids_LUT[Rfeed_i][DAC_value] = Ids_LUT[Rfeed_i][DAC_value-1];
			}
//	    	printf("DAC = %d\tVout = %f\tIds_LUT = %f\tmiddle_DAC = %d\tend_DAC = %d\r\n", DAC_value, Vout[Rfeed_i][DAC_value], Ids_LUT[Rfeed_i][DAC_value], middle_DAC_value, end_DAC_value);
	    }
	}

	// 2) Extract Ids for need
	start_DAC_value = (Vth / 3.3) * 4096;
	for (Rfeed_i=0; Rfeed_i<2; Rfeed_i++)
	{
		for (DAC_value = start_DAC_value; DAC_value<middle_DAC_value; DAC_value++)
		{
		  Ids[Ids_i] = Ids_LUT[Rfeed_i][DAC_value];
//		  printf("Ids[%d] = %f\r\n", Ids_i, Ids[Ids_i]);
		  Ids_i++;
		}
		start_DAC_value = middle_DAC_value;
		middle_DAC_value = end_DAC_value;
	}

	min_DAC_value = (Vth / 3.3) * 4096;
	max_DAC_value = end_DAC_value;

//	printf("min_DAC = %d\tmax_DAC = %d\r\n", min_DAC_value, max_DAC_value);
	Ids_len = Ids_i;
	Ids_i = 0;

	// 3) Ids print for modeling

	float *ln_Ids = (int *)malloc(Ids_len * sizeof(int));

	printf("Ids for STM\r\n");
	uint16_t ln_Ids_i = 0;

	for (DAC_value = min_DAC_value; DAC_value < max_DAC_value; DAC_value++)
	{
		if(ln_Ids_i % 10 == 0)
		{
			printf("\r\n");
		}
		printf("%f, ", Ids[ln_Ids_i]);

		ln_Ids_i++;
	}

	printf("\r\nIds for MATLAB\r\n");
	ln_Ids_i = 0;

	for (DAC_value = min_DAC_value; DAC_value < max_DAC_value; DAC_value++)
	{
		printf("%f\r\n", Ids[ln_Ids_i]);
		ln_Ids_i++;
	}

	printf("ln_Ids for STM\r\n");
	ln_Ids_i = 0;

	for (DAC_value = min_DAC_value; DAC_value < max_DAC_value; DAC_value++)
	{
		ln_Ids[ln_Ids_i] = log(Ids[ln_Ids_i]);

		if(ln_Ids_i % 10 == 0)
		{
			printf("\r\n");
		}
		printf("%f, ", ln_Ids[ln_Ids_i]);

		ln_Ids_i++;
	}

	printf("\r\nln_Ids for MATLAB\r\n");
	ln_Ids_i = 0;
	for (DAC_value = min_DAC_value; DAC_value < max_DAC_value; DAC_value++)
	{
		ln_Ids[ln_Ids_i] = log(Ids[ln_Ids_i]);

		printf("%f\r\n", ln_Ids[ln_Ids_i]);
		ln_Ids_i++;
	}


	int n = max_DAC_value - min_DAC_value;
	float a, b, c, d;

	// https://www.gnu.org/software/gsl/
	// GSL-2.7
	least_squares(n, ln_Ids, a, b, c, d);
    printf("cubic polynomial : y = %.2fx^3 + %.2fx^2 + %.2fx + %.2f\n", a, b, c, d);


	return 0;
}

void least_squares(int n, float y[], float *a, float *b, float *c, float *d) {
    double sum_x = 0.0, sum_x_squared = 0.0, sum_x_cubed = 0.0, sum_x_quartic = 0.0;
    double sum_y = 0.0, sum_xy = 0.0, sum_x_squared_y = 0.0, sum_x_cubed_y = 0.0;

    // 각 변수의 합 계산
    for (int i = 0; i < n; i++) {
    	float xi = i;
    	float yi = y[i];
    	float xi_squared = xi * xi;
    	float xi_cubed = xi_squared * xi;

        sum_x += xi;
        sum_y += yi;
        sum_x_squared += xi_squared;
        sum_x_cubed += xi_cubed;
        sum_x_quartic += xi_squared * xi_squared;
        sum_xy += xi * yi;
        sum_x_squared_y += xi_squared * yi;
        sum_x_cubed_y += xi_cubed * yi;
    }

    // 3차 다항식의 계수 계산
    float denominator = n * sum_x_squared * sum_x_quartic -
                         sum_x_cubed * sum_x_squared * sum_x -
                         sum_x_quartic * sum_x * sum_x +
                         sum_x_cubed * sum_x_cubed;

    *a = (sum_y * sum_x_squared * sum_x_quartic -
          sum_x_cubed_y * sum_x_squared * sum_x -
          sum_x_quartic * sum_xy * sum_x +
          sum_x_cubed * sum_x_squared_y * n +
          sum_x_cubed * sum_x * sum_x * sum_xy -
          sum_x_cubed * sum_x_squared * sum_y) / denominator;

    *b = (-sum_x_quartic * sum_xy * sum_x +
          sum_x_cubed_y * sum_x_cubed * sum_x_squared -
          sum_x_squared_y * sum_x_squared * sum_x_quartic +
          sum_x_cubed * sum_x * sum_x_squared * sum_y +
          sum_x_squared * sum_x * sum_x_squared * sum_xy -
          sum_x_cubed * sum_x_squared * sum_x_squared_y) / denominator;

    *c = (sum_x_quartic * sum_x_squared * sum_xy -
          sum_x_squared * sum_x_cubed_y * sum_x_squared +
          sum_x_squared_y * sum_x_cubed * sum_x_squared -
          sum_x_quartic * sum_x_squared * sum_x_squared_y +
          sum_x_cubed * sum_x_squared * sum_x_squared * sum_x -
          sum_x_cubed * sum_x_squared * sum_x_squared_y * n) / denominator;

    *d = (-sum_x_squared * sum_x_squared * sum_xy * sum_x +
          sum_x_squared_y * sum_x_cubed * sum_x_squared * sum_x -
          sum_x_cubed_y * sum_x_squared * sum_x_squared * sum_x +
          sum_x_squared * sum_x_cubed * sum_x_squared * sum_x_squared -
          sum_x_squared * sum_x_squared * sum_x_squared * sum_x_squared_y +
          sum_x_cubed * sum_x_squared * sum_x_squared * sum_x_squared_y * n) / denominator;
}


/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
