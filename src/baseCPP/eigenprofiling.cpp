#include <iostream>
#include <Eigen/Dense>
#include <inttypes.h>


#define STATE_VAR_DIM 12
#define MEASURE_VAR_DIM 6
typedef Eigen::Matrix<float, STATE_VAR_DIM, STATE_VAR_DIM> mat_6_6;
typedef Eigen::Matrix<float, MEASURE_VAR_DIM, STATE_VAR_DIM> mat_2_6;
typedef Eigen::Matrix<float, STATE_VAR_DIM, MEASURE_VAR_DIM> mat_6_2;
typedef Eigen::Matrix<float, MEASURE_VAR_DIM, MEASURE_VAR_DIM> mat_2_2;
typedef Eigen::Matrix<float, STATE_VAR_DIM, 1> vec_6;
typedef Eigen::Matrix<float, MEASURE_VAR_DIM, 1> vec_2;


void __attribute__ ((noinline)) statePredictor( 
                    vec_6   *xk, 
                    vec_6   *uk, 
                    mat_6_6 *F, 
                    mat_6_6 *B)
{
     //Prediction
     //x(k) = F*x(k-1) + B*u(k-1)
    vec_6 temp1, temp2;
    temp1 = (*F) * (*xk);
    temp2 = (*B) * (*uk);
    *xk = temp1 + temp2;
}

void __attribute__ ((noinline)) covariancePredictor( 
                    mat_6_6 *Pk,
                    mat_6_6 *F, 
                    mat_6_6 *Q) 
{
    //P(k) = F*P(k-1)*F.T + Q
    mat_6_6 temp3;
    temp3 = *Pk * (F->transpose());
    temp3 = (*F) * temp3;
    *Pk = temp3 + *Q;
}

void __attribute__ ((noinline)) measurementResidual( 
                    vec_2   *zk,
                    mat_2_6 *H,
                    vec_6   *xk, 
                    vec_2   *yk)
{
    //Update
    //y(k) = zk - H*x(k)
    vec_2 temp4;
    temp4 = *H * (*xk);
    *yk = *zk - temp4;
}

void __attribute__ ((noinline)) kalmangainCalculator( 
                    mat_6_6 *Pk,
                    mat_2_6 *H,
                    mat_2_2 *R,
                    mat_6_2 *Kk) 
{
    //K(k) =  P(k)*H.T*(R + H*P(k)*H.T).inverse
    mat_6_2 temp5;
    mat_2_2 temp6;
    temp5 = *Pk * (H->transpose());
    temp6 = *H * temp5;
    temp6 = *R + temp6;
    *Kk = temp5 * temp6.inverse();
}

void __attribute__ ((noinline)) stateUpdate( 
                    vec_6   *xk, 
                    mat_6_2 *Kk,
                    vec_2   *yk)
{
    //x(k) = x(k) + K(k)*y(k)
    *xk = *xk + (*Kk * (*yk));
}

void __attribute__ ((noinline)) covarianceUpdate( 
                    mat_6_2 *Kk,
                    mat_2_6 *H,
                    mat_6_6 *Pk)
{
    //P(k) = (1 - K(k)*H)*P(k)
    *Pk = (mat_6_6::Identity() - (*Kk)*(*H))*(*Pk);
}


int main(){
  
  vec_6 xk;
  xk << 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;

  vec_6 uk;
  uk << 0, 0, 0, 0, 0, 0;

  mat_6_6 Pk;
  Pk << 500,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
        0, 500,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
        0,   0, 500,   0,   0,   0,   0,   0,   0,   0,   0,   0,
        0,   0,   0, 500,   0,   0,   0,   0,   0,   0,   0,   0,
        0,   0,   0,   0, 500,   0,   0,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0, 500,   0,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   0, 500,   0,   0,   0,   0,   0, 
        0,   0,   0,   0,   0,   0,   0, 500,   0,   0,   0,   0,	
        0,   0,   0,   0,   0,   0,   0,   0, 500,   0,   0,   0,	
        0,   0,   0,   0,   0,   0,   0,   0,   0, 500,   0,   0,
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 500,   0,
        0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 500	;

  vec_2 zk;
  zk << 393.66, 300.4, 150.4, 142.5, 234, 235;

  mat_6_6 F;
  F << 1,   1, 0.5,  0,  0,   0,  0,   0,   0,  0,  0,   0,
        0,   1,   1,  0,  0,   0,  0,   0,   0,  0,  0,   0,
        0,   0,   1,  0,  0,   0,  0,   0,   0,  0,  0,   0,
        0,   0,   0,  1,  1, 0.5,  0,   0,   0,  0,  0,   0,
        0,   0,   0,  0,  1,   1,  0,   0,   0,  0,  0,   0,
        0,   0,   0,  0,  0,   1,  0,   0,   0,  0,  0,   0,
        0,   0,   0,  0,  0,   0,  1,   1, 0.5,  0,  0,   0, 
        0,   0,   0,  0,  0,   0,  0,   1,   1,  0,  0,   0,
        0,   0,   0,  0,  0,   0,  0,   0,   1,  0,  0,   0,
        0,   0,   0,  0,  0,   0,  0,   0,   0,  1,  1, 0.5,
        0,   0,   0,  0,  0,   0,  0,   0,   0,  0,  1,   1,
        0,   0,   0,  0,  0,   0,  0,   0,   0,  0,  0,   1;

  mat_6_6 Q;
  Q << 0.01, 0.02, 0.02,    0,    0,    0,    0,    0,    0,    0,    0,    0,
        0.02, 0.04, 0.04,    0,    0,    0,    0,    0,    0,    0,    0,    0,
        0.02, 0.04, 0.04,    0,    0,    0,    0,    0,    0,    0,    0,    0,
            0,    0,    0, 0.01, 0.02, 0.02,    0,    0,    0,    0,    0,    0,
            0,    0,    0, 0.02, 0.04, 0.04,    0,    0,    0,    0,    0,    0,
            0,    0,    0, 0.02, 0.04, 0.04,    0,    0,    0,    0,    0,    0,
            0,    0,    0,    0,    0,    0, 0.01, 0.02, 0.02,    0,    0,    0,
            0,    0,    0,    0,    0,    0, 0.02, 0.04, 0.04,    0,    0,    0,
            0,    0,    0,    0,    0,    0, 0.02, 0.04, 0.04,    0,    0,    0,
            0,    0,    0,    0,    0,    0,    0,    0,    0, 0.01, 0.02, 0.02,
            0,    0,    0,    0,    0,    0,    0,    0,    0, 0.02, 0.04, 0.04,
            0,    0,    0,    0,    0,    0,    0,    0,    0, 0.02, 0.04, 0.04;

  mat_6_6 B;
  B << 0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0,
        0,   0,   0,  0,   0,   0;

  mat_2_2 R;
  R << 9, 0, 0, 0, 0, 0,
        0, 9, 0, 0, 0, 0,
        0, 0, 9, 0, 0, 0,
        0, 0, 0, 9, 0, 0,
        0, 0, 0, 0, 9, 0,
        0, 0, 0, 0, 0, 9
;

  mat_2_6 H;
  H << 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0
        ;

  mat_6_2 Kk;
  vec_2 yk;

  statePredictor(&xk, &uk, &F, &B);
  covariancePredictor(&Pk, &F, &Q);
  measurementResidual(&zk, &H, &xk, &yk);
  kalmangainCalculator(&Pk, &H, &R, &Kk);
  stateUpdate(&xk, &Kk, &yk);
  covarianceUpdate(&Kk, &H, &Pk);
}