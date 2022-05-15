package mat_inv;

`include "types.bsv"

//import ratio_accumulate::*;

interface Ifc_mat_inv_gaussian;
    method Action put(MatType matrixA);
    method Bool isRdy();
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

    rule rl_compute (rdy);
        for (int c = 0; c < `MAT_DIM; c = c + 1) begin
            if (cntr == c) begin
                for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                    if (i != c) begin
                        for (int j = 0; j < `MAT_DIM; j=j+1) begin
                            //TODO: replace these operations by proper modules
                            a_inv[i][j] <= a_inv[i][j] - (a_inv[i][c] / a_inv[c][c]) * a_inv[c][j];
                            a_inv[i][j] <= a_inv[i][j] - (a[i][c] / a[c][c]) * a_inv[c][j];
                        end
                    end
                end
            end
        end
        if (cntr == `MAT_DIM) begin
            for (int k = 0; k < `MAT_DIM; k = k + 1) begin
                for (int l = 0; l < `MAT_DIM; l = l + 1) begin
                    a_inv[k][l] <= a_inv[k][l] / a_inv[k][k];
                end
            end
            rdy <= True;
        end
    endrule

    method Action put(MatType matrixA);
        matA <= unpack(pack(matrixA));

        //initialize as identity matrix
        for (int i = 0; i < `MAT_DIM; i = i + 1) begin
            for (int j = 0; j < `MAT_DIM; j = j + 1) begin
                if (i == j) matA_inv[i][j] <= 1'b1;
                else matA_inv[i][j] <= 1'b0;
            end
        end

        rdy <= False;

        //init counter
        cntr <= 0;
    endmethod

    method Bool isRdy();
        return rdy;
    endmethod

    method MatType get() if (rdy);
        MatType lv_a_inv = unpack(pack(a_inv));
        return lv_a_inv;
    endmethod
endmodule

endpackage