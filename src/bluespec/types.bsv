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
