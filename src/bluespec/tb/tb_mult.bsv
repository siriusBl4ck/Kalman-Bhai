package tb_mult;

`include "types.bsv"

import mat_mult_systolic::*;

(*synthesize*)
module mk_tb_mult(Empty);
    Ifc_mat_imm mult_mod <- mkmat_imm;
    MatTypeSD immL2 <- replicateM(replicateM(mkReg(0))), immL1 <- replicateM(replicateM(mkReg(0)));
    Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) sysF1 = replicate(replicate(0));
    
    sysF1[0][0] = 1;
    sysF1[0][1] = 2;
    sysF1[0][2] = fromRational(1, 2);
    sysF1[1][1] = 3;
    sysF1[1][2] = 4;
    sysF1[2][2] = 5;
    sysF1[3][3] = 6;
    sysF1[3][4] = 7;
    sysF1[3][5] = fromRational(1, 2);
    sysF1[4][4] = 8;
    sysF1[4][5] = 9;
    sysF1[5][5] = 10;

    rule cov_predict2;
		MatType tempF = replicate(replicate(unpack(0)));
		MatType tempL1 = replicate(replicate(unpack(0)));
		
		for(Integer i=0; i<`STATE_DIM; i=i+1) begin
			/*for(int j=0; j<`STATE_DIM; j=j+1) begin
				tempF[i][j] = sysF1[i][j];
				//tempL1[i][j] = immL1[i][j];
			end*/
			tempF[i][i] = fromRational(i,1);
			tempL1[i][i] = 1;
		end
		
		mult_mod.putAB(tempF, tempL1);
		// mult_mod.start;
	endrule


	rule store_L2;
		let out_mat <- mult_mod.getC;
		$display("store\n");
		for (int i=0; i<`MAT_DIM; i=i+1) begin
			for(int j=0; j<`MAT_DIM; j=j+1) begin
				$display(" ");
				fxptWrite(5, out_mat[i][j]);
			end 
			$display("\n");
		end 
		$finish;


		/*
		let k = mult_mod.getk;


		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				if ((i<`STATE_DIM) && (k-i<`STATE_DIM))
					immL2[i][k-i] <= out_stream[i];
					$display("\nL2: (%d,%d)\n", i, k-i);
					fxptWrite(5, out_stream[i]);
			end
		end

		if (k==(`STATE_DIM-1))
			$finish;
		*/
    endrule
endmodule

endpackage