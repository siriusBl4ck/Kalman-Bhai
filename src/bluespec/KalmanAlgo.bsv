package KalmanAlgo;

`include "types.bsv"

import vector_dot::*;
import total_mat_inv::*;
import mat_mult_systolic::*;

interface Kalman_Ifc;
	method Action put_xk_uk (Vector#(`STATE_DIM, SysType) inp_xk, Vector#(`INPUT_DIM, SysType) inp_uk);

	method Action put_pk (Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) inp_pk);

	method Action put_zk (Vector#(`MEASUREMENT_DIM, SysType) inp_zk);

	method Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) get_pk();
	
	method Vector#(`STATE_DIM, SysType) get_xk();

	method Vector#(`MEASUREMENT_DIM, SysType) get_yk();
endinterface

(*synthesize*)
module mkKalman(Kalman_Ifc);
	// To put a constraint on resources only 2 vector dot modules are needed
	VectorDot_ifc#(SysType) vdot1 <- mkVectorDot, vdot2 <- mkVectorDot;
	//Ifc_mat_mult_systolic mult_mod <- mat_mult_systolic;
	Ifc_mat_imm mult_mod <- mkmat_imm;
	Ifc_mat_inv inv_mod <- mk_mat_inv;

	VecTypeSD xk <- replicateM(mkReg(defaultValue));
	VecTypeMD yk <- replicateM(mkReg(defaultValue));
	VecTypeMD zk <- replicateM(mkReg(defaultValue));
	VecTypeID uk <- replicateM(mkReg(defaultValue));
	MatTypeSD pk <- replicateM(replicateM(mkReg(defaultValue)));

	Reg#(Bool) xk_ready <- mkReg(False), yk_ready <- mkReg(False), pk_ready <- mkReg(False);

	// counter (cntr) can be reduced easily and only 6 are needed

	//State predictor vars
	VecTypeSD immM <- replicateM(mkReg(defaultValue)), immN <- replicateM(mkReg(defaultValue));
	Reg#(int) sp1a_cntri <- mkReg(0), sp1a_cntrj <- mkReg(0), sp1b_cntri <- mkReg(0), sp1b_cntrj <- mkReg(0), sp2a_cntr <- mkReg(0), sp2b_cntr <- mkReg(0); /// to be reduced
	
	Reg#(Bool) enable_SP1a <- mkReg(False), enable_storeM <- mkReg(False), enable_SP1b <- mkReg(False), enable_storeN <- mkReg(False);
	Reg#(Bool) enable_sp2a <- mkReg(False), enable_sp2b <- mkReg(False);


	// Measurement Residual
	Reg#(Bool) enable_MR1 <- mkReg(False), enable_MR2 <- mkReg(False), enable_SUa <- mkReg(False);
	Reg#(Bool) enable_storeE <- mkReg(False);
	VecTypeMD immE <- replicateM(mkReg(0));
	Reg#(int) mr1_cntri <- mkReg(0), mr1_cntrj <- mkReg(0), mr2_cntr <- mkReg(0); //to be reduced
	Reg#(Bool) zk_valid <- mkReg(False);

	//Cov predictor vars
	Reg#(Bool) enable_CP1 <- mkReg(False), enable_CP2 <- mkReg(False), enable_CP3 <- mkReg(False);
	MatTypeSD immL2 <- replicateM(replicateM(mkReg(0))), immL1 <- replicateM(replicateM(mkReg(0)));
	Reg#(int) mult_cntr <- mkReg(0);

	// Kalman Gain Calculator vars
	Reg#(Bool) enable_KG1 <- mkReg(False), enable_KG2 <- mkReg(False), enable_KG3 <- mkReg(False), enable_KG4 <- mkReg(False), enable_KG5 <- mkReg(False), enable_KG6 <- mkReg(False), enable_SU_CU <- mkReg(False);
	Vector#(`STATE_DIM, Vector#(`MEASUREMENT_DIM, Reg#(SysType))) immA <- replicateM(replicateM(mkReg(0)));
	Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, Reg#(SysType))) immC1 <- replicateM(replicateM(mkReg(0)));
	Vector#(`STATE_DIM, Vector#(`MEASUREMENT_DIM, Reg#(SysType))) kk <- replicateM(replicateM(mkReg(0)));

	//State update vars
	Reg#(int) su_cntri <- mkReg(0), su_cntrj <- mkReg(0), su2_cntr <- mkReg(0);
	Reg#(Bool) enable_storeT <- mkReg(False);

	//Cov update vars
	MatTypeSD immT1 <- replicateM(replicateM(mkReg(0))), immT2 <- replicateM(replicateM(mkReg(0)));




	// State Predictor (SP) rules
	// This rule is using vector dot product module to compute for matrix*vector


	rule state_predictor1a (enable_SP1a);
		$display($time, "state_predictor1a");
		vdot1.put_a(sysF[sp1a_cntri][sp1a_cntrj]);
		vdot1.put_b(xk[sp1a_cntrj]);
		enable_storeM <= True;

		if (sp1a_cntrj == `STATE_DIM-1) begin
			sp1a_cntrj <= 0;
			vdot1.end_value(True);
			if (sp1a_cntri == `STATE_DIM-1) begin
				sp1a_cntri <= 0;
				enable_SP1a <= False;
			end 
			else
				sp1a_cntri <= sp1a_cntri+1;
		end 
		else begin
			sp1a_cntrj <= sp1a_cntrj+1;
			vdot1.end_value(False);
		end 
	endrule

	rule store_M (enable_storeM);
		$display($time, "storeM");
		let za <- vdot1.dot_result;
		immM[sp2a_cntr] <= za;
		
		if (sp2a_cntr == `STATE_DIM-1) begin
			for (int i = 0; i < `STATE_DIM; i = i + 1) begin
				fxptWrite(5, immM[i]);
				$write(" ");
			end
			$write("\n");
			sp2a_cntr <= 0;
			enable_sp2a <= True;
			enable_storeM <= False;
		end
		else
			sp2a_cntr <= sp2a_cntr+1;
	endrule

	rule state_predictor1b (enable_SP1b);
		$display($time, "state_predictor1b");
		vdot2.put_a(sysB[sp1b_cntri][sp1b_cntrj]);
		vdot2.put_b(uk[sp1b_cntrj]);
		enable_storeN <= True;

		if (sp1b_cntrj == `INPUT_DIM-1) begin
			sp1b_cntrj <= 0;
			vdot2.end_value(True);
			if (sp1b_cntri == `STATE_DIM-1) begin
				sp1b_cntri <= 0;
				enable_SP1b <= False;
			end 
			else
				sp1b_cntri <= sp1b_cntri+1;
		end 
		else begin
			sp1b_cntrj <= sp1b_cntrj+1;
			vdot2.end_value(False);
		end 
	endrule
	
	rule store_N (enable_storeN);
		$display($time, "storeN");
		let zb <- vdot2.dot_result;
		immN[sp2b_cntr] <= zb;
		
		if (sp2b_cntr == `STATE_DIM-1) begin
			for (int i = 0; i < `STATE_DIM; i = i + 1) begin
				fxptWrite(5, immN[i]);
				$write(" ");
			end
			$write("\n");
			sp2b_cntr <= 0;
			enable_sp2b <= True;
			enable_storeN <= False;
		end
		else
			sp2b_cntr <= sp2b_cntr+1;
	endrule

	rule state_predictor2 (enable_sp2a && enable_sp2b);
		$display($time, "state_predictor2");
		for (int i=0; i<`STATE_DIM; i=i+1) begin
			xk[i] <= immM[i] + immN[i];
			fxptWrite(5, immM[i] + immN[i]);
			$write(" ");
		end
		$write("\n");

		enable_sp2a <= False;
		enable_sp2b <= False;
		enable_MR1 <= True;
	endrule


	// Measurement Residual rules
	rule measurement_residual1 (enable_MR1);
		$display($time, "measurement_residual1");
		vdot1.put_a(sysH[mr1_cntri][mr1_cntrj]);
		vdot1.put_b(xk[mr1_cntrj]);
		enable_storeE <= True;

		if (mr1_cntrj == `STATE_DIM-1) begin
			mr1_cntrj <= 0;
			vdot1.end_value(True);
			if (mr1_cntri == `MEASUREMENT_DIM-1) begin
				mr1_cntri <= 0;
				enable_MR1 <= False;
			end
			else
				mr1_cntri <= mr1_cntri+1;
		end 
		else begin
			mr1_cntrj <= mr1_cntrj+1;
			vdot1.end_value(False);
		end
	endrule

	rule store_E (enable_storeE);
		$display($time, "store_E");
		let ze <- vdot1.dot_result;
		immE[mr2_cntr] <= ze;

		if (mr2_cntr == `MEASUREMENT_DIM-1) begin
			for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
				fxptWrite(5, immE[i]);
				$write(" ");
			end
			$write("\n");
			mr2_cntr <= 0;
			enable_MR2 <= True;
			enable_storeE <= False;
		end 
		else
			mr2_cntr <= mr2_cntr+1;
	endrule

	rule measurement_residual2 (enable_MR2 && zk_valid);
		$display($time, "measurement_residual2");
		for (int i=0; i<`MEASUREMENT_DIM; i=i+1) begin
			yk[i] <= zk[i] - immE[i];
			fxptWrite(5, zk[i] - immE[i]);
			$write(" ");
		end
		$write("\n");
		
		enable_MR2 <= False;
		enable_SUa <= True;
		yk_ready <= True;
	endrule
	

	//Cov predictor Rules
	//REPLICATE THIS
	rule cov_predict1 (enable_CP1);
		$display($time, "cov_predict1");
		MatType tempF = replicate(replicate(unpack(0)));
		MatType temppk = replicate(replicate(unpack(0)));
		
		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`STATE_DIM; j=j+1) begin
				tempF[i][j] = sysF[j][i];
				temppk[i][j] = pk[i][j];
			end

		mult_mod.putAB(temppk, tempF);
		//mult_mod.start;
	endrule

	rule store_L1 (enable_CP1);
		$display($time, "store_L1");
		let out_stream = mult_mod.getC;
		let k = mult_mod.getk;
		mult_mod.rst;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				if ((i<`STATE_DIM) && (k-i<`STATE_DIM))
					immL1[i][k-i] <= out_stream[i];
			end
		end

		if (k==2*`MAT_DIM-2) begin
			enable_CP1 <= False;
			enable_CP2 <= True;

			for (int i = 0; i < `MAT_DIM; i = i + 1) begin
				for (int j = 0; j < `MAT_DIM; j = j + 1) begin
					fxptWrite(5, immL1[i][j]);
					$write(" ");
				end
				$write("\n");
			end
		end
	endrule

	rule cov_predict2 (enable_CP2);
		$display($time, "cov_predict2");
		//VecType inp_Astream = replicate(0), inp_Bstream = replicate(0);
		MatType tempF = replicate(replicate(unpack(0)));
		MatType tempL1 = replicate(replicate(unpack(0)));
		
		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`STATE_DIM; j=j+1) begin
				tempF[i][j] = sysF[i][j];
				tempL1[i][j] = immL1[i][j];
			end
		
		mult_mod.putAB(tempF, tempL1);
		//mult_mod.start;
	endrule

	rule store_L2 (enable_CP2);
		$display($time, "store_L2");
		let out_stream = mult_mod.getC;
		let k = mult_mod.getk;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				if ((i<`STATE_DIM) && (k-i<`STATE_DIM))
					immL2[i][k-i] <= out_stream[i];
			end
		end

		if (k==2*`MAT_DIM-2) begin
			for (int i = 0; i < `MAT_DIM; i = i + 1) begin
				for (int j = 0; j < `MAT_DIM; j = j + 1) begin
					fxptWrite(5, immL2[i][j]);
					$write(" ");
				end
				$write("\n");
			end
			enable_CP1 <= False;
			enable_CP2 <= True;
		end
	endrule

	rule cov_predict3 (enable_CP3);
		$display($time, "cov_predict3");
		for (int i=0; i<`STATE_DIM; i=i+1)
			for (int j=0; j<`STATE_DIM; j=j+1)
				pk[i][j] <= immL2[i][j] + sysQ[i][j];	
		
		enable_CP3 <= False;
		enable_KG1 <= True;
	endrule

	// kalmanGC rules
	rule kalmanGC1 (enable_KG1);
		$display($time, "kalmanGC1");
		MatType temppk = replicate(replicate(unpack(0)));
		MatType tempHT = replicate(replicate(unpack(0)));
		
		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`STATE_DIM; j=j+1) begin
				temppk[i][j] = pk[i][j];
			end 

		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`MEASUREMENT_DIM; j=j+1) begin
				tempHT[i][j] = sysH[j][i];
			end
		
		mult_mod.putAB(temppk, tempHT);
		//mult_mod.start;
	endrule

	rule store_A (enable_KG1);
		$display($time, "storeA");
		let out_stream = mult_mod.getC;
		let k = mult_mod.getk;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				if ((i<`STATE_DIM) && (k-i<`MEASUREMENT_DIM))
					immA[i][k-i] <= out_stream[i];
			end
		end

		if (k==2*`MAT_DIM-2) begin
			enable_KG1 <= False;
			enable_KG2 <= True;
		end
	endrule

	rule kalmanGC2 (enable_KG2);
		$display($time, "kalmanGC2");
		MatType tempH = replicate(replicate(unpack(0)));
		MatType tempA = replicate(replicate(unpack(0)));
		
		for(int i=0; i<`MEASUREMENT_DIM; i=i+1)
			for(int j=0; j<`STATE_DIM; j=j+1) begin
				tempH[i][j] = sysH[i][j];
			end 

		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`MEASUREMENT_DIM; j=j+1) begin
				tempA[i][j] = immA[i][j];
			end
		
		mult_mod.putAB(tempH, tempA);
		//mult_mod.start;
	endrule

	rule store_C1 (enable_KG2);
		$display($time, "store_C1");
		let out_stream = mult_mod.getC;
		let k = mult_mod.getk;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				if ((i<`MEASUREMENT_DIM) && (k-i<`MEASUREMENT_DIM))
					immC1[i][k-i] <= out_stream[i];
			end
		end

		if (k==2*`MAT_DIM-2) begin
			enable_KG2 <= False;
			enable_KG3 <= True;
		end
	endrule

	rule kalmanGC3 (enable_KG3);
		$display($time, "kalmanGC3");
		for(int i=0; i<`MEASUREMENT_DIM; i=i+1)
			for(int j=0; j<`MEASUREMENT_DIM; j=j+1)
				immC1[i][j] <= immC1[i][j]+sysR[i][j];

		enable_KG3 <= False;
		enable_KG4 <= True;
	endrule

	rule kalmanGC4 (enable_KG4);
		$display($time, "kalmanGC4");
		Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) tempC1 = defaultValue;

		for(int i=0; i<`MEASUREMENT_DIM; i=i+1)
			for(int j=0; j<`MEASUREMENT_DIM; j=j+1)
				tempC1[i][j] = immC1[i][j];
		inv_mod.put(tempC1);
		enable_KG4 <= False;
		enable_KG5 <= True;
	endrule

	rule kalmanGC5 (enable_KG5);
		$display($time, "kalmanGC5");
		if (inv_mod.isRdy) begin
			Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) tempC1 = inv_mod.get;

			for (int i=0; i<`MEASUREMENT_DIM; i=i+1)
				for(int j=0; j<`MEASUREMENT_DIM; j=j+1)
					immC1[i][j] <= tempC1[i][j];

			enable_KG5 <= False;
			enable_KG6 <= True;
		end
	endrule

	rule kalmanGC6 (enable_KG6);
		$display($time, "kalmanGC6");
		MatType tempA = replicate(replicate(unpack(0)));
		MatType tempC1 = replicate(replicate(unpack(0)));
		
		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`MEASUREMENT_DIM; j=j+1) begin
				tempA[i][j] = immA[i][j];
			end 

		for(int i=0; i<`MEASUREMENT_DIM; i=i+1)
			for(int j=0; j<`MEASUREMENT_DIM; j=j+1) begin
				tempC1[i][j] = immC1[i][j];
			end
		
		mult_mod.putAB(tempA, tempC1);
		//mult_mod.start;
	endrule

	rule store_Kk (enable_KG6);
		$display($time, "store_Kk");
		let out_stream = mult_mod.getC;
		let k = mult_mod.getk;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				if ((i<`STATE_DIM) && (k-i<`MEASUREMENT_DIM))
					kk[i][k-i] <= out_stream[i];
			end
		end

		if (k==2*`MAT_DIM-2) begin
			enable_KG6 <= False;
			enable_SU_CU <= True;
		end
	endrule 

	//  State update rules
	rule state_update1 (enable_SUa && enable_SU_CU);
		$display($time, "state_update1");
		vdot1.put_a(kk[su_cntri][su_cntrj]);
		vdot1.put_b(yk[su_cntrj]);
		enable_storeT <= True;

		if (su_cntrj == `MEASUREMENT_DIM-1) begin
			su_cntrj <= 0;
			vdot1.end_value(True);
			if (su_cntri == `STATE_DIM-1) begin
				su_cntri <= 0;
				enable_SUa <= False;
			end
			else
				su_cntri <= su_cntri+1;
		end 
		else begin
			su_cntrj <= su_cntrj+1;
			vdot1.end_value(False);
		end
	endrule

	rule store_temp (enable_storeT);
		$display($time, "store_temp");
		let temp <- vdot1.dot_result;
		xk[su2_cntr] <= xk[su2_cntr]+temp;

		if (su2_cntr == `STATE_DIM-1) begin
			su2_cntr <= 0;
			xk_ready <= True;
			enable_storeT <= False;
		end 
		else
			su2_cntr <= su2_cntr+1;
	endrule

	Reg#(Bool) enable_CU2 <- mkReg(False), enable_CU3 <- mkReg(False);

	//Cov update
	rule cov_updater (enable_SU_CU && (!enable_CU2));
		$display($time, "cov_updater");
		MatType tempkk = replicate(replicate(unpack(0)));
		MatType tempH = replicate(replicate(unpack(0)));
		
		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`MEASUREMENT_DIM; j=j+1) begin
				tempkk[i][j] = kk[i][j];
			end 

		for(int i=0; i<`MEASUREMENT_DIM; i=i+1)
			for(int j=0; j<`STATE_DIM; j=j+1) begin
				tempH[i][j] = sysH[i][j];
			end
		
		mult_mod.putAB(tempkk, tempH);
		//mult_mod.start;
	endrule

	rule store_T1 (enable_SU_CU && (!enable_CU2));
		$display($time, "store_T1");
		let out_stream = mult_mod.getC;
		let k = mult_mod.getk;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				if ((i<`STATE_DIM) && (k-i<`STATE_DIM))
					kk[i][k-i] <= out_stream[i];
			end
		end

		if (k==2*`MAT_DIM-2) begin
			enable_CU2 <= True;
		end
	endrule 

	rule disable_SU_CU ((!enable_SUa) && (enable_CU2));
		$display($time, "disable_SU_CU");
		enable_SU_CU <= False;
	endrule

	rule cov_updater2 (enable_CU2);
		$display($time, "cov_updater2");
		MatType tempT1 = replicate(replicate(unpack(0)));
		MatType temppk = replicate(replicate(unpack(0)));
		
		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`STATE_DIM; j=j+1) begin
				tempT1[i][j] = immT1[i][j];
				temppk[i][j] = pk[i][j];
			end 
		
		mult_mod.putAB(tempT1, temppk);
		//mult_mod.start;
	endrule

	rule store_T2 (enable_CU2);
		$display($time, "store_T2");
		let out_stream = mult_mod.getC;
		let k = mult_mod.getk;

		for (int i=0; i<`MAT_DIM; i=i+1) begin
			if ((k>=i) && (k-i<`MAT_DIM)) begin
				if ((i<`STATE_DIM) && (k-i<`STATE_DIM))
					immT2[i][k-i] <= out_stream[i];
			end
		end

		if (k==2*`MAT_DIM-2) begin
			enable_CU2 <= False;
			enable_CU3 <= True;
		end
	endrule 

	rule cov_updater3 (enable_CU3);
		$display($time, "cov_updater3");
		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`STATE_DIM; j=j+1)
				pk[i][j] <= pk[i][j]-immT2[i][j];
 
		enable_CU3 <= False;
		pk_ready <= True;
	endrule		


	method Action put_xk_uk (Vector#(`STATE_DIM, SysType) inp_xk, Vector#(`INPUT_DIM, SysType) inp_uk);
		$display($time, "put_xk_uk");
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			xk[i] <= inp_xk[i];
			fxptWrite(3, inp_xk[i]);
			$write(" ");
		end
		$write("\n");
		for (int i = 0; i < `INPUT_DIM; i = i + 1) begin
			uk[i] <= inp_uk[i];
			fxptWrite(3, inp_xk[i]);
			$write(" ");
		end
		$write("\n");
		
		enable_SP1a <= True;
		enable_SP1b <= True;
	endmethod

	method Action put_pk (Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) inp_pk);
		$display($time, "put_pk");
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			for (int j = 0; j < `STATE_DIM; j = j + 1) begin
				pk[i][j] <= inp_pk[i][j];
				fxptWrite(3, inp_pk[i][j]);
				$write(" ");
			end
			$write("\n");
		end
		
		enable_CP1 <= True;
	endmethod

	method Action put_zk (Vector#(`MEASUREMENT_DIM, SysType) inp_zk);
		for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
			zk[i] <= inp_zk[i];
			fxptWrite(3, inp_zk[i]);
			$write(" ");
		end
		$write("\n");
		
		zk_valid <= True;
	endmethod

	method Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) get_pk if (pk_ready);
		Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) out_pk = replicate(replicate(unpack(0)));
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			for (int j = 0; j < `STATE_DIM; j = j + 1) begin
				out_pk[i][j] = pk[i][j];
			end
		end
		return out_pk;
	endmethod
	
	method Vector#(`STATE_DIM, SysType) get_xk if (xk_ready);
		Vector#(`STATE_DIM, SysType) tmp_xk = replicate(unpack(0));
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			tmp_xk[i] = xk[i];
		end

		return tmp_xk;
	endmethod

	method Vector#(`MEASUREMENT_DIM, SysType) get_yk if (yk_ready);
		Vector#(`MEASUREMENT_DIM, SysType) tmp_yk = replicate(unpack(0));
		for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
			tmp_yk[i] = yk[i];
		end

		return tmp_yk;
	endmethod
endmodule


endpackage

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
				// pk*F.Transpose
                inp_Astream[i] = pk[i][CP_cntr-i];
                inp_Bstream[i] = F[i][CP_cntr-i];
			end 
		end

		mult_mod.feed_inp_stream(inp_Astream, inp_Bstream);
	endrule
	int k = CP_cntr - i - `MAT_DIM - 7;*/
        // for(int i=0; i<`MAT_DIM; i=i+1) begin
        //     if ((CP_cntr-i < `MAT_DIM) &&(i<=CP_cntr)) begin
		// 		// F*L1
        //         inp_Astream[i] = F[i][CP_cntr-i];
        //         inp_Bstream[i] = L1[CP_cntr-i][i];
		// 	end 
		// end

		// mult_mod.feed_inp_stream(inp_Astream, inp_Bstream); 
