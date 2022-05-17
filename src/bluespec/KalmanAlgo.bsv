package KalmanAlgo;

`include "types.bsv"

import vector_dot::*;

interface Kalman_Ifc;
	method Action put_xk_uk (VecTypeSD inp_xk, VecTypeID inp_uk);
	method Action put_Pk (MatTypeSD inp_Pk);
	method Action put_zk (VecTypeMD inp_zk);
	method MatType get_Pk;
	method VecType get_xk;
	method VecType get_yk;
endinterface

(*synthesize*)
module mkKalman(Kalman_Ifc);
	// To put a constraint on resources only 2 vector dot modules are needed
	Vector_Ifc#(SysType) vdot1 <- mkVectorDot, vdot2 <- mkVectorDot;
	//Ifc_mat_mult_systolic mult_mod <- mat_mult_systolic;
	Ifc_mat_imm mult_mod <- mkmat_imm;

	VecTypeSD xk <- replicateM(mkReg(defaultValue));
	VecTypeMD yk <- replicateM(mkReg(defaultValue));
	VecTypeMD zk <- replicateM(mkReg(defaultValue));
	MatTypeSD Pk <- replicateM(mkReg(defaultValue));

	// counter (cntr) can be reduced easily and only 6 are needed

	//State predictor vars
	VecTypeSD M <- replicateM(mkReg(defaultValue)), N <- replicateM(mkReg(defaultValue));
	Reg#(int) vd1_cntr
	Reg#(int) SP1a_cntri <- mkReg(0), SP1a_cntrj <- mkReg(0), SP1b_cntri <- mkReg(0), SP1b_cntrj <- mkReg(0), SP2a <- mkReg(0), SP2b <- mkReg(0); /// to be reduced
	
	Reg#(Bool) enable_SP1a <- mkReg(False), enable_storeM <- mkReg(False), enable_SP1b <- mkReg(False), enable_storeN <- mkReg(False);
	Reg#(Bool) enable_SP2a <- mkReg(False), enable_SP2b <- mkReg(False);


	// Measurement Residual
	Reg#(Bool) enable_MR1 <- mkReg(False), enable_MR2 <- mkReg(False), enable_SUa <- mkReg(False);
	Reg#(int) MR1_cntri <- mkReg(0), MR1_cntrj <- mkReg(0), MR2_cntr <- mkReg(0); //to be reduced
	Reg#(VecType) yk <- mkReg(defaultValue);
	Reg#(Bool) zk_valid <- mkReg(False);

	//State update vars
	Reg#(int) SU_cntri <- mkReg(0), SU_cntrj <- mkReg(0), SU2_cntr <- mkReg(0);


	// State Predictor (SP) rules
	// This rule is using vector dot product module to compute for matrix*vector
	rule state_predictor1a (enable_SP1a);
		vdot1.puta(F[SP1a_cntri][SP1a_cntrj]);
		vdot1.putb(xk[SP1a_cntrj]);
		enable_storeM <= True;

		if (SP1a_cntrj == `STATE_DIM-1) begin
			SP1a_cntrj <= 0;
			vdot1.end_value(True);
			if (SP1a_cntri == `STATE_DIM-1) begin
				SP1a_cntri <= 0;
				enable_SP1a <= False;
			end 
			else
				SP1a_cntri <= SP1a_cntri+1;
		end 
		else begin
			SP1a_cntrj <= SP1a_cntrj+1;
			vdot1.end_value(False);
		end 
	endrule

	rule store_M (enable_storeM);
		let za <- vdot1.dot_result;
		M[SP2a] <= z;
		
		if (SP2a == `STATE_DIM-1) {
			SP2a <= 0;
			enable_SP2a <= True;
			enable_storeM <= False;
		}
		else
			SP2a <= SP2a+1;
	endrule

	rule state_predictor1b (enable_SP1b);
		vdot2.puta(B[SP1b_cntri][SP1b_cntrj]);
		vdot2.putb(uk[SP1b_cntrj]);
		enable_storeN <= True;

		if (SP1b_cntrj == `INPUT_DIM-1) begin
			SP1b_cntrj <= 0;
			vdot2.end_value(True);
			if (SP1b_cntri == `STATE_DIM-1) begin
				SP1b_cntri <= 0;
				enable_SP1b <= False;
			end 
			else
				SP1b_cntri <= SP1b_cntri+1;
		end 
		else begin
			SP1b_cntrj <= SP1b_cntrj+1;
			vdot2.end_value(False);
		end 
	endrule
	
	rule store_N (enable_storeN);
		let zb <- vdot2.dot_result;
		N[SP2b_cntr] <= z;
		
		if (SP2b_cntr == `STATE_DIM-1) {
			SP2b_cnr <= 0;
			enable_SP2b <= True;
			enable_storeN <= False;
		}
		else
			SP2b_cntr <= SP2b_cntr+1;
	endrule

	rule state_predictor2 (enable_SP2a && enable_SP2b);
		for (int i=0; i<`STATE_DIM; i=i+1)
			xk[i] <= M[i] + N[i];

		enable_SP2a <= False;
		enable_SP2b <= False;
		enable_MR1 <= True;
	endrule


	// Measurement Residual rules
	rule measurement_residual1 (enable_MR1);
		vdot1.puta(H[MR1_cntri][MR1_cntrj]);
		vdot1.putb(xk[MR1_cntrj]);
		enable_storeE <= True;

		if (MR1_cntrj == `STATE_DIM-1) begin
			MR1_cntrj <= 0;
			vdot1.end_value(True);
			if (MR1_cntri == `MEASUREMENT_DIM-1) begin
				MR1_cntri <= 0;
				enable_MR1 <= False;
			end
			else
				MR1_cntri <= MR1_cntri+1;
		end 
		else begin
			MR1_cntrj <= MR1_cntrj+1;
			vdot1.end_value(False);
		end
	endrule

	rule store_E (enable_storeE);
		let ze <- vdot1.dot_result;
		E[MR2_cntr] <= ze;

		if (MR2_cntr == `MEASUREMENT_DIM-1) begin
			MR2_cntr <= 0;
			enable_MR2 <= True;
			enable_storeE <= False;
		end 
		else
			MR2_cntr <= MR2_cntr+1;
	endrule

	rule measurement_residual2 (enable_MR2 && zk_valid); 
		for (int i=0; i<`MEASUREMENT_DIM; i=i+1)
			yk[i] <= zk[i] - E[i];
		
		enable_MR2 <= False;
		enable_SUa <= True;
	endrule


	//Cov predictor vars
	Reg#(Bool) enable_CP1 <- mkReg(False), enable_CP2 <- mkReg(False);
	MatTypeSD L2 <- replicateM(replicateM(mkReg(0))), L1 <- replicateM(replicateM(mkReg(0)));
	Reg#(int) CP_cntr <- mkReg(0);
	

	//Cov predictor Rules
	//REPLICATE THIS
	rule cov_predict1 (enable_CP1);
		MatType tempF = defaultValue;
		
		for(int i=0; i<`MAT_DIM; i=i+1)
			for(int j=0; j<`MAT_DIM; j=j+1)
				tempF[i][j] = F[j][i];

		mult_mod.putAB(Pk, tempF);
		mult_mod.start;
	endrule

	rule store_L1 (enable_CP1);
		let out_stream = mult_mod.getC;
		let k = mult_mod.getk;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				L1[i][k-i] <= out_stream[i];
			end 
		end

		if (k==2*`MAT_DIM-2) begin
			enable_CP1 <= False;
			enable_CP2 <= True;
		end
	endrule


	/*VecType inp_Astream = replicate(0), inp_Bstream = replicate(0);

		if (CP_cntr == 3*`MAT_DIM+5) begin
			CP_cntr <= 0;
			enable_CP1 <= False;
			enable_CP2 <= True;
		end
		else
			CP_cntr <= CP_cntr+1;

        for(int i=0; i<`MAT_DIM; i=i+1) begin
            if ((CP_cntr-i < `MAT_DIM) &&(i<=CP_cntr)) begin
				// Pk*F.Transpose
                inp_Astream[i] = Pk[i][CP_cntr-i];
                inp_Bstream[i] = F[i][CP_cntr-i];
			end 
		end

		mult_mod.feed_inp_stream(inp_Astream, inp_Bstream);
	endrule
	int k = CP_cntr - i - `MAT_DIM - 7;*/



	rule cov_predict2 (enable_CP2);
		VecType inp_Astream = replicate(0), inp_Bstream = replicate(0);

		if (CP_cntr == 3*`MAT_DIM+5) begin
			CP_cntr <= 0;
			enable_CP2 <= False;
			enable_CP3 <= True;
		end
		else
			CP_cntr <= CP_cntr+1;

        for(int i=0; i<`MAT_DIM; i=i+1) begin
            if ((CP_cntr-i < `MAT_DIM) &&(i<=CP_cntr)) begin
				// F*L1
                inp_Astream[i] = F[i][CP_cntr-i];
                inp_Bstream[i] = L1[CP_cntr-i][i];
			end 
		end

		mult_mod.feed_inp_stream(inp_Astream, inp_Bstream);
	endrule

	rule store_L2 (enable_CP2);
		let out_stream = mult_mod.get_out_stream;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			int k = CP_cntr - i - `MAT_DIM - 7;

			if ((k>=0) && (k<`MAT_DIM)) begin
				L2[i][k] <= out_stream[i];
			end 
		end
	endrule

	rule cov_predict3 (enable_CP3);
		for (int i=0; i<`STATE_DIM; i=i+1)
			for (int j=0; j<`STATE_DIM; j=j+1)
				Pk[i][j] = L2[i][j] + Q[i][j];	
		
		enable_CP3 <= False;
		enable_KG1 <= True;
	endrule


	//KalmanGC vars
	Reg#(Bool) enable_KG1 <- mkReg(False), enable_SUb <- mkReg(False);
	Reg#(int) KG_cntr <- mkReg(0);

	rule kalmanGC1 (enable_KG1);
		VecType inp_Astream = replicate(0), inp_Bstream = replicate(0);

		if (KG_cntr == 3*`MAT_DIM+5) begin	//////
			KG_cntr <= 0;
			enable_CP1 <= False;
			enable_CP2 <= True;
		end
		else
			KG_cntr <= KG_cntr+1;

        for(int i=0; i<`MAT_DIM; i=i+1) begin
            if ((CP_cntr-i < `MAT_DIM) &&(i<=CP_cntr)) begin
				// Pk*F.Transpose
                inp_Astream[i] = Pk[i][CP_cntr-i];
                inp_Bstream[i] = F[i][CP_cntr-i];
			end 
		end

		mult_mod.feed_inp_stream(inp_Astream, inp_Bstream);
	endrule

	rule store_L1 (enable_CP1);
		let out_stream = mult_mod.get_out_stream;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			int k = CP_cntr - i - `MAT_DIM - 7;

			if ((k>=0) && (k<`MAT_DIM)) begin
				L1[i][k] <= out_stream[i];
			end 
		end
	endrule
	rule kalmanGC1 (enable_KG1);

		enable_KG1 <= False;
		enable_KG2 <= True;
	endrule

	rule kalmanGC2 (enable_KG2);

		//inverse of C1

		enable_KG2 <= False;
		enable_KG3 <= True;
	endrule

	rule kalmanGC3 (enable_KG3);
		//A * C1;

		enable_KG3 <= False;
		enable_SUb <= True;
	endrule


	//  State update rules
	rule state_update1 (enable_SUa && enable_SUb);
		vdot1.puta(Kk[SU_cntri][SU_cntrj]);
		vdot1.putb(yk[SU_cntrj]);
		enable_storeTemp <= True;

		if (SU_cntrj == `MEASUREMENT_DIM-1) begin
			SU_cntrj <= 0;
			vdot1.end_value(True);
			if (SU_cntri == `STATE_DIM-1) begin
				SU_cntri <= 0;
				enable_SUa <= False;
				enable_SUb <= False;
			end
			else
				SU_cntri <= SU_cntri+1;
		end 
		else begin
			SU_cntrj <= SU_cntrj+1;
			vdot1.end_value(False);
		end
	endrule

	rule store_temp (enable_storeTemp);
		let temp <- vdot1.dot_result;
		xk[SU2_cntr] <= xk[SU2_cntr]+temp;

		if (SU2_cntr == `STATE_DIM-1) begin
			SU2_cntr <= 0;
			xk_ready <= True;
			enable_storeTemp <= False;
		end 
		else
			SU2_cntr <= SU2_cntr+1;
	endrule


	//Cov update
	rule cov_updater (enable_SUb);
	//Kk*H 

		Pk_ready <= True;
	
	endrule

		


	method Action put_xk_uk (VecType inp_xk, VecType inp_uk);
		xk <= inp_xk;
		uk <= inp_uk;
		enable_SP1a <= True;
		enable_SP1b <= True;
	endmethod

	method Action put_Pk (MatType inp_Pk);
		Pk <= inp_Pk;
		enable_CP <= True;
	endmethod

	method Action put_zk (VecTypeMD inp_zk);
		zk <= inp_zk;
		zk_valid <= True;
	endmethod

	method MatType get_Pk = Pk;
	method VecType get_xk = xk;
	method VecType get_yk = yk;
endmodule


endpackage


