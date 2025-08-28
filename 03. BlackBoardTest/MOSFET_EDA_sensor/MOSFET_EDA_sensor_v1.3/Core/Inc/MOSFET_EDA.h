/*
 * MOSFET_EDA.h
 *
 *  Created on: Apr 1, 2024
 *      Author: namseungyoon
 */

#ifndef INC_MOSFET_EDA_H_
#define INC_MOSFET_EDA_H_


void MOSFET_EDA_Measure_Ids(float Ids[], uint16_t* min_DAC_value, uint16_t* max_DAC_value);
void MOSFET_EDA_Calibration_Ids(float Ids[], uint16_t min_DAC_value, uint16_t max_DAC_value, float Ids_[], float parameter[], float* tmp);
void MOSFET_EDA_Start(uint16_t start_DAC_value);
void MOSFET_EDA_Get(float* EDA_LPF_Vout, float* EDA_HPF_Vout);

#endif /* INC_MOSFET_EDA_H_ */
