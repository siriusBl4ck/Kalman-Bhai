package KalmanAlgo;

`include "types.bsv"

import vector_dot::*;
import total_mat_inv::*;
import mat_mult_systolic::*;
import FixedPoint::*;
import ConfigReg::*;

interface Kalman_Ifc;
	method Action put_xk_uk (Vector#(`STATE_DIM, SysType) inp_xk, Vector#(`INPUT_DIM, SysType) inp_uk);

	method Action put_pk (Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) inp_pk);

	method Action put_zk (Vector#(`MEASUREMENT_DIM, SysType) inp_zk);

	method Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) get_pk();
	
	method Vector#(`STATE_DIM, SysType) get_xk();

	method Vector#(`MEASUREMENT_DIM, SysType) get_yk();

	method Bool is_pk_rdy();

	method Bool is_xk_rdy();

	method Bool is_yk_rdy();
endinterface

(*synthesize*)
module mkKalman(Kalman_Ifc);
	// system params
	Vector#(`STATE_DIM, Vector#(`INPUT_DIM, SysType)) sysB = replicate(replicate(0));
	Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) sysF = replicate(replicate(0));

	Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) sysR = replicate(replicate(0));

	Vector#(`MEASUREMENT_DIM, Vector#(`STATE_DIM, SysType)) sysH = replicate(replicate(0));


	Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) sysQ = replicate(replicate(0));

	sysF[0][0] = fromRational(1, 1);
	sysF[0][1] = fromRational(1, 1);
	sysF[0][2] = fromRational(1, 2);
	sysF[1][1] = fromRational(1, 1);
	sysF[1][2] = fromRational(1, 1);
	sysF[2][2] = fromRational(1, 1);
	sysF[3][3] = fromRational(1, 1);
	sysF[3][4] = fromRational(1, 1);
	sysF[3][5] = fromRational(1, 2);
	sysF[4][4] = fromRational(1, 1);
	sysF[4][5] = fromRational(1, 1);
	sysF[5][5] = fromRational(1, 1);

	sysH[0][0] = fromRational(1, 1);
	sysH[1][1] = fromRational(1, 1);


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

	sysR[0][0] = fromRational(1, 1);
	sysR[1][1] = fromRational(1, 1);


	
	// To put a constraint on resources only 2 vector dot modules are needed
	VectorDot_ifc vdot1 <- mkVectorDot, vdot2 <- mkVectorDot, vdot3 <- mkVectorDot;
	//Ifc_mat_mult_systolic mult_mod <- mat_mult_systolic;
	Ifc_mat_imm mult_mod <- mkmat_imm;
	Ifc_mat_inv inv_mod <- mk_mat_inv;

	VecTypeSD xk <- replicateM(mkReg(defaultValue));
	VecTypeSD next_xk <- replicateM(mkReg(defaultValue));
	VecTypeMD yk <- replicateM(mkReg(defaultValue));
	VecTypeMD zk <- replicateM(mkReg(defaultValue));
	VecTypeID uk <- replicateM(mkReg(defaultValue));
	MatTypeSD pk <- replicateM(replicateM(mkReg(defaultValue)));

	Reg#(Bool) xk_ready <- mkReg(False), yk_ready <- mkReg(False), pk_ready <- mkReg(False);

	// counter (cntr) can be reduced easily and only 6 are needed

	//State predictor vars
	VecTypeSD immM <- replicateM(mkReg(defaultValue)), immN <- replicateM(mkReg(defaultValue));
	Reg#(int) sp1a_cntri <- mkReg(0), sp1a_cntrj <- mkReg(0), sp1b_cntri <- mkReg(0), sp1b_cntrj <- mkReg(0), sp2a_cntr <- mkReg(0), sp2b_cntr <- mkReg(0); /// to be reduced
	
	Reg#(Bool) enable_SP1a <- mkReg(False), enable_storeM <- mkConfigReg(False), enable_SP1b <- mkReg(False), enable_storeN <- mkReg(False);
	Reg#(Bool) enable_sp2a <- mkReg(False), enable_sp2b <- mkReg(False);
	Reg#(Bool) enable_storeL1 <- mkReg(False);

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
	Reg#(Bool) enable_storeL2 <- mkReg(False);

	// Kalman Gain Calculator vars
	Reg#(Bool) enable_KG1 <- mkReg(False), enable_KG2 <- mkReg(False), enable_KG3 <- mkReg(False), enable_KG4 <- mkReg(False), enable_KG5 <- mkReg(False), enable_KG6 <- mkReg(False), enable_SU_CU <- mkReg(False);
	Vector#(`STATE_DIM, Vector#(`MEASUREMENT_DIM, Reg#(SysType))) immA <- replicateM(replicateM(mkReg(0)));
	Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, Reg#(SysType))) immC1 <- replicateM(replicateM(mkReg(0)));
	Vector#(`STATE_DIM, Vector#(`MEASUREMENT_DIM, Reg#(SysType))) kk <- replicateM(replicateM(mkReg(0)));
	Reg#(Bool) enable_store_A <- mkReg(False);
	Reg#(Bool) enable_store_C1 <- mkReg(False);
	Reg#(Bool) enable_store_Kk <- mkReg(False);

	//State update vars
	Reg#(int) su_cntri <- mkReg(0), su_cntrj <- mkReg(0), su2_cntr <- mkReg(0);
	Reg#(Bool) enable_storeT <- mkReg(False);
	Reg#(Bool) enable_store_T1 <- mkReg(False);
	Reg#(Bool) enable_store_T2 <- mkReg(False);

	Reg#(Bool) enable_CU2 <- mkReg(False), enable_CU3 <- mkReg(False);

	//Cov update vars
	MatTypeSD immT1 <- replicateM(replicateM(mkReg(0))), immT2 <- replicateM(replicateM(mkReg(0)));

	Reg#(Bool) mul_rst <- mkReg(False);


	Reg#(Bool) inp_xk_uk_rdy <- mkReg(False);
	Reg#(Bool) inp_pk_rdy <- mkReg(False);
	Reg#(Bool) inp_zk_rdy <- mkReg(False);

	// State Predictor (SP) rules
	// This rule is using vector dot product module to compute for matrix*vector

	(*conflict_free = "state_predictor1a, store_M, state_predictor1b, store_N"*) //, measurement_residual1"*)
	// (*conflict_free = "store_M, store_E"*)

	// (*mutually_exclusive="cov_predict1, cov_predict3, cov_updater2"*)
	// (*mutually_exclusive="kalmanGC1, kalmanGC2, kalmanGC3, kalmanGC4, kalmanGC5,  kalmanGC6"*)
	// (*mutually_exclusive="cov_updater2, cov_updater3, cov_predict1, cov_predict3"*)
	
	rule state_predictor1a (enable_SP1a);
		$display($time, "state_predictor1a");
		$write("sysF[%d][%d] ", sp1a_cntri, sp1a_cntrj);
		fxptWrite(3, sysF[sp1a_cntri][sp1a_cntrj]);
		$write("  x[%d] ", sp1a_cntrj);
		fxptWrite(3, xk[sp1a_cntrj]);
		$write("\n");
		vdot1.put_a(sysF[sp1a_cntri][sp1a_cntrj]);
		vdot1.put_b(xk[sp1a_cntrj]);
		enable_storeM <= True;

		if (sp1a_cntrj == `STATE_DIM-1) begin
			sp1a_cntrj <= 0;
			vdot1.end_value(True);
			if (sp1a_cntri == `STATE_DIM-1) begin
				sp1a_cntri <= 0;
				enable_SP1a <= False;
				$display($time, "completed passing for M");
			end 
			else
				sp1a_cntri <= sp1a_cntri+1;
		end 
		else begin
			sp1a_cntrj <= sp1a_cntrj+1;
			vdot1.end_value(False);
		end 
	endrule

	rule store_M (enable_storeM && (!enable_sp2a));
		$display($time, "storeM %d", sp2a_cntr);
		let za <- vdot1.dot_result;
		$write("za ");
		fxptWrite(3, za);
		$write("\n");
		immM[sp2a_cntr] <= za;
		
		if (sp2a_cntr == `STATE_DIM-1) begin
			sp2a_cntr <= 0;
			enable_sp2a <= True;
			enable_storeM <= False;
			$display($time, "StoreM completed\n");
			for (int i = 0; i < `STATE_DIM; i = i + 1) begin
				fxptWrite(3, immM[i]);
				$write(" ");
			end
			$write("\n");
		end
		else
			sp2a_cntr <= sp2a_cntr+1;
	endrule

	rule state_predictor1b (enable_SP1b);
		$display($time, "state_predictor1b");
		$write("sysB[%d][%d] ", sp1b_cntri, sp1b_cntrj);
		fxptWrite(3, sysB[sp1b_cntri][sp1b_cntrj]);
		$write("  ");
		$write("uk[%d] ", sp1b_cntrj);
		fxptWrite(3, uk[sp1b_cntrj]);
		$write("\n");
		vdot2.put_a(sysB[sp1b_cntri][sp1b_cntrj]);
		vdot2.put_b(uk[sp1b_cntrj]);
		enable_storeN <= True;

		if (sp1b_cntrj == `INPUT_DIM-1) begin
			sp1b_cntrj <= 0;
			vdot2.end_value(True);
			if (sp1b_cntri == `STATE_DIM-1) begin
				sp1b_cntri <= 0;
				enable_SP1b <= False;
				$display($time, "completed passing for N");
			end 
			else
				sp1b_cntri <= sp1b_cntri+1;
		end 
		else begin
			sp1b_cntrj <= sp1b_cntrj+1;
			vdot2.end_value(False);
		end 
	endrule
	
	rule store_N (enable_storeN && (!enable_sp2b));
		$display($time, "storeN %d", sp2b_cntr);
		let zb <- vdot2.dot_result;
		immN[sp2b_cntr] <= zb;
		$write("zb ");
		fxptWrite(3, zb);
		$write("\n");
		
		if (sp2b_cntr == `STATE_DIM-1) begin
			sp2b_cntr <= 0;
			enable_sp2b <= True;
			enable_sp2a <= True;
			enable_storeN <= False;
			$display($time, "Completed storeN\n");
			for (int i = 0; i < `STATE_DIM; i = i + 1) begin
				fxptWrite(3, immN[i]);
				$write(" ");
			end
			$write("\n");
		end
		else
			sp2b_cntr <= sp2b_cntr+1;
	endrule

	rule state_predictor2 (enable_sp2a && enable_sp2b);
		$display($time, "state_predictor2");
		for (int i=0; i<`STATE_DIM; i=i+1)
			xk[i] <= fxptTruncate(fxptAdd(immM[i], immN[i]));

		enable_sp2a <= False;
		enable_sp2b <= False;
		enable_MR1 <= True;
	endrule


	// Measurement Residual rules
	(*mutually_exclusive="measurement_residual1, state_predictor1a"*)
	(*conflict_free="measurement_residual1, store_E"*)
	rule measurement_residual1 (enable_MR1);
		$display($time, "measurement_residual1");
		vdot1.put_a(sysH[mr1_cntri][mr1_cntrj]);
		vdot1.put_b(xk[mr1_cntrj]);
		enable_storeE <= True;

		if (mr1_cntrj == `STATE_DIM-1) begin
			mr1_cntrj <= 0;
			vdot1.end_value(True);
			if (mr1_cntri == `MEASUREMENT_DIM-1) begin
				$display("measurement residual sent");
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
			mr2_cntr <= 0;
			enable_MR2 <= True;
			enable_storeE <= False;
		end 
		else
			mr2_cntr <= mr2_cntr+1;
	endrule

	rule measurement_residual2 (enable_MR2 && zk_valid);
		$display($time, "measurement_residual2");
		for (int i=0; i<`MEASUREMENT_DIM; i=i+1)
			yk[i] <= zk[i] - immE[i];
		
		enable_MR2 <= False;
		enable_SUa <= True;
		yk_ready <= True;
		// xk_ready <= True;
	endrule
	

	//Cov predictor Rules
	//REPLICATE THIS
	(*conflict_free = "cov_predict1, store_L1"*)
	rule cov_predict1 (enable_CP1);
		$display($time, "cov_predict1");
		if (!mul_rst) begin
			mult_mod.reset_systole();
			mul_rst <= True;
		end
		else begin
			MatType tempF = replicate(replicate(unpack(0)));
			MatType temppk = replicate(replicate(unpack(0)));
			
			for(int i=0; i<`STATE_DIM; i=i+1)
				for(int j=0; j<`STATE_DIM; j=j+1) begin
					tempF[i][j] = sysF[j][i];
					temppk[i][j] = pk[i][j];
				end

			mult_mod.putAB(temppk, tempF);

			enable_CP1 <= False;
			enable_storeL1 <= True;
			//mult_mod.start;
			mul_rst <= False;
		end
	endrule

	(*descending_urgency = "mult_mod_cntr, store_L1"*)
	rule store_L1 (enable_storeL1);
		if (mult_mod.is_out_rdy()) begin
			$display($time, "store_L1");
			MatType out_stream <- mult_mod.getC();

			for (int i=0; i<`STATE_DIM; i=i+1) begin
				for (int j = 0; j < `STATE_DIM; j=j+1) begin
					immL1[i][j] <= out_stream[i][j];
					fxptWrite(3, out_stream[i][j]);
					$write("  ");
				end
				$write("\n");
			end
			
			enable_storeL1 <= False;
			enable_CP2 <= True;
		end
	endrule
	
	rule cov_predict2 (enable_CP2);
		$display($time, "cov_predict2");
		if (!mul_rst) begin
			mult_mod.reset_systole();
			mul_rst <= True;
		end
		else begin
			//VecType inp_Astream = replicate(0), inp_Bstream = replicate(0);
			MatType tempF = replicate(replicate(unpack(0)));
			MatType tempL1 = replicate(replicate(unpack(0)));
			
			for(int i=0; i<`STATE_DIM; i=i+1)
				for(int j=0; j<`STATE_DIM; j=j+1) begin
					tempF[i][j] = sysF[i][j];
					tempL1[i][j] = immL1[i][j];
				end
			
			mult_mod.putAB(tempF, tempL1);

			enable_CP2 <= False;
			enable_storeL2 <= True;
			//mult_mod.start;
			mul_rst <= False;
		end
	endrule

	rule store_L2 (enable_storeL2);
		if (mult_mod.is_out_rdy()) begin
			$display($time, "store_L2");
			MatType out_stream <- mult_mod.getC();

			for (int i = 0; i < `STATE_DIM; i = i + 1) begin
				for (int j = 0; j < `STATE_DIM; j = j + 1) begin
					immL2[i][j] <= out_stream[i][j];
					fxptWrite(3, out_stream[i][j]);
					$write("  ");
				end
				$write("\n");
			end
			
			enable_storeL2 <= False;
			enable_CP3 <= True;
		end
	endrule

	rule cov_predict3 (enable_CP3 && !enable_CP1 && !enable_storeL2);
		$display($time, "cov_predict3");
		for (int i=0; i<`STATE_DIM; i=i+1) begin
			for (int j=0; j<`STATE_DIM; j=j+1) begin
				SysType p = fxptTruncate(fxptAdd(immL2[i][j], sysQ[i][j]));
				pk[i][j] <= p;
				fxptWrite(5, p);
				$write("  ");
			end
			$write("\n");
		end	
		
		enable_CP3 <= False;
		enable_KG1 <= True;
	endrule
	
	// // // kalmanGC rules
	rule kalmanGC1 (enable_KG1);
		$display($time, "kalmanGC1");
		if (!mul_rst) begin
		mult_mod.reset_systole();
		mul_rst <= True;
		end
		else begin
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

		enable_KG1 <= False;
		enable_store_A <= True;
		//mult_mod.start;
		mul_rst <= False;
		end
	endrule

	rule store_A (enable_store_A);
		if (mult_mod.is_out_rdy()) begin
			$display($time, "storeA");
			MatType out_stream <- mult_mod.getC();

			for (int i=0; i<`STATE_DIM; i=i+1) begin
				for(int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
					immA[i][j] <= out_stream[i][j];
					fxptWrite(5, out_stream[i][j]);
					$write("  ");
				end
				$write("\n");
			end

			enable_store_A <= False;
			enable_KG2 <= True;
		end
	endrule

	rule kalmanGC2 (enable_KG2);
		$display($time, "kalmanGC2");
		if (!mul_rst) begin
		mult_mod.reset_systole();
		mul_rst <= True;
		end
		else begin
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

		enable_KG2 <= False;
		enable_store_C1 <= True;
		//mult_mod.start;
		mul_rst <= False;
		end
	endrule

	rule store_C1 (enable_store_C1);
		if (mult_mod.is_out_rdy()) begin
			$display($time, "store_C1");
			if (mult_mod.is_out_rdy()) begin
				MatType out_stream <- mult_mod.getC();

				for (int i=0; i<`MEASUREMENT_DIM; i=i+1) begin
					for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
						immC1[i][j] <= out_stream[i][j];
						fxptWrite(5, out_stream[i][j]);
						$write("  ");
					end
					$write("\n");
				end
				
				enable_store_C1 <= False;
				enable_KG3 <= True;
			end
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

	rule kalmanGC6 (enable_KG6 && !enable_KG3 && !enable_store_C1);
		$display($time, "kalmanGC6");
		if (!mul_rst) begin
		mult_mod.reset_systole();
		mul_rst <= True;
		end
		else begin
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

		enable_KG6 <= False;
		enable_store_Kk <= True;
		//mult_mod.start;
		mul_rst <= False;
		end
	endrule

	rule store_Kk (enable_store_Kk);
		if (mult_mod.is_out_rdy()) begin
			$display($time, "store_Kk");
			MatType out_stream <- mult_mod.getC();

			for (int i=0; i<`STATE_DIM; i=i+1) begin
				for (int j = 0; j < `MEASUREMENT_DIM; j=j+1) begin
					kk[i][j] <= out_stream[i][j];
				end
			end
			
			enable_store_Kk <= False;
			enable_SU_CU <= True;
		end
	endrule

	// // // //  State update rules
	// (*mutually_exclusive="state_update1, measurement_residual1, measurement_residual2, store_temp, store_E"*)
	// rule state_update1 (enable_SUa && enable_SU_CU && !enable_storeE && !enable_MR1 && !enable_MR2);
	// (*descending_urgency = "measurement_residual1, measurement_residual2, state_update1"*)
	rule state_update1 (enable_SU_CU && enable_SUa);
		$display($time, "state_update1");
		
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			SysType x = 0;
			for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
				let p = fxptMult(kk[i][j], yk[j]);
				SysType p1 = fxptTruncate(p);
				let s = fxptAdd(x, p1);
				x = fxptTruncate(s);
			end
			next_xk[i] <= x;
			fxptWrite(5, x);
			$write(" ");
		end
		$write("\n");

		xk_ready <= True;

		

		// vdot3.put_a(kk[su_cntri][su_cntrj]);
		// vdot3.put_b(yk[su_cntrj]);
		// enable_storeT <= True;

		// if (su_cntrj == `MEASUREMENT_DIM-1) begin
		// 	su_cntrj <= 0;
		// 	vdot3.end_value(True);
		// 	if (su_cntri == `STATE_DIM-1) begin
		// 		su_cntri <= 0;
		// 		// enable_SU_CU <= False;
		// 		enable_SUa <= False;
		// 	end
		// 	else
		// 		su_cntri <= su_cntri+1;
		// end 
		// else begin
		// 	su_cntrj <= su_cntrj+1;
		// 	vdot3.end_value(False);
		// end
	endrule

	// rule store_temp (enable_storeT);
	// 	$display($time, "store_temp");
	// 	let temp <- vdot3.dot_result;
	// 	fxptWrite(3, temp);
	// 	$write("\n");
	// 	let x = fxptAdd(xk[su2_cntr], temp);
	// 	xk[su2_cntr] <= fxptTruncate(x);

	// 	if (su2_cntr == `STATE_DIM-1) begin
	// 		su2_cntr <= 0;
	// 		xk_ready <= True;
	// 		enable_storeT <= False;
	// 	end 
	// 	else
	// 		su2_cntr <= su2_cntr+1;
	// endrule

	// //Cov update
	rule cov_updater (enable_SU_CU);
		$display($time, "cov_updater");
		if (!mul_rst) begin
		mult_mod.reset_systole();
		mul_rst <= True;
		end
		else begin
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

		enable_SU_CU <= False;
		enable_store_T1 <= True;
		//mult_mod.start;
		mul_rst <= False;
		end
	endrule

	rule store_T1 (enable_store_T1);
		if (mult_mod.is_out_rdy()) begin
			$display($time, "store_T1");
			MatType out_stream <- mult_mod.getC();

			for (int i=0; i<`STATE_DIM; i=i+1) begin
				for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
					kk[i][j] <= out_stream[i][j];
				end
			end

			enable_store_T1 <= False;
			enable_CU2 <= True;
		end
	endrule
	
	rule cov_updater2 (enable_CU2);
		$display($time, "cov_updater2");
		if (!mul_rst) begin
			mult_mod.reset_systole();
			mul_rst <= True;
		end
		else begin
		MatType tempT1 = replicate(replicate(unpack(0)));
		MatType temppk = replicate(replicate(unpack(0)));
		
		for(int i=0; i<`STATE_DIM; i=i+1)
			for(int j=0; j<`STATE_DIM; j=j+1) begin
				tempT1[i][j] = immT1[i][j];
				temppk[i][j] = pk[i][j];
			end 
		
		mult_mod.putAB(tempT1, temppk);
		enable_CU2 <= False;
		enable_store_T2 <= True;
		//mult_mod.start;
		mul_rst <= False;
		end
	endrule

	rule store_T2 (enable_store_T2);
		if (mult_mod.is_out_rdy()) begin
			$display($time, "store_T2");
			MatType out_stream <- mult_mod.getC();

			for (int i=0; i<`STATE_DIM; i=i+1) begin
				for (int j=0; j < `STATE_DIM; j=j+1) begin
					immT2[i][j] <= out_stream[i][j];
				end
			end

			enable_store_T2 <= False;
			enable_CU3 <= True;
		end
	endrule

	rule cov_updater3 (enable_CU3 && !enable_CP1 && !enable_CU2);
		$display($time, "cov_updater3");
		for(int i=0; i<`STATE_DIM; i=i+1) begin
			for(int j=0; j<`STATE_DIM; j=j+1) begin
				let p = fxptSub(pk[i][j], immT2[i][j]);
				pk[i][j] <= fxptTruncate(p);
				fxptWrite(5, p);
				$write(" ");
			end
			$write("\n");
		end
 
		enable_CU3 <= False;
		pk_ready <= True;
	endrule


	method Action put_xk_uk (Vector#(`STATE_DIM, SysType) inp_xk, Vector#(`INPUT_DIM, SysType) inp_uk) if ((!enable_SP1a) && (!enable_SP1b) && !inp_xk_uk_rdy);
		$display($time, "put_xk_uk");
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			xk[i] <= inp_xk[i];
			fxptWrite(3, inp_xk[i]);
			$write(" ");
		end
		for (int i = 0; i < `INPUT_DIM; i = i + 1) begin
			uk[i] <= inp_uk[i];
			fxptWrite(3, inp_xk[i]);
			$write(" ");
		end

		$display("sysF");
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			for (int j = 0; j < `STATE_DIM; j = j + 1) begin
				fxptWrite(3, sysF[i][j]);
				$write(" ");
			end
			$write("\n");
		end
		inp_xk_uk_rdy <= True;
		enable_SP1a <= True;
		enable_SP1b <= True;
	endmethod

	method Action put_pk (Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) inp_pk) if (!enable_CP1 && !inp_pk_rdy);
		$display($time, "put_pk");
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			for (int j = 0; j < `STATE_DIM; j = j + 1) begin
				pk[i][j] <= inp_pk[i][j];
			end
		end
		inp_pk_rdy <= True;
		enable_CP1 <= True;
	endmethod

	method Action put_zk (Vector#(`MEASUREMENT_DIM, SysType) inp_zk) if (!inp_zk_rdy);
		$display("put_zk");
		for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
			fxptWrite(3, inp_zk[i]);
			$write(" ");
			zk[i] <= inp_zk[i];
		end
		
		inp_zk_rdy <= True;
		zk_valid <= True;
	endmethod

	method Bool is_pk_rdy();
		return pk_ready;
	endmethod

	method Bool is_xk_rdy();
		return xk_ready;
	endmethod

	method Bool is_yk_rdy();
		return yk_ready;
	endmethod

	method Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) get_pk;
		Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) out_pk = replicate(replicate(unpack(0)));
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			for (int j = 0; j < `STATE_DIM; j = j + 1) begin
				out_pk[i][j] = pk[i][j];
			end
		end
		return out_pk;
	endmethod
	
	method Vector#(`STATE_DIM, SysType) get_xk;
		Vector#(`STATE_DIM, SysType) tmp_xk = replicate(unpack(0));
		for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			tmp_xk[i] = next_xk[i];
		end

		return tmp_xk;
	endmethod

	method Vector#(`MEASUREMENT_DIM, SysType) get_yk;
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
