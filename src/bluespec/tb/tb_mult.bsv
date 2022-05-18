package tb_mult;

`include "types.bsv"

import mat_mult_systolic::*;

(*synthesize*)
module mk_tb_mult(Empty);
    Ifc_mat_imm mult_mod <- mkmat_imm;
    MatTypeSD immL2 <- replicateM(replicateM(mkReg(0))), immL1 <- replicateM(replicateM(mkReg(0)));
    Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) sysF1 = replicate(replicate(0));
    
    sysF1[0][0] = 1;
    sysF1[0][1] = 1;
    sysF1[0][2] = fromRational(1, 2);
    sysF1[1][1] = 1;
    sysF1[1][2] = 1;
    sysF1[2][2] = 1;
    sysF1[3][3] = 1;
    sysF1[3][4] = 1;
    sysF1[3][5] = fromRational(1, 2);
    sysF1[4][4] = 1;
    sysF1[4][5] = 1;
    sysF1[5][5] = 1;

    rule cov_predict2;
		MatType tempF = replicate(replicate(unpack(0)));
		MatType tempL1 = replicate(replicate(unpack(0)));
		
		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`STATE_DIM; j=j+1) begin
				tempF[i][j] = sysF1[i][j];
				tempL1[i][j] = immL1[i][j];
			end
		
		mult_mod.putAB(tempF, tempL1);
		// mult_mod.start;
	endrule

	rule store_L2;
		let out_stream = mult_mod.getC;
		let k = mult_mod.getk;

        mult_mod.rst;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				if ((i<`STATE_DIM) && (k-i<`STATE_DIM))
					immL2[i][k-i] <= out_stream[i];
			end
		end
        $finish();
    endrule
endmodule

endpackage