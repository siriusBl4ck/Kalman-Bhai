import FixedPoint::*;
import Vector::*;

`include "params.bsv"

typedef FixedPoint#(`bits_int, `bits_frac) SysType;

typedef Vector#(`STATE_DIM, Reg#(SysType)) VecTypeSD;
typedef Vector#(`INPUT_DIM, Reg#(SysType)) VecTypeID;
typedef Vector#(`MEASUREMENT_DIM, Reg#(SysType)) VecTypeMD;
typedef Vector#(`MEASUREMENT_DIM, SysType) VecTypeMD;
typedef Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) MatTypeMD_noregs;
typedef Vector#(`STATE_DIM, Vector#(`STATE_DIM, Reg#(SysType))) MatTypeSD;


Vector#(`STATE_DIM, Vector#(`INPUT_DIM, SysType)) B = replicate(replicate(0));
Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) F = replicate(replicate(0));

F[0][0] = 1;
F[0][1] = 1;
F[0][2] = fromRational(1, 2);
F[1][1] = 1;
F[1][2] = 1;
F[2][2] = 1;
F[3][3] = 1;
F[3][4] = 1;
F[3][5] = fromRational(1, 2);
F[4][4] = 1;
F[4][5] = 1;
F[5][5] = 1;

Vector#(`MEASUREMENT_DIM, Vector#(`STATE_DIM, SysType)) H = replicate(replicate(0));
H[0][0] = 1;
H[1][3] = 1;

Vector#(STATE_DIM, Vector#(`STATE_DIM, SysType)) Q = replicate(replicate(0));
Q[0][0] = fromRational(1, 100);
Q[0][1] = fromRational(2, 100);
Q[0][2] = fromRational(2, 100);

Q[1][0] = fromRational(2, 100);
Q[1][1] = fromRational(4, 100);
Q[1][2] = fromRational(4, 100);

Q[2][0] = fromRational(2, 100);
Q[2][1] = fromRational(4, 100);
Q[2][2] = fromRational(4, 100);

Q[3][3] = fromRational(1, 100);
Q[3][4] = fromRational(2, 100);
Q[3][5] = fromRational(2, 100);

Q[4][3] = fromRational(2, 100);
Q[4][4] = fromRational(4, 100);
Q[4][5] = fromRational(4, 100);

