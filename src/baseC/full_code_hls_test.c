#include<stdio.h>
#include<stdlib.h>
#include<full_code_hls.h>

#define STATE_DIM 6
#define INPUT_DIM 6
#define MEASUREMENT_DIM 2
typedef float DTYPE;

void printmat(DTYPE *mat, int noRows, int noColumns) {
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


void printMatrices(DTYPE **mat, int noRows, int noColumns) {
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

	int ret = 0;

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

	kalmanIterate(xk, uk, F, B, Pk, Q, yk, zk, H, Kk, R);
	hls::print("boo");
	return ret;
}
