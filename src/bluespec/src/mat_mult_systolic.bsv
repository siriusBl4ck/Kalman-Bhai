package mat_mult_systolic;
`include "params.bsv"
`include "types.bsv"

import pe::*;
import FixedPoint::*;

interface Ifc_mat_mult_systolic;
    method Action feed_inp_stream(VecType a_stream, VecType b_stream);
    method MatType get_out_stream();
endinterface

(* synthesize *)
module mat_mult_systolic(Ifc_mat_mult_systolic);
    Ifc_pe pe[`MAT_DIM][`MAT_DIM];
    Wire#(SysType) wr_inp_a[`MAT_DIM];
    Wire#(SysType) wr_inp_b[`MAT_DIM];
    Reg#(SysType) rg_inp_a[`MAT_DIM];
    Reg#(SysType) rg_inp_b[`MAT_DIM];

    //pipe registers
    Reg#(Bit#(1)) rg_stage0_rdy <- mkReg(0);

    for (int i = 0; i < `MAT_DIM; i = i + 1) begin
        for (int j = 0; j < `MAT_DIM; j = j + 1) begin
            pe[i][j] <- mk_pe;
        end
    end

    for (int i = 0; i < `MAT_DIM; i = i + 1) begin
        wr_inp_a[i] <- mkDWire(unpack(0));
        wr_inp_b[i] <- mkDWire(unpack(0));
    end

    for (int i = 0; i < `MAT_DIM; i = i + 1) begin
        rg_inp_a[i] <- mkReg(unpack(0));
        rg_inp_b[i] <- mkReg(unpack(0));
    end

    Wire#(Bit#(1)) wr_inp_rdy <- mkDWire(0);

    rule stage0_latch;
        if (wr_inp_rdy == 1'b1) begin
            for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                $display($time, " [MULT] [stage0] latching A[%d] ", i);
                fxptWrite(5, wr_inp_a[i]);
                $display("\n");
                $display($time, " [MULT] [stage0] latching B[%d] ", i);
                fxptWrite(5, wr_inp_b[i]);
                $display("\n");
                rg_inp_a[i] <= wr_inp_a[i];
                rg_inp_b[i] <= wr_inp_b[i];
            end

            rg_stage0_rdy <= 1'b1;
        end
        else rg_stage0_rdy <= 1'b0;
    endrule

    rule stage1_systole;
        SysType lv_pe_a[`MAT_DIM][`MAT_DIM];
        SysType lv_pe_b[`MAT_DIM][`MAT_DIM];

        if (rg_stage0_rdy == 1'b1) begin
            // feed the new inputs to the systolic array
            for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                lv_pe_a[i][0] = rg_inp_a[i];
                lv_pe_b[0][i] = rg_inp_b[i];

                if (i != 0) begin
                    lv_pe_b[i][0] = pe[i - 1][0].getB();
                    lv_pe_a[0][i] = pe[0][i - 1].getA();
                end
            end

            for (int i = 1; i < `MAT_DIM; i = i + 1) begin
                for (int j = 1; j < `MAT_DIM; j= j + 1) begin
                    lv_pe_a[i][j] = pe[i][j - 1].getA();
                    lv_pe_b[i][j] = pe[i - 1][j].getB();
                end
            end

            //propagate the systolic array
            for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                for (int j = 0; j < `MAT_DIM; j= j + 1) begin
                    pe[i][j].putA(lv_pe_a[i][j]);
                    pe[i][j].putB(lv_pe_b[i][j]);
                end
            end
        end
    endrule

    method Action feed_inp_stream(VecType a_stream, VecType b_stream);
        $display($time, " [MULT] method feed_inp_stream reached");
        for (int i = 0; i < `MAT_DIM; i = i + 1) begin
            wr_inp_a[i] <= unpack(a_stream[(i+1) * `INP_LEN - 1 : i * `INP_LEN]);
        end

        for (int j = 0; j < `MAT_DIM; j = j + 1) begin
            wr_inp_b[j] <= unpack(b_stream[(j+1) * `INP_LEN - 1 : j * `INP_LEN]);
        end

        wr_inp_rdy <= 1'b1;
    endmethod

    method MatType get_out_stream();
        MatType out_stream = 0;
        for (int i = 0; i < `MAT_DIM; i = i + 1) begin
            for (int j = 0; j < `MAT_DIM; j = j + 1) begin
                out_stream[((i * `MAT_DIM + j + 1) * `INP_LEN - 1) : ((i * `MAT_DIM + j) * `INP_LEN)] = pack(pe[i][j].getC());
            end
        end
        return out_stream;
    endmethod
endmodule

endpackage