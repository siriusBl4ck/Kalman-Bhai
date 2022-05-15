package tb_mat_inv;

`include "types.bsv"

import FixedPoint::*;
import mat_inv::*;

(*synthesize*)
module mkTb_mat_inv(Empty);
	Ifc_mat_inv_gaussian myInv <- mat_inv_gaussian_3x3;

	Reg#(MatType) inp <- mkReg(defaultValue);

	Reg#(int) stage <- mkReg(0);

    MatType lv_mat_A;

    lv_mat_A[0][0] = 1;
    lv_mat_A[0][1] = 0;//2;
    lv_mat_A[0][2] = 0;//3;

    lv_mat_A[1][0] = 0;//4;
    lv_mat_A[1][1] = 1;//5;
    lv_mat_A[1][2] = 0;//6;

    lv_mat_A[2][0] = 0;//7;
    lv_mat_A[2][1] = 0;//8;
    lv_mat_A[2][2] = 1;//9;

	rule init (stage==0);
		inp <= lv_mat_A;
		stage <= 1;
	endrule

	rule stg1 (stage == 1);
		myInv.put(inp);
		stage <= 2;	
	endrule

	rule stgx (stage==2);
		let z <- myInv.get();
		inp <= z;

		for(int i=0; i<`MAT_DIM; i=i+1)
			for(int j=0; j<`MAT_DIM; j=j+1)
				fxptWrite(5, inp[i][j]);
		stage <= 3;
	endrule

	rule init2 (stage==3);
		$display("---------");
		myInv.put(inp);
		stage <= 4;
	endrule

	rule stg2 (stage==2);
		let z <- myInv.get();
		inp <= z;

		for(int i=0; i<`MAT_DIM; i=i+1)
			for(int j=0; j<`MAT_DIM; j=j+1)
				fxptWrite(z[i][j]);
		$finish;
	endrule
endmodule


endpackage