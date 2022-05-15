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
    Vector#(`MAT_DIM, Vector#(`MAT_DIM, Reg#(SysType))) matA <- replicateM(replicateM(mkReg(unpack(0))));
    Vector#(`MAT_DIM, Vector#(`MAT_DIM, Reg#(SysType))) matA_inv <- replicateM(replicateM(mkReg(unpack(0))));

    Reg#(Bool) rdy <- mkReg(True);
    Reg#(int) cntr <- mkReg(0);///////////////////

    rule rl_cntr (!rdy);
        cntr <= cntr + 1;
    endrule

    rule rl_compute (rdy == 1'b0);
        int c = cntr;
        for (int i = 0; i < MAT_DIM; i = i + 1) begin
            for (int j = 0; j < MAT_DIM; j = j + 1) begin
                if (i != c) begin
                    //TODO: replace these operations by proper modules
                    SysType lv_quot = fxptTruncate(fxptQuot(a[i][c], a[c][c]));
                    SysType lv_mult = fxptTruncate(fxptMult(lv_quot, a[c][j]));
                    a[i][j] <= fxptTruncate(fxptSub(a[i][j], lv_mult));

                    SysType lv_quot2 = fxptTruncate(fxptQuot(a[i][c], a[c][c]));
                    SysType lv_mult2 = fxptTruncate(fxptMult((lv_quot2), a_inv[c][j]));
                    a_inv[i][j] <= fxptTruncate(fxptSub(a_inv[i][j], lv_mult2));
                end
            end
        end
        if (cntr == MAT_DIM) begin
            for (int k = 0; k < MAT_DIM; k = k + 1) begin
                for (int l = 0; l < MAT_DIM; l = l + 1) begin
                    a_inv[k][l] <= fxptTruncate(fxptQuot(a_inv[k][l], a[k][k]));
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

    method MatType get() if (rdy);
        MatType lv_a_inv = unpack(pack(a_inv));
        return lv_a_inv;
    endmethod
endmodule

endpackage