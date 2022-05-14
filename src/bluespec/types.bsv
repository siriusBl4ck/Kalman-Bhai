import FixedPoint::*;
import Vector::*;

`include "params.bsv"

typedef FixedPoint#(`bits_int, `bits_frac) SysType;
typedef Vector#(`MAT_DIM, SysType) VecType;
typedef Vector#(`MAT_DIM, Vector#(`MAT_DIM, SysType)) MatType;