/*
 * HDC1080.h
 *
 *  Created on: Sep 25, 2023
 *      Author: SYNAM-OFFICE
 */

#ifndef INC_HDC1080_H_
#define INC_HDC1080_H_

#include "i2c.h"

#define HDC_1080_Address                    0x40

#define HDC1080_Configuration				0x02
#define HDC1080_Temperature					0x00
#define HDC1080_Humidity					0x01
#define HDC1080_DeviceID			       	0xFF

typedef enum
{
  Temperature_Resolution_14_bit = 0,
  Temperature_Resolution_11_bit = 1
}Temp_Reso;

typedef enum
{
  Humidity_Resolution_14_bit = 0,
  Humidity_Resolution_11_bit = 1,
  Humidity_Resolution_8_bit =2
}Humi_Reso;

void HDC1080_initialize(I2C_HandleTypeDef* hi2c_x,Temp_Reso Temperature_Resolution_x_bit,Humi_Reso Humidity_Resolution_x_bit);
uint8_t HDC1080_Measurement(I2C_HandleTypeDef* hi2c_x,float* temperature, float* humidity);
uint8_t HDC1080_testConnection(void);
uint16_t HDC1080_getDeviceID(void);
uint16_t HDC1080_ReadBytes(uint8_t reg_Address);


//#define HDC1080_ADDRESS             (0x40<<1)
//
//#define HDC_Configuration       	0x02
//#define HDC_Temperature				0x00
//#define HDC_Humidity				0x01
//
//#define HDC_ManufacturerID       	0xFE
//
//void HDC1080_initialize(void);
//float HDC1080_ReadTEMPnHUMI(void);
//
//uint32_t HDC1080_ReadBytes(uint8_t reg_Address);
//void HDC1080_WriteByte(uint8_t reg_Address, uint16_t data);

#endif /* INC_HDC1080_H_ */
