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
    Reg#(SysType) matA[MAT_DIM][MAT_DIM];
    Reg#(SysType) matA_inv[MAT_DIM][MAT_DIM];

    for (int i = 0; i < MAT_DIM; i = i + 1) begin
        for (int j = 0; j < MAT_DIM; j = j + 1) begin
            matA[i][j] <- mkReg(0);
            matA_inv[i][j] <- mkReg(0);
        end
    end

    Reg#(Bit#(1)) rdy <- mkReg(1);
    Reg#(int) cntr <- mkReg(0);

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

        //initialize as identity matrix
        for (int i = 0; i < MAT_DIM; i = i + 1) begin
            for (int j = 0; j < MAT_DIM; j = j + 1) begin
                if (i == j) matA_inv[i][j] <= 1'b1;
                else matA_inv[i][j] <= 1'b0;
            end
        end

        rdy <= 1'b0;

        //init counter
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