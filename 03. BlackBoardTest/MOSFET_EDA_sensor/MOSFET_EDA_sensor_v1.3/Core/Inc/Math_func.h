/*
 * Math_func.h
 *
 *  Created on: Apr 1, 2024
 *      Author: namseungyoon
 */

#ifndef INC_MATH_FUNC_H_
#define INC_MATH_FUNC_H_

void Least_square_method(float signal[], int n_signal, int degree, float signal_[], float parameter[]);
void transpose_matrix(int rows, int cols, float **mat_a, float **mat_a_t);
void multiply_matrices(int rows1, int cols1, float **mat_a, int rows2, int cols2, float **mat_b, float **mat_ab);
void inverse_matrix(int N, float **mat_a, float **mat_a_inv);
void print_matrix(int rows, int cols, float **mat);
float **allocate_2d_array(int rows, int cols);
void free_allocate_2d_array(float** array, int rows);


#endif /* INC_MATH_FUNC_H_ */
