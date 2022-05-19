package tb_new_top_module;

`include "types.bsv"

import top_module::*;

// latency in cycles of kalman
`define LATENCY 1;

(*synthesize*)
module mk_tb_new_top_module(Empty);
    Ifc_top_module kalman <- mk_top_module;
    Reg#(int) cntr <- mkReg(0);

    // VecType init_xk <- replicate(unpack(0));
    // MatTypeSD_noregs init <- replicate(replicate(unpack(0)));

    Reg#(Vector#(`STATE_DIM, SysType)) xk <- mkReg(replicate(unpack(0)));
    Reg#(Vector#(`INPUT_DIM, SysType)) uk <- mkReg(replicate(unpack(0)));
    Reg#(Vector#(`MEASUREMENT_DIM, SysType)) zk <- mkReg(replicate(unpack(0)));

    Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) init_pk = replicate(replicate(unpack(0)));
    for (int i = 0; i < `STATE_DIM; i = i + 1) init_pk[i][i] = fromRational(500, 1);
    Reg#(Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType))) pk <- mkReg(init_pk);

    Reg#(Bool) xk_done <- mkReg(False);
    Reg#(Bool) pk_done <- mkReg(False);

    Reg#(Bool) start <- mkReg(False);
    Reg#(Bool) init <- mkReg(False);

    rule rl_cntr;
        cntr <= cntr + 1;
    endrule

    rule rl_test;
        if (cntr == 0) begin
            kalman.put_xk_uk(xk, uk);
            kalman.put_pk(pk);
            kalman.put_zk(zk);
        end
    endrule

    rule get_pk;
        if (kalman.pk_Rdy()) begin
        let tmp_pk = kalman.get_pk();
            for (int i = 0; i < `STATE_DIM; i = i + 1) begin
                for (int j = 0; j < `STATE_DIM; j = j + 1) begin
                    fxptWrite(5, tmp_pk[i][j]);
                    $write("  ");
                end
                $write("\n");
            end
        end

        pk_done <= True;
    endrule

    rule get_xk;
        if (kalman.xk_Rdy()) begin
            let tmp_xk = kalman.get_xk();
            for (int i = 0; i < `STATE_DIM; i = i + 1) begin
                fxptWrite(5, tmp_xk[i]);
                $write("  ");
            end
            $write("\n");
        end

        xk_done <= True;
    endrule

    rule finish;
        //if (xk_done && pk_done) $finish();
    endrule

endmodule

endpackage