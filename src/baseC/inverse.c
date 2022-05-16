#include<stdio.h>
typedef float DTYPE;
#define MEASUREMENT_DIM 3

#define dimensions MEASUREMENT_DIM



void inversemata(DTYPE *res, 
				DTYPE *a) 
{
	/*if(res_dimensions != a_dimensions)
	{
		printf("void inversemat(): Error - Dimensions Mismatch");
		exit(0);
	}*/

	int i,j;
	DTYPE tempmat[dimensions][2*dimensions];
	#pragma HLS ARRAY_PARTITION variable=tempmat complete dim=0
	
	LOOP_copy1: for (i = 0; i < dimensions; i++) {
		LOOP_copy2: for (j = 0; j < 2 * dimensions; j++) {
			if (j < dimensions)
				tempmat[i][j] = a[i*dimensions + j];
            if (j == (i + dimensions))
                tempmat[i][j] = 1;
        }
    }

	/*LOOP_rowechange2 error: Unable to schedule 'load' operation on 'tempmat' due to limited memory ports (II=1)
	 *Can be solved by partitioning the array 'tempmat'. #pragma HLS ARRAY_PARTITION can be used.
	 *Doubt: (II=1)? rowechange2 uses two elements from two different rows. Only two elements are used and BRAM
	 *has two different ports which can be accessed at the same time. Why issue??
	 *The ARRAY_PARTITION directive cannot be used on arrays which are arguments of the function selected as an
	 *accelerator
	 *
	 *#pragma HLS ARRAY_PARTITION variable = tempmat complete
	 *#pragma HLS ARRAY_PARTITION variable = tempmat cyclic factor = 2 dim = 1
    */



	/*int x, y;
    LOOP_rowechange1: for (x = dimensions - 1; x > 0; x--) {
        if (tempmat[x - 1][0] < tempmat[x][0]) {
        	LOOP_rowechange2: for (y=0; y < 2*dimensions; y++) {
				temp = tempmat[x][y];
				tempmat[x][y] = tempmat[x-1][y];
				tempmat[x-1][y] = temp;
			}
        }
    }*/

    /*
    This code is not working. Throwing up dependency errors even if dependency is explicitly stated. Should check it
    out later


    LOOP_elimination1: for (i = 0; i < dimensions; i++) {
    	LOOP_elimination2: for (j = 0; j < dimensions; j++) {
			#pragma HLS LOOP_FLATTEN off
			#pragma HLS DEPENDENCE variable=tempmat type=intra dependent=true
    		if (j != i) {
                temp = tempmat[j][i] / tempmat[i][i];
                LOOP_elimination3: for (k = 0; k < 2 * dimensions; k++) {
					#pragma HLS UNROLL
                	tempmat[j][k] -= tempmat[i][k] * temp;
                }
            }
        }
    }


    LOOP_normalization1: for (i = 0; i < dimensions; i++) {
	#pragma HLS DEPENDENCE variable=tempmat intra true
    	temp = 1/tempmat[i][i];
        LOOP_normalization2: for (j = 0; j < 2 * dimensions; j++) {
			#pragma HLS UNROLL
        	tempmat[i][j] = tempmat[i][j] * temp; //see if it can be added here
        }
    }
	*/

	int x, y, z;
	float temp;

    LOOP_elimination1: for (x = 0; x < dimensions; x++) {
    	LOOP_elimination2: for (y = 0; y < dimensions; y++) {
#pragma HLS DEPENDENCE variable=tempmat type=intra dependent=true
#pragma HLS PIPELINE II=7
			if (x != y) {
				if (tempmat[x][x]==0)
				{
					LOOP_sumrows1: for (int i = x+1; i < dimensions; i++){
						LOOP_sumrows2: for(int j = 0; j < 2*dimensions; j++){
							tempmat[x][j] = tempmat[x][j] + tempmat[i][j];
						}
					}
				}
                temp = tempmat[y][x] / tempmat[x][x];
                LOOP_elimination3: for (z = 0; z < 2 * dimensions; z++) {
					#pragma HLS UNROLL
					tempmat[y][z] = tempmat[y][z] - tempmat[x][z] * temp;
                }
            }
        }
    }

	int m;
    DTYPE inversediagonal_elements[dimensions];
    LOOP_inversediagonal: for(m = 0; m < dimensions; m++)
    {
    	inversediagonal_elements[m] = 1/tempmat[m][m];
    }

    int n,p;
    LOOP_normalization1: for (n = 0; n < dimensions; n++) {
    	LOOP_normalization2: for (p = 0; p < 2 * dimensions; p++) {
    		#pragma HLS UNROLL
            tempmat[n][p] = tempmat[n][p] * inversediagonal_elements[n];
        }
    }


    int q,r;
	LOOP_copyback1: for (q=0; q<dimensions; q++) {
		LOOP_copyback2: for (r=0; r<dimensions; r++) {
			res[q*dimensions + r] = tempmat[q][r+dimensions];
		}
	}
    //for(i=0;  i<dimensions*dimensions; i++)
    //	printf("%f\t", res[i]);

}


void main() {
	DTYPE res[dimensions*dimensions];
	DTYPE a[dimensions*dimensions] = { 1, 1, 0,
										0, 1, 0,
										0, 0, 1};

	DTYPE xd[dimensions*dimensions];

	
	inversemata(res, a);
	
	printf("\nresult\n");
	for(int i =0; i<dimensions; i++) {	
		for(int j=0; j<dimensions; j++)
			printf("%f ", res[i*dimensions+j]);
		printf("\n");
	}
/*
	for(int i=0; i<dimensions; i++) {
		for(int j=0; j<dimensions; j++) {
			xd[i*dimensions+j] = 0;
			for(int k=0; k<dimensions; k++)
		}
	}*/

}