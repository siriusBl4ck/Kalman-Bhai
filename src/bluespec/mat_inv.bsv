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

    rule rl_compute (!rdy);
        int c = cntr;
        //MatType temp_matA = defaultValue, temp_matA_inv=defaultValue;

        /*
                FixedPoint#(33, 16) lv_quot = fxptQuot(matA[i][c], matA[c][c]);
                SysType lv_quot_final = fxptTruncate(lv_quot);

                SysType lv_mult = fxptTruncate(fxptMult(lv_quot_final, matA[c][j]));
                temp_matA[i][j] = fxptTruncate(fxptSub(matA[i][j], lv_mult));

                SysType lv_mult2 = fxptTruncate(fxptMult((lv_quot_final), matA_inv[c][j]));
                temp_matA_inv[i][j] = fxptTruncate(fxptSub(matA_inv[i][j], lv_mult2));
        */

        //SysType lv_ratio[`MAT_DIM];
        /*
        Vector#(`MAT_DIM, VecType) matA_vecs <- replicate(unpack(0));

        for (int j = 0; j < `MAT_DIM; j = j + 1) begin
            matA_vecs[j] = matA[j];
        end
        
        for (int j = 0; j < `MAT_DIM; j = j + 1) begin
            //if (j != c) begin
            FixedPoint#(33, 16) lv_q = fxptQuot(matA[j][c], matA[c][c]); 
            lv_ratio[j] = fxptTruncate(lv_q);
            //end
        end
        */

        /*
        for (int i = 0; i < `MAT_DIM; i = i + 1) begin
            for (int j = 0; j < `MAT_DIM; j = j + 1) begin
                
            end
        end
        for (int j=0; j<`MAT_DIM; j= j+1) begin
            temp_matA[c][j] = matA[c][j];
            temp_matA_inv[c][j] = matA_inv[c][j];
        end


        if (cntr == `MAT_DIM) begin
            for (int k = 0; k < `MAT_DIM; k = k + 1) begin
                for (int l = 0; l < `MAT_DIM; l = l + 1) begin
                    FixedPoint#(33, 16) lv_q = fxptQuot(matA_inv[k][l], matA[k][k]);
                    temp_matA_inv[k][l] = fxptTruncate(lv_q);
                end
            end
            rdy <= True;
        end

        for(int i=0; i<`MAT_DIM; i=i+1) begin
            for (int j=0; j<`MAT_DIM; j=j+1) begin
                matA[i][j] <= temp_matA[i][j];
                matA_inv[i][j] <= temp_matA_inv[i][j];
            end
        end
        */

        rdy <= True;
    endrule

    method Action put(MatType matrixA);
    /*
        for (int i = 0; i < `MAT_DIM; i = i + 1) begin
            for (int j = 0; j < `MAT_DIM; j = j + 1) begin
                
                matA[i][j] <= matrixA[i][j];
            end
        end

        //initialize as identity matrix
        for (int i = 0; i < `MAT_DIM; i = i + 1) begin
            for (int j = 0; j < `MAT_DIM; j = j + 1) begin
                if (i == j) matA_inv[i][j] <= fromRational(1, 1);
                else matA_inv[i][j] <= fromRational(0, 1);
            end
        end
    */
        rdy <= False;

        //init counter
        cntr <= 0;
    endmethod

    method Bool isRdy();
        return rdy;
    endmethod

    method MatType get() if (rdy);
        MatType lv_a_inv = unpack(0);
        /*
        for (int i = 0; i < `MAT_DIM; i = i + 1) begin
            for (int j = 0; i < `MAT_DIM; j = j + 1) begin
                lv_a_inv[i][j] = matA_inv[i][j];
            end
        end
        */
        return lv_a_inv;
    endmethod
endmodule

endpackage