import FixedPoint::*;
import Vector::*;

`include "params.bsv"

`define MAT_DIM 6


typedef FixedPoint#(`bits_int, `bits_frac) SysType;

typedef Vector#(`STATE_DIM, Reg#(SysType)) VecTypeSD;
typedef Vector#(`INPUT_DIM, Reg#(SysType)) VecTypeID;
typedef Vector#(`MEASUREMENT_DIM, Reg#(SysType)) VecTypeMD;

typedef Vector#(`STATE_DIM, Vector#(`STATE_DIM, Reg#(SysType))) MatTypeSD;

typedef Vector#(`MAT_DIM, Vector#(`MAT_DIM, SysType)) MatType;

typedef Vector#(`MAT_DIM, SysType) VecType;


Vector#(`STATE_DIM, Vector#(`INPUT_DIM, SysType)) sysB = replicate(replicate(0));
Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) sysF = replicate(replicate(0));

Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) sysR = replicate(replicate(0));

Vector#(`MEASUREMENT_DIM, Vector#(`STATE_DIM, SysType)) sysH = replicate(replicate(0));


Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) sysQ = replicate(replicate(0));
/*
sysF[0][0] = 1;
sysF[0][1] = 1;
sysF[0][2] = fromRational(1, 2);
sysF[1][1] = 1;
sysF[1][2] = 1;
sysF[2][2] = 1;
sysF[3][3] = 1;
sysF[3][4] = 1;
sysF[3][5] = fromRational(1, 2);
sysF[4][4] = 1;
sysF[4][5] = 1;
sysF[5][5] = 1;

sysH[0][0] = 1;
sysH[1][3] = 1;


sysQ[0][0] = fromRational(1, 100);
sysQ[0][1] = fromRational(2, 100);
sysQ[0][2] = fromRational(2, 100);

sysQ[1][0] = fromRational(2, 100);
sysQ[1][1] = fromRational(4, 100);
sysQ[1][2] = fromRational(4, 100);

sysQ[2][0] = fromRational(2, 100);
sysQ[2][1] = fromRational(4, 100);
sysQ[2][2] = fromRational(4, 100);

sysQ[3][3] = fromRational(1, 100);
sysQ[3][4] = fromRational(2, 100);
sysQ[3][5] = fromRational(2, 100);

sysQ[4][3] = fromRational(2, 100);
sysQ[4][4] = fromRational(4, 100);
sysQ[4][5] = fromRational(4, 100);

*/
