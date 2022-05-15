#include<stdio.h>
#include<stdlib.h>
#include<omp.h>


#define STATE_DIM 6
#define INPUT_DIM 6
#define MEASUREMENT_DIM 2
typedef float DTYPE;


void __attribute__ ((noinline)) printmat(DTYPE *mat, int noRows, int noColumns) {
	printf("==============\n");
	for(int i=0; i<noRows; i++) 
	{
		for (int j=0; j<noColumns; j++)
		{ 
			printf("%f ", mat[i*noColumns + j]);
		}
		printf("\n");
	}
	printf("==============\n");
}


void __attribute__ ((noinline)) printMatrices(DTYPE **mat, int noRows, int noColumns) {
	printf("==============\n");
	for(int i=0; i<noRows; i++) 
	{
		for (int j=0; j<noColumns; j++)
		{ 
			printf("%f  ", mat[i][j]);
		}
		printf("\n");
	}
	printf("==============\n");
}


void __attribute__ ((noinline)) matmultvec(DTYPE *res, int res_dim, 
				DTYPE *mat, int mat_noRows, int mat_noColumns, 
				DTYPE *vec, int vec_dim) 
{
	if (vec_dim != mat_noColumns)
	{
		printf("void matmultvec(): Error - Dimensions Mismatch");
		exit(0);
	}
	
	if (res_dim != mat_noRows)
	{
		printf("void matmultvec(): Error - Dimensions Mismatch");
		exit(0);
	}

	//#pragma omp parallel for collapse(1) - failed
	for (int i=0; i<mat_noRows; i++) 
	{
		res[i] = 0;
		for (int j=0; j<mat_noColumns; j++) 
			res[i] += mat[i*mat_noColumns + j] * vec[i];
	}
}

void __attribute__ ((noinline)) addvecs(DTYPE *res, int res_dim, 
			 DTYPE *a, int a_dim,
			 DTYPE *b, int b_dim) 
{
	if (res_dim != a_dim || res_dim != b_dim)
	{
		printf("void addvecs(): Error - Dimensions Mismatch");
		exit(0);
	}	

	// #pragma omp parallel for collapse(1) - fail
	for (int i=0; i<res_dim; i++)
		res[i] = a[i] + b[i];
}


void __attribute__ ((noinline)) subvecs(DTYPE *res, int res_dim, 
			 DTYPE *a, int a_dim,
			 DTYPE *b, int b_dim) 
{
	if (res_dim != a_dim || res_dim != b_dim)
	{
		printf("void subvecs(): Error - Dimensions Mismatch");
		exit(0);
	}	

	// #pragma omp parallel for collapse(1) - fail
	for (int i=0; i<res_dim; i++)
		res[i] = a[i] - b[i];
}



void __attribute__ ((noinline)) amultbtrans(DTYPE *res, int res_noRows, int res_noColumns, 
				 DTYPE *a, int a_noRows, int a_noColumns, 
				 DTYPE *b, int b_noRows, int b_noColumns) 
{
	
	if (res_noRows != a_noRows || a_noColumns != b_noColumns || res_noColumns != b_noRows)
	{
		printf("void amultbtrans(): Error - Dimensions Mismatch");
		exit(0);
	}
	
	// #pragma omp parallel for collapse(2) - fail
	for (int i=0; i<res_noRows; i++) 
	{
		for (int j=0; j<res_noColumns; j++) 
		{
			res[i*res_noColumns + j] = 0;

			for (int k=0; k<b_noColumns; k++)
				res[i*res_noColumns + j] += a[i*a_noColumns + k] * b[j*b_noColumns + k];
		}
	}
}



void __attribute__ ((noinline)) amultb(DTYPE *res, int res_noRows, int res_noColumns, 
			DTYPE *a, int a_noRows, int a_noColumns, 
			DTYPE *b, int b_noRows, int b_noColumns) 
{
	
	if (res_noRows != a_noRows || a_noColumns != b_noRows || res_noColumns != b_noColumns)
	{
		printf("void amultb(): Error - Dimensions Mismatch");
		exit(0);
	}
	
	//#pragma omp parallel for collapse(2)
	for (int i=0; i<res_noRows; i++) 
	{
		for (int j=0; j<res_noColumns; j++) 
		{
			res[i*res_noColumns + j] = 0;
			for (int k=0; k<b_noRows; k++)
				res[i*res_noColumns + j] += a[i*a_noColumns + k] * b[k*b_noRows + j];
		}
	}

}



void __attribute__ ((noinline)) addmats(DTYPE *res, int res_noRows, int res_noColumns, 
			DTYPE *a, int a_noRows, int a_noColumns, 
			DTYPE *b, int b_noRows, int b_noColumns) 
{

	if (res_noRows != a_noRows || res_noRows != b_noRows || res_noColumns != a_noColumns || res_noColumns != b_noColumns)
	{
		printf("void addmats(): Error - Dimensions Mismatch");
		exit(0);
	}

	//#pragma omp parallel for collapse(2)
	for (int i=0; i<res_noRows; i++) {
		for (int j=0; j<res_noColumns; j++)
			res[i*res_noColumns + j] = a[i*a_noColumns + j] + b[i*b_noColumns + j];
	}
}



void __attribute__ ((noinline)) submats(DTYPE *res, int res_noRows, int res_noColumns, 
			DTYPE *a, int a_noRows, int a_noColumns, 
			DTYPE *b, int b_noRows, int b_noColumns) 
{

	if (res_noRows != a_noRows || res_noRows != b_noRows || res_noColumns != a_noColumns || res_noColumns != b_noColumns)
	{
		printf("void submats(): Error - Dimensions Mismatch");
		exit(0);
	}

	//#pragma omp parallel for collapse(2)
	for (int i=0; i<res_noRows; i++) {
		for (int j=0; j<res_noColumns; j++)
			res[i*res_noColumns + j] = a[i*a_noColumns + j] - b[i*b_noColumns + j];
	}
}


void __attribute__ ((noinline)) inversemat(DTYPE *res, int res_dimensions, 
				DTYPE *a, int a_dimensions) 
{
	if(res_dimensions != a_dimensions)
	{
		printf("void inversemat(): Error - Dimensions Mismatch");
		exit(0);
	}

	int dimensions = res_dimensions;

	DTYPE tempmat[MEASUREMENT_DIM][2*MEASUREMENT_DIM];

	//printf("%ld", sizeof(tempmat)/sizeof(DTYPE));

	for (int i = 0; i < dimensions; i++) {
        for (int j = 0; j < 2 * dimensions; j++) {
			if (j < dimensions)
				tempmat[i][j] = a[i*dimensions + j];
            if (j == (i + dimensions))
                tempmat[i][j] = 1;
        }
    }
	//printMatrices(tempmat, STATE_DIM, 2*STATE_DIM);

    for (int i = dimensions - 1; i > 0; i--) {
        if (tempmat[i - 1][0] < tempmat[i][0]) {
			for (int j=0; j<2*dimensions; j++) {
				float temp = tempmat[i][j];
				tempmat[i][j] = tempmat[i-1][j];
				tempmat[i-1][j] = temp;
			}
        }
    }

    for (int i = 0; i < dimensions; i++) {
        for (int j = 0; j < dimensions; j++) {
            if (j != i) {
				float temp;
                temp = tempmat[j][i] / tempmat[i][i];
                for (int k = 0; k < 2 * dimensions; k++)
                    tempmat[j][k] -= tempmat[j][k] * temp;
            }
        }
    }

    for (int i = 0; i < dimensions; i++) {
		float temp;
        temp = tempmat[i][i];
        for (int j = 0; j < 2 * dimensions; j++)
            tempmat[i][j] = tempmat[i][j] / temp; //see if it can be added here
    }

	//printMatrices(tempmat, STATE_DIM, 2*STATE_DIM);

	for (int i=0; i<dimensions; i++) {
		for (int j=0; j<dimensions; j++)
			res[i*dimensions + j] = tempmat[i][j+dimensions];
	}
}

#define xk_dim       STATE_DIM
#define uk_dim       INPUT_DIM
#define F_noRows     STATE_DIM
#define F_noColumns  STATE_DIM
#define B_noRows     STATE_DIM
#define B_noColumns  INPUT_DIM
#define Pk_noRows    STATE_DIM
#define Pk_noColumns STATE_DIM
#define Q_noRows     STATE_DIM
#define Q_noColumns  STATE_DIM
#define yk_dim       MEASUREMENT_DIM
#define zk_dim       MEASUREMENT_DIM
#define H_noRows     MEASUREMENT_DIM
#define H_noColumns  STATE_DIM
#define Kk_noRows    STATE_DIM
#define Kk_noColumns MEASUREMENT_DIM
#define R_noRows     MEASUREMENT_DIM
#define R_noColumns  MEASUREMENT_DIM


#define M_dim xk_dim
#define N_dim xk_dim
void __attribute__ ((noinline)) statePredictor(DTYPE *xk, DTYPE *uk, DTYPE *F,	DTYPE *B)
{
	DTYPE M[M_dim], N[N_dim];

	matmultvec(M, M_dim, 
			   F, F_noRows, F_noColumns,
			   xk, xk_dim);
	
	matmultvec(N, N_dim, 
			   B, B_noRows, B_noColumns,
			   uk, uk_dim);
	
	addvecs(xk, xk_dim,
			M, M_dim, 
			N, N_dim);		
}



#define L1_noRows    Pk_noRows
#define L1_noColumns F_noRows
#define L2_noRows    F_noRows
#define L2_noColumns L1_noColumns
void __attribute__ ((noinline)) covariancePredictor(DTYPE *Pk, DTYPE *F, DTYPE *Q)
{
	DTYPE L1[L1_noRows * L1_noColumns], L2[L2_noRows * L2_noColumns];
	
	amultbtrans(L1, L1_noRows, L1_noColumns,
				Pk, Pk_noRows, Pk_noColumns,
				F,  F_noRows,  F_noColumns);
	
	amultb(L2, L2_noRows, L2_noColumns,
		   F,  F_noRows,  F_noColumns,
		   L1, L1_noRows, L1_noColumns);
	
	addmats(Pk, Pk_noRows, Pk_noColumns,
			L2, L2_noRows, L2_noColumns,
		    Q,  Q_noRows,  Q_noColumns);		
}


#define E_dim yk_dim
void __attribute__ ((noinline)) measurementResidual(DTYPE *zk, DTYPE *H, DTYPE *xk, DTYPE *yk)
{
	DTYPE E[E_dim];

	matmultvec(E,  E_dim,
			   H,  H_noRows, H_noColumns, 
			   xk, xk_dim);

	subvecs(yk, yk_dim, 
	        zk, zk_dim,
			E,  E_dim);
}


#define A_noRows      Pk_noRows
#define A_noColumns   H_noRows
#define C1_noRows     H_noRows
#define C1_noColumns  A_noColumns
void __attribute__ ((noinline)) kalmangainCalculator(DTYPE *Pk, DTYPE *H, 	DTYPE *R, DTYPE *Kk)
{
	DTYPE A[A_noRows * A_noColumns], C1[C1_noRows * C1_noColumns];

	amultbtrans(A,  A_noRows,  A_noColumns,
	            Pk, Pk_noRows, Pk_noColumns,
				H,  H_noRows,  H_noColumns);

	amultb(C1, C1_noRows, C1_noColumns,
	       H,  H_noRows,  H_noColumns,
		   A,  A_noRows,  A_noColumns);

	addmats(C1, C1_noRows, C1_noColumns, 
	        R,  R_noRows,  R_noColumns,
			C1, C1_noRows, C1_noColumns);
	
	inversemat(C1, C1_noRows, 
	           C1, C1_noRows);

	amultb(Kk, Kk_noRows, Kk_noColumns,
	       A,  A_noRows,  A_noColumns,
	       C1, C1_noRows, C1_noColumns);		
}


#define temp_dim xk_dim
void __attribute__ ((noinline)) stateUpdate(DTYPE *xk, DTYPE *Kk, DTYPE *yk)
{
	DTYPE temp[temp_dim];
	
	matmultvec(temp, temp_dim,
			   Kk,   Kk_noRows, Kk_noColumns,
			   yk,   yk_dim);

	addvecs(xk,   xk_dim,
	 		xk,   xk_dim,
			temp, temp_dim);
}

#define temp1_noRows    Kk_noRows
#define temp1_noColumns H_noColumns
#define temp2_noRows    temp1_noRows
#define temp2_noColumns Pk_noColumns
void __attribute__ ((noinline)) covarianceUpdate(DTYPE *Kk, DTYPE *H, DTYPE *Pk)
{
	DTYPE temp1[temp1_noRows * temp1_noColumns], temp2[temp2_noRows * temp2_noColumns];

	amultb(temp1, temp1_noRows, temp1_noColumns, 
		   Kk,    Kk_noRows,    Kk_noColumns,
		   H,     H_noRows,     H_noColumns);

	amultb(temp2, temp2_noRows, temp2_noColumns, 
		   temp1, temp1_noRows, temp1_noColumns, 
		   Pk,     Pk_noRows,   Pk_noColumns);

	submats(Pk,     Pk_noRows,    Pk_noColumns,
	        Pk,     Pk_noRows,    Pk_noColumns, 
			temp2,  temp2_noRows, temp2_noColumns);
}


void __attribute__ ((noinline)) kalmanIterate(DTYPE *xk, DTYPE *uk, DTYPE *F, DTYPE *B, DTYPE *Pk, DTYPE *Q, DTYPE *yk, DTYPE *zk, DTYPE *H, DTYPE *Kk, DTYPE *R) 
{
	#pragma omp task depend (out:Kk)
	{
	covariancePredictor(Pk, F, Q);
    kalmangainCalculator(Pk, H, R, Kk);
	}

	#pragma omp task depend(out:xk)
	{
	statePredictor(xk,	uk,	F, B);
	measurementResidual(zk, H, xk, yk);
	}


	#pragma omp taskwait
	{
	stateUpdate(xk, Kk, yk);
	covarianceUpdate(Kk, H, Pk);

	printf("xk\n");
	for (int i=0; i<xk_dim; i++)
		printf("%f ", xk[i]);
	
	printf("\nPk\n");
	for(int i=0; i<Pk_noRows; i++) {
		for(int j=0; j<Pk_noColumns; j++)
			printf("%f ", Pk[i*Pk_noColumns + j]);
		
		printf("\n");
	}
	}
}


int main() {

	/*DTYPE mat[STATE_DIM * STATE_DIM];

	for (int i=0; i<STATE_DIM; i++) {
		for (int j=0; j<STATE_DIM; j++) {
			if (i==j) mat[i*STATE_DIM + j] = 1;
			else mat[i*STATE_DIM + j] = 0;
		}
	}
	printmat(mat, STATE_DIM, STATE_DIM);
	inversemat(mat, STATE_DIM, mat, STATE_DIM);
	printmat(mat, STATE_DIM, STATE_DIM);
	*/

	double t1, t2;
	DTYPE xk[STATE_DIM] = {0, 0, 0, 0, 0, 0};
	DTYPE uk[INPUT_DIM] = {0, 0, 0, 0, 0, 0};

	DTYPE Pk[STATE_DIM * STATE_DIM] = { 500,   0,   0,   0,   0,   0,
								          0, 500,   0,   0,   0,   0,
          								  0,   0, 500,   0,   0,   0,
          								  0,   0,   0, 500,   0,   0,
          								  0,   0,   0,   0, 500,   0,
          								  0,   0,   0,   0,   0, 500 };

	DTYPE zk[MEASUREMENT_DIM] = {393.66, 300.4};

	DTYPE F[STATE_DIM * STATE_DIM] = {1,   1, 0.5,  0,  0,   0,
       								  0,   1,   1,  0,  0,   0,
       								  0,   0,   1,  0,  0,   0,
       								  0,   0,   0,  1,  1, 0.5,
       								  0,   0,   0,  0,  1,   1,
       								  0,   0,   0,  0,  0,   1};

	DTYPE Q[STATE_DIM * STATE_DIM] = {  0.01, 0.02, 0.02,    0,    0,    0,
        								0.02, 0.04, 0.04,    0,    0,    0,
        								0.02, 0.04, 0.04,    0,    0,    0,
          								   0,    0,    0, 0.01, 0.02, 0.02,
          								   0,    0,    0, 0.02, 0.04, 0.04,
          								   0,    0,    0, 0.02, 0.04, 0.04   };


	DTYPE B[STATE_DIM * INPUT_DIM] = {	0,   0,   0,  0,   0,   0,
       									0,   0,   0,  0,   0,   0,
										0,   0,   0,  0,   0,   0,
										0,   0,   0,  0,   0,   0,
										0,   0,   0,  0,   0,   0,
										0,   0,   0,  0,   0,   0 };

	DTYPE R[MEASUREMENT_DIM * MEASUREMENT_DIM] = {9, 0,
												  0, 9};


	DTYPE H[MEASUREMENT_DIM * STATE_DIM] = {1, 0, 0, 0, 0, 0,
       										0, 0, 0, 1, 0, 0};

	DTYPE Kk[STATE_DIM * MEASUREMENT_DIM];
	DTYPE yk[MEASUREMENT_DIM];

	t1 = omp_get_wtime();
	kalmanIterate(xk, uk, F, B, Pk, Q, yk, zk, H, Kk, R);
	t2 = omp_get_wtime();
	printf("Time: %g\n", t2-t1);
}


