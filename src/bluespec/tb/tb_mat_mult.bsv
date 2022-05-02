package tb_mat_mult;

`include "src/types.bsv"

import FixedPoint::*;
import mat_mult_systolic::*;

/*
    0 1 2
    ------
0 | 1 2 3
1 | 4 5 6
2 | 7 8 9
*/
(* synthesize *)
module tb_mat_mult(Empty);
    Ifc_mat_mult_systolic myMult <- mat_mult_systolic;
    Reg#(VecType) inp_Astream <- mkReg(unpack(0));
    Reg#(VecType) inp_Bstream <- mkReg(unpack(0));
    Reg#(MatType) out_stream <- mkReg(unpack(0));
    Reg#(Bit#(4)) rg_cntr <- mkReg(0);

    SysType lv_mat_A[`MAT_DIM][`MAT_DIM];
    SysType lv_mat_B[`MAT_DIM][`MAT_DIM];

    lv_mat_A[0][0] = 1;
    lv_mat_A[0][1] = 2;
    lv_mat_A[0][2] = 3;

    lv_mat_A[1][0] = 4;
    lv_mat_A[1][1] = 5;
    lv_mat_A[1][2] = 6;

    lv_mat_A[2][0] = 7;
    lv_mat_A[2][1] = 8;
    lv_mat_A[2][2] = 9;

    lv_mat_B[0][0] = 1;
    lv_mat_B[0][1] = 2;
    lv_mat_B[0][2] = 3;

    lv_mat_B[1][0] = 4;
    lv_mat_B[1][1] = 5;
    lv_mat_B[1][2] = 6;

    lv_mat_B[2][0] = 7;
    lv_mat_B[2][1] = 8;
    lv_mat_B[2][2] = 9;

    rule cntr;
        rg_cntr <= rg_cntr + 1;
    endrule

    rule feed_stream;
        if (rg_cntr >= 1 && rg_cntr <= 4) myMult.feed_inp_stream(inp_Astream, inp_Bstream);
        
        if (rg_cntr >= 1) begin
            //get the result back
            MatType output_mat = myMult.get_out_stream();
            out_stream <= output_mat;

            SysType c[3][3];

            c[0][0] = unpack(output_mat[`INP_LEN - 1 : 0]);
            c[0][1] = unpack(output_mat[2 * `INP_LEN - 1 : `INP_LEN]);
            c[0][2] = unpack(output_mat[3 * `INP_LEN - 1 : 2 * `INP_LEN]);

            c[1][0] = unpack(output_mat[4 * `INP_LEN - 1 : 3 * `INP_LEN]);
            c[1][1] = unpack(output_mat[5 * `INP_LEN - 1 : 4 * `INP_LEN]);
            c[1][2] = unpack(output_mat[6 * `INP_LEN - 1 : 5 * `INP_LEN]);

            c[2][0] = unpack(output_mat[7 * `INP_LEN - 1 : 6 * `INP_LEN]);
            c[2][1] = unpack(output_mat[8 * `INP_LEN - 1 : 7 * `INP_LEN]);
            c[2][2] = unpack(output_mat[9 * `INP_LEN - 1 : 8 * `INP_LEN]);

            $display($time, " [systole]\n");

            for (int i = 0; i < 3; i = i + 1) begin
                for (int j = 0; j < 3; j = j + 1) begin
                    fxptWrite(1, c[i][j]);
                    $write(" ");
                end
                $display("\n");
            end
        end

        if (rg_cntr == 10) $finish();
    endrule

    rule streams;
        SysType a1 = 0;
        SysType a2 = 0;
        SysType a3 = 0;
        SysType b1 = 0;
        SysType b2 = 0;
        SysType b3 = 0;

        if (rg_cntr == 0) begin
            //init for 0
            a1 = lv_mat_A[0][0];
            
            b1 = lv_mat_B[0][0];
        end

        else if (rg_cntr == 1) begin
            //init for 1
            a1 = lv_mat_A[0][1];
            a2 = lv_mat_A[1][0];
            
            b1 = lv_mat_B[1][0];
            b2 = lv_mat_B[0][1];
        end

        else if (rg_cntr == 2) begin
            //init for 2
            a1 = lv_mat_A[0][2];
            a2 = lv_mat_A[1][1];
            a3 = lv_mat_A[2][0];
            
            b1 = lv_mat_B[2][0];
            b2 = lv_mat_B[1][1];
            b3 = lv_mat_B[0][2];
        end

        else if (rg_cntr == 3) begin
            //init for 3
            a2 = lv_mat_A[1][2];
            a3 = lv_mat_A[2][1];
            
            b2 = lv_mat_B[2][1];
            b3 = lv_mat_B[1][2];
        end

        else if (rg_cntr == 4) begin
            //init for 4
            a3 = lv_mat_A[2][2];
            
            b3 = lv_mat_B[2][2];
        end

        inp_Astream <= {pack(a1), pack(a2), pack(a3)};
        inp_Bstream <= {pack(b1), pack(b2), pack(b3)};
    endrule
endmodule

endpackage