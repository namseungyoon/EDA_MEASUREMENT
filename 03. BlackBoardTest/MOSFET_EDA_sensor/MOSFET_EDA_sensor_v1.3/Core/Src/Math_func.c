/*
 * Math_func.c
 *
 *  Created on: Apr 1, 2024
 *      Author: namseungyoon
 */

#include "Math_func.h"
#include <stdlib.h>

void Least_square_method(float signal[], int n_signal, int degree, float signal_[], float parameter[])
{
	float **A = allocate_2d_array(n_signal, (degree+1));
	float **AT = allocate_2d_array((degree+1), n_signal);
	float **ATA = allocate_2d_array((degree+1), (degree+1));
	float **ATAI = allocate_2d_array((degree+1), (degree+1));
	float **ATAIAT = allocate_2d_array((degree+1), n_signal);

	float **B = allocate_2d_array(n_signal, 1);
	float **X = allocate_2d_array((degree+1), 1);

	float **B_ = allocate_2d_array(n_signal, 1);

	float x = 0;

	for(int i = 0; i < n_signal; i++)
	{
		x = (float)i;

		A[i][5] = x * x * x * x * x;
		A[i][4] = x * x * x * x;
		A[i][3] = x * x * x;
		A[i][2] = x * x;
		A[i][1] = x;
		A[i][0] = 1;

		B[i][0] = signal[i];

//		printf("A => %f\t%f\t%f\t%f\t%f\t%f\t\tB = %f\r\n", A[i][5], A[i][4], A[i][3], A[i][2], A[i][1], A[i][0], B[i][0]);
	}

	/* Least Square fitting
	* AX = B
	* X = A^(-1)B
	*   = ( A^(T)A )^(-1)A^(T)B
	*/

	transpose_matrix(n_signal, (degree+1), A, AT);
//	print_matrix((degree+1), n_signal, AT);

	multiply_matrices((degree+1), n_signal, AT, n_signal, (degree+1), A, ATA);
//	print_matrix((degree+1), (degree+1), ATA);

	inverse_matrix((degree+1), ATA, ATAI);
//	print_matrix((degree+1), (degree+1), ATAI);

	multiply_matrices((degree+1), (degree+1), ATAI, (degree+1), n_signal, AT, ATAIAT);
//	print_matrix((degree+1), n_signal, ATAIAT);

	multiply_matrices((degree+1), n_signal, ATAIAT, n_signal, 1, B, X);
//	print_matrix((degree+1), 1, X);

	multiply_matrices(n_signal, (degree+1), A, (degree+1), 1, X, B_);
//	print_matrix(n_signal, 1, B_);

	for(int i = 0; i < n_signal; i++)
	{
		signal_[i] = B_[i][0];
	}
	for(int i = 0; i < degree+1; i++)
	{
		parameter[i] = X[i][0];
	}
	free_allocate_2d_array(A, n_signal);
	free_allocate_2d_array(AT, (degree+1));
	free_allocate_2d_array(ATA, (degree+1));
	free_allocate_2d_array(ATAI, (degree+1));
	free_allocate_2d_array(ATAIAT, (degree+1));
	free_allocate_2d_array(B, n_signal);
	free_allocate_2d_array(X, (degree+1));
	free_allocate_2d_array(B_, n_signal);

}

void transpose_matrix(int rows, int cols, float **mat_a, float **mat_a_t)
{
    int i, j;

    for (i = 0; i < rows; i++)
    {
        for (j = 0; j < cols; j++)
        {
        	mat_a_t[j][i] = mat_a[i][j]; // Swap rows and columns to assign
        }
    }
}

// Function to calculate the product of two matrices
void multiply_matrices(int rows1, int cols1, float **mat_a, int rows2, int cols2, float **mat_b, float **mat_ab)
{
    int i, j, k;

    if (cols1 != rows2)
    {
        printf("Error: Number of columns in the first matrix must be equal to the number of rows in the second matrix.\n");
        return;
    }

    for (i = 0; i < rows1; i++)
    {
        for (j = 0; j < cols2; j++)
        {
        	mat_ab[i][j] = 0; // Initialize the result matrix
            for (k = 0; k < cols1; k++)
            {
            	mat_ab[i][j] += mat_a[i][k] * mat_b[k][j]; // Matrix multiplication
            }
        }
    }
}

// Function to calculate the inverse of a matrix
void inverse_matrix(int N, float **mat_a, float **mat_a_inv)
{
	float temp[N][2*N]; // Matrix combining the original matrix and the identity matrix
	float factor;

    // Initialize the temp matrix
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < 2*N; j++)
        {
            if (j < N)
            {
                temp[i][j] = mat_a[i][j];
            }
            else
            {
                if (j - N == i)
                {
                    temp[i][j] = 1; // Initialize the identity matrix part
                }
                else
                {
                    temp[i][j] = 0;
                }
            }
        }
    }

    // Gaussian elimination
    for (int i = 0; i < N; i++)
    {
        // If the diagonal element is 0, swap rows
        if (temp[i][i] == 0)
        {
            for (int j = i + 1; j < N; j++)
            {
                if (temp[j][i] != 0)
                {
                    // Swap rows
                    for (int k = 0; k < 2*N; k++)
                    {
                    	float temp_swap = temp[i][k];
                        temp[i][k] = temp[j][k];
                        temp[j][k] = temp_swap;
                    }
                    break;
                }
            }
        }
        // Make the diagonal element 1
        factor = temp[i][i];
        for (int j = 0; j < 2*N; j++)
        {
            temp[i][j] /= factor;
        }
        // Make other elements in the same column 0
        for (int j = 0; j < N; j++)
        {
            if (i != j)
            {
                factor = temp[j][i];
                for (int k = 0; k < 2*N; k++)
                {
                    temp[j][k] -= factor * temp[i][k];
                }
            }
        }
    }

    // Extract the inverse matrix
    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
        	mat_a_inv[i][j] = temp[i][j+N];
        }
    }
}

// Function to print a matrix
void print_matrix(int rows, int cols, float **mat)
{
    int i, j;
    for (i = 0; i < rows; i++)
    {
        for (j = 0; j < cols; j++)
        {
            printf("%f\t", mat[i][j]);
        }
        printf("\r\n");
    }
}

float **allocate_2d_array(int rows, int cols)
{
    // Dynamic memory allocation for the 2D array
    float **matrix = (float **)malloc(rows * sizeof(float *));
    if (matrix == NULL)
    {
        printf("Memory allocation error\r\n");
        exit(1);
    }

    for (int i = 0; i < rows; i++)
    {
        matrix[i] = (float *)malloc(cols * sizeof(float));
        if (matrix[i] == NULL)
        {
            printf("Memory allocation error\r\n");
            exit(1);
        }
    }

    // Initialization and assignment of values to the array
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            matrix[i][j] = 0;
        }
    }

    return matrix;
}


void free_allocate_2d_array(float** array, int rows) {
    // Free each row
    for (int i = 0; i < rows; i++) {
        free(array[i]);
    }

    // Free the array of row pointers
    free(array);
}
