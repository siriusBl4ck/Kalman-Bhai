package tb_mat_mult;

`include "types.bsv"

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
    Reg#(int) rg_cntr <- mkReg(0);

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
        if (rg_cntr >= 1 && rg_cntr <= 5) 
            myMult.feed_inp_stream(inp_Astream, inp_Bstream);
        
        if (rg_cntr >= 1) begin
            //get the result back
            MatType output_mat = myMult.get_out_stream();
            out_stream <= output_mat;

            SysType c[3][3];

            c[0][0] = output_mat[0][0];
            c[0][1] = output_mat[0][1];
            c[0][2] = output_mat[0][2];

            c[1][0] = output_mat[1][0];
            c[1][1] = output_mat[1][1];
            c[1][2] = output_mat[1][2];

            c[2][0] = output_mat[2][0];
            c[2][1] = output_mat[2][1];
            c[2][2] = output_mat[2][2];

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
            $display("\na1:");
            fxptWrite(5, a1);
            $display("\nb1:");
            fxptWrite(5, b1);
            $display("\n");
        end

        else if (rg_cntr == 1) begin
            //init for 1
            a1 = lv_mat_A[0][1];
            a2 = lv_mat_A[1][0];
            
            b1 = lv_mat_B[1][0];
            b2 = lv_mat_B[0][1];

            $display("\na1:");
            fxptWrite(5, a1);
            $display("\nb1:");
            fxptWrite(5, b1);

            $display("\na2:");
            fxptWrite(5, a2);
            $display("\nb2:");
            fxptWrite(5, b2);
            $display("\n");
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
            $display("\na3:");
            fxptWrite(5, a3);
            $display("\nb3:");
            fxptWrite(5, b3);
            $display("\n");
        end

        VecType inp_A = unpack({pack(a3), pack(a2), pack(a1)});
        VecType inp_B = unpack({pack(b3), pack(b2), pack(b1)});

        inp_Astream <= inp_A;
        inp_Bstream <= inp_B;
    endrule
endmodule

endpackage