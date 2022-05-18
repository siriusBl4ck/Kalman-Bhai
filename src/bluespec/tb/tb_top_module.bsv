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

    Reg#(Vector#(`STATE_DIM, SysType)) xk <- mkReg(replicate(unpack(0)));
    Reg#(Vector#(`INPUT_DIM, SysType)) uk <- mkReg(replicate(unpack(0)));
    Reg#(Vector#(`MEASUREMENT_DIM, SysType)) zk <- mkReg(replicate(unpack(0)));

    Reg#(Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType))) pk <- mkReg(replicate(replicate(unpack(0))));

    

    Reg#(Bool) xk_done <- mkReg(False);
    Reg#(Bool) pk_done <- mkReg(False);

    Reg#(Bool) start <- mkReg(False);
    Reg#(Bool) init <- mkReg(False);

    rule rl_cntr;
        cntr <= cntr + 1;
    endrule

    rule rl_init (!init);
        init <= True;
        Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) tmp_pk = pk;
        for (int i = 0; i < `STATE_DIM; i = i + 1) tmp_pk[i][i] = fromRational(500, 1);

        pk <= tmp_pk;
    endrule

    rule rl_test (!start && init);
        start <= True;
        kalman.put_xk_uk(xk, uk);
        kalman.put_pk(pk);
        kalman.put_zk(zk);
    endrule

    rule get_pk;
        let tmp_pk = kalman.get_pk();

        for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			for (int j = 0; j < `STATE_DIM; j = j + 1) begin
				fxptWrite(5, tmp_pk[i][j]);
                $write("  ");
			end
            $write("\n");
		end
        $finish();

        pk_done <= True;
    endrule

    rule get_xk;
        let tmp_xk = kalman.get_xk();
        for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			fxptWrite(5, tmp_xk[i]);
            $write("  ");
        end
        $write("\n");
        $finish();

        xk_done <= True;
    endrule

    rule finish;
        if (xk_done && pk_done) $finish();
    endrule

endmodule

endpackage