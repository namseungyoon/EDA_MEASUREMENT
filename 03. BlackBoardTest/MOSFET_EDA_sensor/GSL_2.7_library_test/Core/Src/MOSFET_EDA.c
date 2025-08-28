/*
 * MOSFET_EDA.c
 *
 *  Created on: Apr 1, 2024
 *      Author: namseungyoon
 */

#include "MOSFET_EDA.h"

float* calibration_Ids(float Ids[], int n_Ids)
{
	for(int i_Ids = 0; i_Ids < n_Ids; i_Ids++)
	  {
		  x = (float)i_Ids;
		  A[i_Ids][5] = x * x * x * x * x;
		  A[i_Ids][4] = x * x * x * x;
		  A[i_Ids][3] = x * x * x;
		  A[i_Ids][2] = x * x;
		  A[i_Ids][1] = x;
		  A[i_Ids][0] = 1;

		  B[i_Ids][0] = ln_Ids[i_Ids];

	  }
	  float A_T[6][1394] = {0, };
	  float A_T_A[6][6] = {0, };
	  float A_T_A_I[6][6] = {0, };
	  float A_T_A_I_A_T[6][1394] = {0, };

	  float X[6][1] = {0, };

	  /* Least Square fitting
	   * AX = B
	   * X = A^(-1)B
	   *   = ( A^(T)A )^(-1)A^(T)B
	   */
	  transpose_matrix(1394, 6, A, A_T);

	  multiply_matrices(6, 1394, A_T, 1394, 6, A, A_T_A);

	  inverse_matrix(6, A_T_A, A_T_A_I);

	  multiply_matrices(6, 6, A_T_A_I, 6, 1394, A_T, A_T_A_I_A_T);

	  multiply_matrices(6, 1394, A_T_A_I_A_T, 1394, 1, B, X);

	  multiply_matrices(1394, 6, A, 6, 1, X, B_);
	  print_matrix(1394, 1, B_);

	  for(int i_Ids=0; i_Ids<n_Ids; i_Ids++)
	  {
		  ln_Ids_[i_Ids] = B_[i_Ids][0];
		  Ids_[i_Ids] = exp(ln_Ids_[i_Ids]);
	  }

}

