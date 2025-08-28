/*
 * MOSFET_EDA.c
 *
 *  Created on: Apr 1, 2024
 *      Author: namseungyoon
 */
#include "dac.h"
#include "adc.h"
#include "i2c.h"

#include "MOSFET_EDA.h"
#include "Math_func.h"
#include "HDC1080.h"
#include "math.h"


// ADC variables
uint16_t ADC_value[4] = {0,};
float EDA_LPF_ADC = 0.0;
float EDA_HPF_ADC = 0.0;

// feedback register varibles
float Rfeed[2] = {1000000, 100000};
int Rfeed_i = 0;

// mosfet variables
uint16_t DAC_value = 0;
uint16_t middle_DAC_value = 0;
uint16_t end_DAC_value = 0;
uint16_t start_DAC_value = 0;

float Vgs = 0.0;
float Vth = 0.5;
float Vin = 0.5;
float Vout[2][4096] = {0.0, };

//int Ids_i;
float Ids_LUT[2][4096] = {0,};

// Temperature, Humidity variables
volatile float temp;
volatile float humi;
float Temps[2][4096] = {0.0, };
float Humis[2][4096] = {0.0, };
float avg_Temp = 0.0;
float avg_Humi = 0.0;

void MOSFET_EDA_Measure_Ids(float Ids[], uint16_t* min_DAC_value, uint16_t* max_DAC_value)
{
	HDC1080_initialize(&hi2c2,Temperature_Resolution_14_bit,Humidity_Resolution_14_bit);

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
	    	HAL_Delay(1);
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

//			printf("[%d][%d] Ids_LUT = %f\tTemp = %f\tHumi = %f\r\n", Rfeed_i, DAC_value, Ids_LUT[Rfeed_i][DAC_value], Temps[Rfeed_i][DAC_value], Humis[Rfeed_i][DAC_value]);

//	    	printf("DAC = %d\tRfeed = %.0fohm\tVout = %f\tIds_LUT = %f\r\n", DAC_value, Rfeed[Rfeed_i], Vout[Rfeed_i][DAC_value], Ids_LUT[Rfeed_i][DAC_value]);


	    }
	}

	// 2) Extract Ids for need area
//	Ids_i = 0;
	start_DAC_value = (Vth / 3.3) * 4096;
	/* measure HDC1080 value */
	HDC1080_Measurement(&hi2c2, (float*)&temp, (float*)&humi);
//	printf("DAC_value\tIds(T%.2f)\r\n", temp);
	for (Rfeed_i=0; Rfeed_i<2; Rfeed_i++)
	{
		for (DAC_value = start_DAC_value; DAC_value<middle_DAC_value; DAC_value++)
		{
			Ids[DAC_value] = Ids_LUT[Rfeed_i][DAC_value];
//			printf("%d\t%f\r\n", DAC_value, Ids[DAC_value]);
//			printf("%d. Ids = %fuA\tTemp = %fC\tHumi = %f%%\r\n", DAC_value, Ids[DAC_value], Temps[Rfeed_i][DAC_value], Humis[Rfeed_i][DAC_value]);
//			Ids  _i++;
		}
		start_DAC_value = middle_DAC_value;
		middle_DAC_value = end_DAC_value;
	}

	float min_DAC_value_float = (Vth / 3.3) * 4096;
	*min_DAC_value = (uint16_t)min_DAC_value_float;
	*max_DAC_value = end_DAC_value;

//	for(int i = 0; i < 4096; i++)
//	{
//		printf("%f, ", Ids[i]);
//		if( (i % 10) == 9)
//		{
//			printf("\r\n");
//		}
//	}

//	printf("start DAC value = %d\tend DAC value = %d\r\n", *min_DAC_value, *max_DAC_value);
}

void MOSFET_EDA_Calibration_Ids(float Ids[], uint16_t min_DAC_value, uint16_t max_DAC_value, float Ids_[], float parameter[], float* tmp)
{
	uint16_t size = max_DAC_value - min_DAC_value;

	float* ln_Ids_temp = (float*)malloc(size * sizeof(float));


	for(int Ids_i = min_DAC_value; Ids_i < max_DAC_value; Ids_i++)
	{
		ln_Ids_temp[Ids_i-min_DAC_value] = log(Ids[Ids_i]);
//		printf("* Ids_temp[%d] = %f\tIds[%d] = %f\r\n", (Ids_i-min_DAC_value), Ids_temp[Ids_i-min_DAC_value], Ids_i, Ids[Ids_i]);
	}
	/* Least square method */
	Least_square_method(ln_Ids_temp, size, 5, ln_Ids_temp, parameter);


	/* measure HDC1080 value */
	HDC1080_Measurement(&hi2c2, (float*)&temp, (float*)&humi);

//	printf("Vgs\tIds\tIds_(T%.2f)\r\n", temp);
//	printf(" Ids_(T%.2f)\r\n", temp);
	*tmp = temp;

	for(int Ids_i = min_DAC_value; Ids_i < max_DAC_value; Ids_i++)
	{
		Ids_[Ids_i] = exp(ln_Ids_temp[Ids_i - min_DAC_value]);
		float Vgs = (float)Ids_i/4096 * 3.3;
//		printf("%f\t%f\t%f\r\n", Vgs, Ids[Ids_i], Ids_[Ids_i]);
//		printf("%f\r\n", Ids_[Ids_i]);

//		printf("** Ids[%d] = %f\tIds_[%d] = %f\r\n", Ids_i, Ids[Ids_i], Ids_i, Ids_[Ids_i]);
	}
//	Least_square_method(float signal[], int n_signal, int degree, float signal_[])
	free(ln_Ids_temp);
}

void MOSFET_EDA_Start(uint16_t start_DAC_value)
{
	HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, start_DAC_value);
	HAL_DAC_Start(&hdac, DAC_CHANNEL_1);

	// set EDA electrode
	HAL_GPIO_WritePin(EDA_MUX_SET1_GPIO_Port, EDA_MUX_SET1_Pin, GPIO_PIN_SET);
	HAL_GPIO_WritePin(EDA_MUX_SET2_GPIO_Port, EDA_MUX_SET2_Pin, GPIO_PIN_RESET);

	HAL_Delay(100);
}

void MOSFET_EDA_Get(float* EDA_LPF_Vout, float* EDA_HPF_Vout)
{
	/* measure ADC value */
	HAL_ADC_Start_DMA(&hadc1, (uint32_t*)ADC_value, 4);

	/* EDA value ADC */
	*EDA_LPF_Vout  = ( (float)ADC_value[0] / 4096 ) * 3.3;
	*EDA_HPF_Vout  = ( (float)ADC_value[1] / 4096 ) * 3.3;
}

