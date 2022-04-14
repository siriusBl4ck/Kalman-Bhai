package mat_inv;

`include "types.bsv";

import ratio_accumulate::*;

interface Ifc_mat_inv_gaussian;
    method Action put(MatType A);
    method Bit#(1) isRdy();
    method MatType get();
endinterface

(* synthesize *)
module mat_inv_gaussian_3x3(Ifc_mat_inv_gaussian);
    Reg#(SysType) matA[MAT_DIM][MAT_DIM] <- mkReg(0);
    Reg#(SysType) matA_inv[MAT_DIM][MAT_DIM] <- mkReg(0);
    Reg#(Bit#(1)) rdy <- mkReg(1);
    Reg#(int) cntr <- mkReg(0);
    Ifc_ratio_accumulate rta[MAT_DIM - 1] <- mk_ratio_accumulate;

    rule rl_cntr (rdy == 1'b0);
        cntr <= cntr + 1;
    endrule

    rule rl_compute (rdy == 1'b0);
        for (int c = 0; c < MAT_DIM; c = c + 1) begin
            if (cntr == c) begin
                for (int i = 0; i < MAT_DIM; i = i + 1) begin
                    if (i != c) begin
                        for (int j = 0; j < MAT_DIM; j++) begin
                            //TODO: replace these operations by proper modules
                            a[i][j] <= a[i][j] - (a[i][c] / a[c][c]) * a[c][j];
                            a_inv[i][j] <= a_inv[i][j] - (a[i][c] / a[c][c]) * a_inv[c][j];
                        end
                    end
                end
            end
        end
        if (cntr == MAT_DIM) begin
            for (int k = 0; k < MAT_DIM; k = k + 1) begin
                for (int l = 0; l < MAT_DIM; l = l + 1) begin
                    a_inv[k][l] <= a_inv[k][l] / a[k][k];
                end
            end
            rdy <= 1'b1;
        end
    endrule

    method Action put(MatType A);
        matA <= unpack(pack(A));

        matA_inv[0][0] <= 1'b1;
        matA_inv[0][1] <= 1'b0;
        matA_inv[0][2] <= 1'b0;
        matA_inv[1][0] <= 1'b0;
        matA_inv[1][1] <= 1'b1;
        matA_inv[1][2] <= 1'b0;
        matA_inv[2][0] <= 1'b0;
        matA_inv[2][1] <= 1'b0;
        matA_inv[2][2] <= 1'b1;

        rdy <= 1'b0;
        cntr <= 0;
    endmethod

    method Bit#(1) isRdy();
        return rdy;
    endmethod

    method MatType get();
        MatType lv_a_inv = unpack(pack(a_inv));
        return lv_a_inv;
    endmethod
endmodule

endpackage