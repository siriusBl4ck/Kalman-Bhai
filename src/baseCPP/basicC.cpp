#include <iostream>
#include <iostream>
#include <Eigen/Dense>

#define STATE_VAR_DIM 6
typedef Eigen::Matrix<float, STATE_VAR_DIM, STATE_VAR_DIM> mat;
typedef Eigen::Matrix<float, STATE_VAR_DIM, 1> vec;

/*
int main()
{
  Eigen::Matrix2d a;
  a << 1, 2,
       3, 4;
  Eigen::Vector3d v(1,2,3);
  std::cout << "a * 2.5 =\n" << a * 2.5 << std::endl;
  std::cout << "0.1 * v =\n" << 0.1 * v << std::endl;
  std::cout << "Doing v *= 2;" << std::endl;
  v *= 2;
  std::cout << "Now v =\n" << v << std::endl;
}
*/
void kalmanIterate(vec *xk, vec *uk, mat *Pk, vec *yk, vec *zk, mat *Kk, mat *F, mat *B, mat *Q, mat *R, mat *H){
    //predict
    vec M, N;
    M = (*F) * (*xk);
    N = (*B) * (*uk);
    *xk = M + N;

    mat L;
    L = (*F) * (*Pk);
    L = (L) * (F->transpose());
    *Pk = L + *Q;

    //update
    vec E;
    E = (*H) * (*xk);
    *yk = (*zk) - (E);

    mat A, C;
    A = (*Pk) * (H->transpose());
    C = (*H) * (A);
    C = (*R) * (C);
    *Kk = A * C;

    *xk = *xk + (*Kk) * (*yk);

    *Pk = (mat::Identity() - (*Kk) * (*H)) * (*Pk);
}

int main(){
    
}