package mat_imm;

`include "types.bsv"
 

import FixedPoint::*;
import mat_mult_systolic::*;

interface Ifc_mat_imm;
    method Action putAB (MatType inpA, MatType inpB);
    method Action start;
    method VecType getC;
    method int getk;
endinterface

(* synthesize *)
module mk_mat_imm(Ifc_mat_imm);
    Ifc_mat_mult_systolic myMult <- mat_mult_systolic;
    
    Reg#(VecType) inp_Astream <- mkReg(unpack(0));
    Reg#(VecType) inp_Bstream <- mkReg(unpack(0));
    Reg#(VecType) out_stream <- mkReg(unpack(0));
    Reg#(int) rg_cntr <- mkReg(0);
    Wire#(Bool) inp_rdy <- mkDWire(False), out_rdy <- mkDWire(False);

    rule cntr;
        rg_cntr <= rg_cntr + 1;
    endrule

    rule feed_stream;
        if (inp_rdy && rg_cntr <= 2 * `MAT_DIM - 1)
            myMult.feed_inp_stream(inp_Astream, inp_Bstream);
    endrule

    method Action putAB (MatType inpA, MatType inpB);
        VecType a_in = replicate(0);
        VecType b_in = replicate(0);

        for(int i=0; i<`MAT_DIM; i=i+1) begin
            if ((rg_cntr-i < `MAT_DIM) &&(i<=rg_cntr)) begin
                a_in[i] = inpA[i][rg_cntr-i];
                b_in[i] = inpB[rg_cntr-i][i];

                //$display("\nlvA[%d, %d]\n", i, rg_cntr-i);
                //fxptWrite(5, lv_mat_A[i][rg_cntr-i]);
                $display("\na\n");
                fxptWrite(5, a_in[i]);
                $display("\nb\n");
                fxptWrite(5, b_in[i]);
            end
        end 

        inp_Astream <= a_in;
        inp_Bstream <= b_in;
        inp_rdy <= True;
    endrule

    method VecType getC;
        inp_rdy <= False;
        let z = myMult.get_out_stream;
        VecType outr = z;

        return outr;
    endrule

    method int getk;
        return rg_cntr-`MAT_DIM-7;
    endmethod
endmodule

endpackage