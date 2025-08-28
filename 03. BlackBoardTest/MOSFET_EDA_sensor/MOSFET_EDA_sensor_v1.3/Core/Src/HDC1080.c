/*
 * HDC1080.c
 *
 *  Created on: Sep 25, 2023
 *      Author: SYNAM-OFFICE
 */

#include <HDC1080.h>
#include <stdio.h>

void HDC1080_initialize(I2C_HandleTypeDef* hi2c_x,Temp_Reso Temperature_Resolution_x_bit,Humi_Reso Humidity_Resolution_x_bit)
{
	/* Temperature and Humidity are acquired in sequence, Temperature first
	 * Default:   Temperature resolution = 14 bit,
	 *            Humidity resolution = 14 bit
	 */

	/* Set the acquisition mode to measure both temperature and humidity by setting Bit[12] to 1 */
	uint16_t config_reg_value=0x1000;
	uint8_t data_send[2];

	if(Temperature_Resolution_x_bit == Temperature_Resolution_11_bit)
	{
		config_reg_value |= (1<<10); //11 bit
	}

	switch(Humidity_Resolution_x_bit)
	{
	case Humidity_Resolution_11_bit:
		config_reg_value|= (1<<8);
		break;
	case Humidity_Resolution_8_bit:
		config_reg_value|= (1<<9);
		break;
	}

	data_send[0]= (config_reg_value>>8);
	data_send[1]= (config_reg_value&0x00ff);

	HAL_I2C_Mem_Write(hi2c_x,HDC_1080_Address<<1,HDC1080_Configuration,I2C_MEMADD_SIZE_8BIT,data_send,2,1000);
//	printf(HDC1080_testConnection() ? "Temp,Humi sensor(HDC1080) connection successful\r\n" : "Temp,Humi sensor(HDC1080) connection failed\r\n");

}


uint8_t HDC1080_Measurement(I2C_HandleTypeDef* hi2c_x,float* temperature, float* humidity)
{
	uint8_t receive_data[4];
	uint16_t temp_x,humi_x;
	uint8_t send_data = HDC1080_Temperature;

	HAL_I2C_Master_Transmit(hi2c_x,HDC_1080_Address<<1,&send_data,1,1000);

	/* Delay here 15ms for conversion compelete.
	 * Note: datasheet say maximum is 7ms, but when delay=7ms, the read value is not correct
	 */
	HAL_Delay(15);

	/* Read temperature and humidity */
	HAL_I2C_Master_Receive(hi2c_x,HDC_1080_Address<<1,receive_data,4,1000);

	temp_x =((receive_data[0]<<8)|receive_data[1]);
	humi_x =((receive_data[2]<<8)|receive_data[3]);

	*temperature = ((temp_x/65536.0)*165.0)-40.0;
	*humidity = ((humi_x/65536.0)*100.0);

	return 0;

}

uint8_t HDC1080_testConnection(void)
{
	return HDC1080_getDeviceID() == 0x1050;
}

uint16_t HDC1080_getDeviceID(void)
{
	uint16_t data = 0;
	data = HDC1080_ReadBytes(HDC1080_DeviceID);
	return data;
}

uint16_t HDC1080_ReadBytes(uint8_t reg_Address)
{
	uint8_t data[2] = {0, };
	uint16_t value = 0;

	HAL_I2C_Mem_Read(&hi2c2, HDC_1080_Address<<1, reg_Address, 1, (uint8_t*)&data, 2, 10);
	value = (data[0]<<8 | data[1]);

//	printf("HDC1080_ReadBytes => reg_Address : 0x%X, value : 0x%X, data[0] : 0x%X, data[1] : 0x%X\r\n", reg_Address, value, data[0], data[1]);
    return value;
}

