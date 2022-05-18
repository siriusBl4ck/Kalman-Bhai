package total_mat_inv;

`include "types.bsv"

interface Ifc_mat_inv;
    method Action put(Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) matrixA);
    method Bool isRdy();
    method Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) get();
endinterface

/*
add all the rows together and replace that with the row in case there is a zero a[j][j]
*/

(* synthesize *)
module mk_mat_inv(Ifc_mat_inv);
    Reg#(int) cntr <- mkReg(0);
    Reg#(Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType))) a <- mkReg(unpack(0));

    Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) identity_mat = unpack(0);
    for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
        for (int j = 0; j < i; j = j + 1) begin
            identity_mat[i][j] = fromRational(0,1);
        end
        identity_mat[i][i] = fromRational(1,1);
        for (int j = i + 1; j < `MEASUREMENT_DIM; j = j + 1) begin
            identity_mat[i][j] = fromRational(0,1);
        end
    end

    Reg#(Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType))) a_inv <- mkReg(identity_mat);
    Reg#(Bool) a_valid <- mkReg(False);
    Reg#(Bool) inv_rdy <- mkReg(True);

    rule rl_cntr;
        cntr <= cntr + 1;
    endrule

    rule rl_stuff;
        int c = cntr - 1;
        SysType lv_ratios[`MEASUREMENT_DIM][`MEASUREMENT_DIM];
        SysType lv_sum[`MEASUREMENT_DIM];
        SysType lv_sum_inv[`MEASUREMENT_DIM];

        for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
            lv_sum[i] = fromRational(0, 1);
            lv_sum_inv[i] = fromRational(0, 1);
        end

        Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) tmp_A = a;
        Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) tmp_A_inv = a_inv;
        
        if (a_valid) begin
            for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
                if (tmp_A[i][i] == fromRational(0, 1)) begin
                    $display("Swap with sum!");
                    for (int i0 = 0; i0 < `MEASUREMENT_DIM; i0 = i0 + 1) begin
                        for (int j0 = i; j0 < `MEASUREMENT_DIM; j0 = j0 + 1) begin
                            lv_sum[i0] = lv_sum[i0] + a[j0][i0];
                            lv_sum_inv[i0] = lv_sum_inv[i0] + a_inv[j0][i0];
                        end
                    end
                    $display("Sums:");
                    for (int i0 = 0; i0 < `MEASUREMENT_DIM; i0 = i0 + 1) begin
                        fxptWrite(5, lv_sum[i0]);
                        $write(" ");
                    end
                    $write("\n");
                    for (int k = 0; k < `MEASUREMENT_DIM; k = k + 1) begin
                        tmp_A[i][k] = lv_sum[k];
                        tmp_A_inv[i][k] = lv_sum_inv[k];
                    end

                    $display($time, "tmp_A after swap:");
                    for (int i0 = 0; i0 < `MEASUREMENT_DIM; i0 = i0 + 1) begin
                        for (int j0 = 0; j0 < `MEASUREMENT_DIM; j0 = j0 + 1) begin
                            fxptWrite(1, tmp_A[i0][j0]);
                            $write(" ");
                        end
                        $display("\n");
                    end
                end
            end

            for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
                for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
                    $write("check tmp_A[j][j] = ");
                    fxptWrite(5, tmp_A[j][j]);
                    $write("\n");
                    FixedPoint#(33, 16) lv_q = fxptQuot(tmp_A[i][j], tmp_A[j][j]);
                    lv_ratios[j][i] = fxptTruncate(lv_q);
                end
            end

            for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
                for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
                    if (i == j) lv_ratios[i][j] = unpack(0);
                end
            end

            $display("Ratios");
            for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
                for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
                    fxptWrite(5, lv_ratios[i][j]);
                    $write(" ");
                end
                $write("\n");
            end
        end

        if (a_valid && c >= 0 && c < `MEASUREMENT_DIM) begin

            //$display($time, "[inv] [rl_stuff] pivot column %d", c);

            for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
                $display("Row %d", i);
                for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
                    // SysType lv_mult = fxptTruncate(fxptMult(lv_ratios[c][i], a[c][j]));
                    // tmp_A[i][j] = fxptTruncate(fxptSub(a[i][j], lv_mult));

                    // SysType lv_mult2 = fxptTruncate(fxptMult(lv_ratios[c][i], a_inv[c][j]));
                    // tmp_A_inv[i][j] = fxptTruncate(fxptSub(a_inv[i][j], lv_mult2));

                    SysType lv_mult = fxptTruncate(fxptMult(lv_ratios[c][i], tmp_A[c][j]));
                    tmp_A[i][j] = fxptTruncate(fxptSub(tmp_A[i][j], lv_mult));

                    SysType lv_mult2 = fxptTruncate(fxptMult(lv_ratios[c][i], tmp_A_inv[c][j]));
                    tmp_A_inv[i][j] = fxptTruncate(fxptSub(tmp_A_inv[i][j], lv_mult2));

                    $write("ratios[%d][%d] * a[%d][%d] = ", c, i, c, j);
                    fxptWrite(5, lv_ratios[c][i]);
                    $write(" * ");
                    fxptWrite(5, a[c][j]);
                    $write(" = ");
                    fxptWrite(5, lv_mult);
                    $write("\n");

                    // SysType lv_mult2 = fxptTruncate(fxptMult(lv_ratios[c][i], a_inv[c][j]));
                    // a_inv[i][j] <= fxptTruncate(fxptSub(a_inv[i][j], lv_mult2));
                end
                //$write("\n");
            end

            a <= tmp_A;
            a_inv <= tmp_A_inv;

            $display($time, "[inv] [rl_stuff] tmp_A:");
            for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
                for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
                    fxptWrite(1, tmp_A[i][j]);
                    $write(" ");
                end
                $display("\n");
            end

            $display($time, "[inv] [rl_stuff] tmp_A_inv:");
            for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
                for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
                    fxptWrite(1, tmp_A_inv[i][j]);
                    $write(" ");
                end
                $display("\n");
            end
        end
    
        if (a_valid && c == `MEASUREMENT_DIM) begin
            $display($time, "mat_inverse");
            for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
                for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
                    FixedPoint#(33,16) lv_res = fxptQuot(a_inv[i][j], a[i][i]);
                    tmp_A_inv[i][j] = fxptTruncate(lv_res);

                    $write("a_inv[%d][%d] / a[%d][%d] = ", i, j, i, i);
                    fxptWrite(5, a_inv[i][j]);
                    $write(" / ");
                    fxptWrite(5, a[i][j]);
                    $write(" = ");
                    fxptWrite(5, lv_res);
                    $write("\n");
                end
            end

            a_inv <= tmp_A_inv;
            inv_rdy <= True;
            a_valid <= False;
        end
    endrule

    method Action put(Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) matrixA);
        a <= matrixA;
        cntr <= 0;
        a_valid <= True;
        inv_rdy <= False;
        $display($time, "[inv] [put] called! MatrixA:");
        for (int i = 0; i < `MEASUREMENT_DIM; i = i + 1) begin
            for (int j = 0; j < `MEASUREMENT_DIM; j = j + 1) begin
                fxptWrite(1, matrixA[i][j]);
                $write(" ");
            end
            $display("\n");
        end
    endmethod

    method Bool isRdy() ;
        return inv_rdy;
    endmethod

    method Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) get();
        Vector#(`MEASUREMENT_DIM, Vector#(`MEASUREMENT_DIM, SysType)) lv_res = a_inv;
        return lv_res;
    endmethod
endmodule

endpackage