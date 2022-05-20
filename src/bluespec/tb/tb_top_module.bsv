package tb_top_module;

`include "types.bsv"

import KalmanAlgo::*;

// latency in cycles of kalman
`define LATENCY 1;

(*synthesize*)
module mk_tb_top_module(Empty);
    Kalman_Ifc kalman <- mkKalman;
    Reg#(int) cntr <- mkReg(0);

    // VecType init_xk <- replicate(unpack(0));
    // MatTypeSD_noregs init <- replicate(replicate(unpack(0)));

    Reg#(Vector#(`STATE_DIM, SysType)) xk <- mkReg(replicate(fromRational(1, 1)));
    Reg#(Vector#(`INPUT_DIM, SysType)) uk <- mkReg(replicate(fromRational(1, 1)));
    Reg#(Vector#(`MEASUREMENT_DIM, SysType)) zk <- mkReg(replicate(fromRational(1, 1)));

    Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) init_pk = replicate(replicate(unpack(0)));
    for (int i = 0; i < `STATE_DIM; i = i + 1) init_pk[i][i] = fromRational(500, 1);
    Reg#(Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType))) pk <- mkReg(init_pk);

    Reg#(Bool) xk_done <- mkReg(False);
    Reg#(Bool) pk_done <- mkReg(False);

    rule rl_test;
        if (cntr == 0) begin
            $display("fed inputs\n");
            kalman.put_xk_uk(xk, uk);
            kalman.put_pk(pk);
            kalman.put_zk(zk);
            cntr <= 1;
        end
    endrule

    rule get_pk (!pk_done);
        if (kalman.is_pk_rdy()) begin
            let tmp_pk = kalman.get_pk();

            for (int i = 0; i < `STATE_DIM; i = i + 1) begin
                for (int j = 0; j < `STATE_DIM; j = j + 1) begin
                    fxptWrite(5, tmp_pk[i][j]);
                    $write("  ");
                end
                $write("\n");
            end

            pk_done <= True;
        end
    endrule

    rule get_xk (!xk_done);
        if (kalman.is_xk_rdy()) begin
            let tmp_xk = kalman.get_xk();
            for (int i = 0; i < `STATE_DIM; i = i + 1) begin
                fxptWrite(5, tmp_xk[i]);
                $write("  ");
            end
            $write("\n");

            xk_done <= True;
        end
    endrule

    rule finish;
        if (xk_done && pk_done) begin
            $display($time, "both done");
            $finish();
        end
    endrule

endmodule

endpackage