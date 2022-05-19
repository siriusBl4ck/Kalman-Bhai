package top_module;

`include "types.bsv"

// import vector_dot::*;
// import total_mat_inv::*;
// import mat_mult_systolic::*;

interface Ifc_top_module;
    method Action put_xk_uk (Vector#(`STATE_DIM, SysType) inp_xk, Vector#(`INPUT_DIM, SysType) inp_uk);

	method Action put_pk (Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) inp_pk);

	method Action put_zk (Vector#(`MEASUREMENT_DIM, SysType) inp_zk);

	method Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) get_pk();
	
	method Vector#(`STATE_DIM, SysType) get_xk();

	method Vector#(`MEASUREMENT_DIM, SysType) get_yk();

    method Bool xk_Rdy();

    method Bool pk_Rdy();
endinterface

(*synthesize*)
module mk_top_module(Ifc_top_module);
    // inputs and parameters for kalman
    Reg#(Vector#(`STATE_DIM, SysType)) xk <- mkReg(replicate(unpack(0)));
    Reg#(Vector#(`INPUT_DIM, SysType)) uk <- mkReg(replicate(unpack(0)));
    Reg#(Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType))) pk <- mkReg(replicate(replicate(unpack(0))));
    Reg#(Vector#(`MEASUREMENT_DIM, SysType)) zk <- mkReg(replicate(unpack(0)));
    Reg#(Vector#(`MEASUREMENT_DIM, SysType)) yk <- mkReg(replicate(unpack(0)));

    // the ready signals for inputs and outputs
    Wire#(Bool) inp_xk_uk_rdy <- mkReg(False);
    Wire#(Bool) inp_pk_rdy <- mkReg(False);
    Wire#(Bool) inp_zk_rdy <- mkReg(False);

    Reg#(Bool) out_xk_rdy <- mkReg(False);
    Reg#(Bool) out_pk_rdy <- mkReg(False);

    // compute submodules
    // VectorDot_ifc#(SysType) vdot1 <- mkVectorDot;
    // VectorDot_ifc#(SysType) vdot2 <- mkVectorDot;

	// Ifc_mat_imm mat_multiplier <- mkmat_imm;

	// Ifc_mat_inv mat_inverter <- mk_mat_inv;

    // enables, counters and intermediate variables for various stages
    //sp1a
    Reg#(Bool) en_sp1a <- mkReg(False);
    //storeM
    Reg#(Bool) en_storeM <- mkReg(False);
    Reg#(int) storeM_cntr <- mkReg(0);
    Reg#(Vector#(`STATE_DIM, SysType)) immM <- mkReg(replicate(unpack(0)));

    // counters for feeding the systole in vdot modules
    Reg#(int) vdot1_counter_i <- mkReg(0);
    Reg#(int) vdot1_counter_j <- mkReg(0);

    Reg#(int) vdot2_counter_i <- mkReg(0);
    Reg#(int) vdot2_counter_j <- mkReg(0);

    //scheduling conflict resolution
    

    //rules

    rule rl_debug;
        // if (inp_xk_uk_rdy && inp_pk_rdy && inp_zk_rdy) begin
        //     $display("Yay we're all set!");

        //     $display("xk");
        //     for (int i = 0; i < `STATE_DIM; i = i + 1) begin
        //         fxptWrite(3, xk[i]);
        //         $write("  ");
        //     end
        //     $write("\n");

        //     $display("uk");
        //     for (int i = 0; i < `INPUT_DIM; i = i + 1) begin
        //         fxptWrite(3, uk[i]);
        //         $write("  ");
        //     end
        //     $write("\n");

        //     $display("zk");
        //     for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
        //         fxptWrite(3, zk[i]);
        //         $write("  ");
        //     end
        //     $write("\n");

        //     $display("pk");
        //     for (int i = 0; i < `STATE_DIM; i = i + 1) begin
        //         for (int j = 0; j < `STATE_DIM; j = j + 1) begin
        //             fxptWrite(3, pk[i][j]);
        //             $write("  ");
        //         end
        //         $write("\n");
        //     end
        //     // out_xk_rdy <= True;
        //     // out_pk_rdy <= True;
        // end
    endrule

    rule rl_sp1a (en_sp1a);
        // if (en_sp1a) begin
        //     $display($time, " [sp1a]");
            // vdot1.put_a(sysF[vdot1_counter_i][vdot1_counter_j]);
            // vdot1.put_b(xk[vdot1_counter_j]);
        //     en_storeM <= True;

            if (vdot1_counter_j == `STATE_DIM - 1) begin
                vdot1_counter_j <= 0;
                vdot1.end_value(True);
                if (vdot1_counter_i == `STATE_DIM - 1) begin
                    vdot1_counter_i <= 0;
                end
                else begin
                    vdot1_counter_i <= vdot1_counter_i + 1;
                end
            end 
            else begin
                vdot1_counter_j <= vdot1_counter_j + 1;
                vdot1.end_value(False);
            end
        // end
        // else en_storeM <= False;

        $display("working\n");

        if (en_sp1a) begin
            vdot1.put_a(sysF[vdot1_counter_i][vdot1_counter_j]);
            vdot1.put_b(xk[vdot1_counter_j]);
            en_storeM <= True;

            if (vdot1_counter_j == `STATE_DIM - 1) begin
                vdot1_counter_j <= 0;
                vdot1.end_value(True);
                if (vdot1_counter_i == `STATE_DIM - 1) begin
                    vdot1_counter_i <= 0;
                    en_sp1a <= False;
                end
                else begin
                    vdot1_counter_i <= vdot1_counter_i + 1;
                end
            end 
            else begin
                vdot1_counter_j <= vdot1_counter_j + 1;
                vdot1.end_value(False);
            end
        end
    endrule

    rule rl_storeM (en_storeM);
        // if (en_storeM) begin
        //     $display($time, " [storeM]");
        //     let za <- vdot1.dot_result;
        //     let tmp_M = immM;
        //     tmp_M[storeM_cntr] = za;
        //     immM <= tmp_M;
            
        //     if (storeM_cntr == `STATE_DIM-1) begin
        //         // en_sp1a <= False;
        //         // storeM_cntr <= 0;
        //         //enable_sp2a <= True;
        //         // en_storeM <= False;

        //         $display("storeM complete");
        //         for (int i = 0; i < `STATE_DIM; i = i + 1) begin
        //             fxptWrite(3, immM[i]);
        //             $write("   ");
        //         end
        //         $write("\n");
        //         $finish();
        //     end
        //     else storeM_cntr <= storeM_cntr + 1;
        // end

        if (en_storeM) begin
            vdot1_counter_i <= vdot1_counter_i + 1;

            
        end
	endrule

    method Action put_xk_uk (Vector#(`STATE_DIM, SysType) inp_xk, Vector#(`INPUT_DIM, SysType) inp_uk) if (!en_sp1a);
        $display("putting\n");
        xk <= inp_xk;
        uk <= inp_uk;
        inp_xk_uk_rdy <= True;
        en_sp1a <=  True;
    endmethod

	method Action put_pk (Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) inp_pk);
        pk <= inp_pk;
        inp_pk_rdy <= True;
    endmethod

	method Action put_zk (Vector#(`MEASUREMENT_DIM, SysType) inp_zk);
        zk <= inp_zk;
        inp_zk_rdy <= True;
    endmethod

	method Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) get_pk();
        return pk;
    endmethod
	
	method Vector#(`STATE_DIM, SysType) get_xk();
        return xk;
    endmethod

	method Vector#(`MEASUREMENT_DIM, SysType) get_yk();
        return yk;
    endmethod

    method Bool xk_Rdy();
        return out_xk_rdy;
    endmethod

    method Bool pk_Rdy();
        return out_pk_rdy;
    endmethod
endmodule

endpackage