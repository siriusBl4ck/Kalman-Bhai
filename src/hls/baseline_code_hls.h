#ifndef KALMAN_HEADER
#define KALMAN_HEADER

#include<stdio.h>
#include<stdlib.h>

#define STATE_DIM 6
#define INPUT_DIM 6
#define MEASUREMENT_DIM 2
typedef float DTYPE;


void matmultvec(DTYPE *res, int res_dim,
				DTYPE *mat, int mat_noRows, int mat_noColumns, 
				DTYPE *vec, int vec_dim);
				
void addvecs(DTYPE *res, int res_dim,
			 DTYPE *a, int a_dim,
			 DTYPE *b, int b_dim);

void subvecs(DTYPE *res, int res_dim,
			 DTYPE *a, int a_dim,
			 DTYPE *b, int b_dim);

void amultbtrans(DTYPE *res, int res_noRows, int res_noColumns,
				 DTYPE *a, int a_noRows, int a_noColumns, 
				 DTYPE *b, int b_noRows, int b_noColumns);

void amultb(DTYPE *res, int res_noRows, int res_noColumns,
			DTYPE *a, int a_noRows, int a_noColumns, 
			DTYPE *b, int b_noRows, int b_noColumns);

void addmats(DTYPE *res, int res_noRows, int res_noColumns,
			DTYPE *a, int a_noRows, int a_noColumns, 
			DTYPE *b, int b_noRows, int b_noColumns);

void submats(DTYPE *res, int res_noRows, int res_noColumns,
			DTYPE *a, int a_noRows, int a_noColumns, 
			DTYPE *b, int b_noRows, int b_noColumns);

void inversemat(DTYPE *res, int res_dimensions,
				DTYPE *a, int a_dimensions);

void statePredictor(DTYPE *xk, DTYPE *uk, DTYPE *F,	DTYPE *B);

void covariancePredictor(DTYPE *Pk, DTYPE *F, DTYPE *Q);

void measurementResidual(DTYPE *zk, DTYPE *H, DTYPE *xk, DTYPE *yk);

void stateUpdate(DTYPE *xk, DTYPE *Kk, DTYPE *yk);

void kalmangainCalculator(DTYPE *Pk, DTYPE *H, 	DTYPE *R, DTYPE *Kk);

void covarianceUpdate(DTYPE *Kk, DTYPE *H, DTYPE *Pk);

void kalmanIterate(DTYPE *xk, DTYPE *uk, DTYPE *F, DTYPE *B, DTYPE *Pk, DTYPE *Q, DTYPE *yk, DTYPE *zk, DTYPE *H, DTYPE *Kk, DTYPE *R);

#endif
