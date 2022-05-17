#include"baseline_code_hls.h"
int main() {

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
	return ret;
}
