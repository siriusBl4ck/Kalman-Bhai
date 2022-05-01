import FixedPoint::*;

`include "params.bsv"

typedef FixedPoint#(`bits_int, `bits_frac) SysType;
typedef Bit#(TMul#(`INP_LEN, `MAT_DIM)) VecType;
typedef Bit#(TMul#(TMul#(`INP_LEN, `MAT_DIM), `MAT_DIM)) MatType;