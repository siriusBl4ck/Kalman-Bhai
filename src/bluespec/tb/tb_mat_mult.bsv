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
    Reg#(VecType) out_stream <- mkReg(unpack(0));
    Reg#(int) rg_cntr <- mkReg(0);
    Vector#(`MAT_DIM, Vector#(`MAT_DIM, Reg#(SysType))) finalo <- replicateM(replicateM(mkReg(0)));

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
        

        if (rg_cntr == 20) $finish();
    endrule

    rule in_stream;
        VecType a_in = replicate(0);
        VecType b_in = replicate(0);

        VecType outp = replicate(0);
        //MatType output_mat = myMult.get_out_stream();

        for(int i=0; i<`MAT_DIM; i=i+1) begin
            if ((rg_cntr-i < `MAT_DIM) &&(i<=rg_cntr)) begin
                a_in[i] = lv_mat_A[i][rg_cntr-i];
                b_in[i] = lv_mat_B[rg_cntr-i][i];

                //$display("\nlvA[%d, %d]\n", i, rg_cntr-i);
                //fxptWrite(5, lv_mat_A[i][rg_cntr-i]);
                $display("\na\n");
                fxptWrite(5, a_in[i]);
                $display("\nb\n");
                fxptWrite(5, b_in[i]);
            end 
            /*
            else if (rg_cntr-i > `MAT_DIM) begin
                int k = rg_cntr-i-`MAT_DIM-1;

                if (k<`MAT_DIM)
                    outp[i] = output_mat[i][k];

                $display("\noutp[%d]\n", i, $time);
                fxptWrite(5, outp[i]);
            end*/
        end 

        inp_Astream <= a_in;
        inp_Bstream <= b_in;
        out_stream <= outp;
    endrule

    rule lol;
        let z = myMult.get_out_stream;
        VecType outr = z;
        $display("\nbruh %d\n", rg_cntr);

        for (int i=0; i<`MAT_DIM; i=i+1) begin
            int k = rg_cntr-i-`MAT_DIM-7;
            $display("\nincoming %d\n", k);
            fxptWrite(5, outr[i]);

            
            if ((k>=0) && (k < `MAT_DIM)) begin
                finalo[i][k] <= outr[i];
                $display($time, " hooo %d,%d\n", i, k);
            end
        end
    endrule
    

        

    /*
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

        else if (rg_cntr == 5) begin
            a
        end

        VecType inp_A = unpack({pack(a3), pack(a2), pack(a1)});
        VecType inp_B = unpack({pack(b3), pack(b2), pack(b1)});

        inp_Astream <= inp_A;
        inp_Bstream <= inp_B;
    endrule
    */
endmodule

endpackage