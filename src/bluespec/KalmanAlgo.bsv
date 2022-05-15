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
	

	Vector_Ifc#(SysType) vdot1 <- mkVectorDot, vdot2 <- mkVectorDot;
	
	Reg#(VecTypeSD) xk <- mkReg(defaultValue);
	Reg#(VecTypeMD) yk <- mkReg(defaultValue);
	Reg#(VecTypeMD) zk <- mkReg(defaultValue);
	Reg#(MatTypeSD) Pk <- mkReg(defaultValue);

	//State predictor vars
	Vector#(`STATE_DIM, Reg#(SysType)) M <- replicateM(mkReg(defaultValue)), N <- replicateM(mkReg(defaultValue));

	Reg#(int) SPa_cntri <- mkReg(0), SPa_cntrj <- mkReg(0), SP2a <- mkReg(0), SP2b <- mkReg(0); /// to be reduced
	
	Reg#(Bool) enable_SP1a <- mkReg(False);

	rule state_predictor1a (enable_SP1a);
		vdot1.puta(F[SPa_cntri][SPa_cntrj]);
		vdot1.putb(xk[SPa_cntrj]);
		enable_storeM <= True;

		if (SPa_cntrj == `STATE_DIM-1) begin
			SPa_cntrj <= 0;
			vdot1.end_value(True);
			if (SPa_cntri == `STATE_DIM-1) begin
				SPa_cntri <= 0;
				enable_SP1a <= False;
			end 
			else
				SPa_cntri <= SPa_cntri+1;
		end 
		else begin
			SPa_cntrj <= SPa_cntrj+1;
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
		vdot2.puta(B[SPb_cntri][SPb_cntrj]);
		vdot2.putb(uk[SPb_cntrj]);
		enable_storeN <= True;

		if (SPb_cntrj == `INPUT_DIM-1) begin
			SPb_cntrj <= 0;
			vdot2.end_value(True);
			if (SPb_cntri == `STATE_DIM-1) begin
				SPb_cntri <= 0;
				enable_SP1b <= False;
			end 
			else
				SPb_cntri <= SPb_cntri+1;
		end 
		else begin
			SPb_cntrj <= SPb_cntrj+1;
			vdot2.end_value(False);
		end 
	endrule
	
	rule store_N (enable_storeN);
		let zb <- vdot2.dot_result;
		N[SP2b] <= z;
		
		if (SP2b == `STATE_DIM-1) {
			SP2b <= 0;
			enable_SP2b <= True;
			enable_storeN <= False;
		}
		else
			SP2b <= SP2b+1;
	endrule

	rule state_predictor2 (enable_SP2a && enable_SP2b);
		for (int i=0; i<`STATE_DIM; i=i+1)
			xk[i] <= M[i] + N[i];

		enable_SP2a <= False;
		enable_SP2b <= False;
		enable_MR1 <= True;
	endrule

	
	// Measurement Residual
	Reg#(Bool) enable_MR1 <- mkReg(False);
	Reg#(int) MR_cntri <- mkReg(0), MR_cntrj <- mkReg(0), MR2 <- mkReg(0);
	Reg#(VecType) yk <- mkReg(defaultValue);

	rule measurement_residual1 (enable_MR1);
		vdot1.puta(H[MR_cntri][MR_cntrj]);
		vdot1.putb(xk[MR_cntrj]);
		enable_storeE <= True;

		if (MR_cntrj == `STATE_DIM-1) begin
			MR_cntrj <= 0;
			vdot1.end_value(True);
			if (MR_cntri == `MEASUREMENT_DIM-1) begin
				MR_cntri <= 0;
				enable_MR1 <= False;
			end
			else
				MR_cntri <= MR_cntri+1;
		end 
		else begin
			MR_cntrj <= MR_cntrj+1;
			vdot1.end_value(False);
		end
	endrule

	rule store_E (enable_storeE);
		let ze <- vdot1.dot_result;
		E[MR2] <= ze;

		if (MR2 == `MEASUREMENT_DIM-1) begin
			MR2 <= 0;
			enable_MR2 <= True;
			enable_storeE <= False;
		end 
		else
			MR2 <= MR2+1;
	endrule

	rule measurement_residual2 (enable_MR2 && zk_valid); //check for zk?
		for (int i=0; i<`MEASUREMENT_DIM; i=i+1)
			yk[i] <= zk[i] - E[i];
		
		enable_MR2 <= False;
		enable_SUa <= True;
	endrule

	//Cov predictor

	rule cov_predict1 (enable_CP1);

		enable_CP2 <= True;
		enable_CP1 <= False;
	endrule

	rule cov_predict2 (enable_CP2);
		MatType temp_Pk = defaultValue;

		for (int i=0; i<`STATE_DIM; i=i+1)
			for (int j=0; j<`STATE_DIM; j=j+1)
				temp_Pk[i][j] = L2[i][j] + Q[i][j];
		
		Pk <= temp_Pk;
		enable_CP2 <= False;
		enable_KG1 <= True;
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

	//State update
	Reg#(int) SU_cntri <- mkReg(0), SU_cntrj <- mkReg(0), SU2_cntr <- mkReg(0);

	rule state_update1 (enable_SUa && enable_SUb);
		vdot1.puta(Kk[SU_cntri][SU_cntrj]);
		vdot1.putb(yk[SU_cntrj]);
		enable_storeTemp1 <= True;

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

	rule store_temp1 (enable_storeTemp1);
		let z <- vdot1,dot_result;
		temp1[SU2_cntr] <= z;

		enable_storeTemp1 <= False;
		enable_store2 <= True;

	endrule

	rule state_update2 (enable_store2);
		
	
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


