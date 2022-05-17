package tb_top_module;

`include "types.bsv"

import KalmanAlgo::*;

// latency in cycles of kalman
`define LATENCY 1;

module mk_tb_top_module(Empty);
    Kalman_Ifc kalman <- mkKalman;
    Reg#(int) cntr <- mkReg(0);

    VecType init_xk <- replicate(unpack(0));
    MatTypeSD_noregs init <- replicate(replicate(unpack(0)));

    Vector#(`STATE_DIM, SysType) xk <- replicate(unpack(0));
    Vector#(`MEASUREMENT_DIM, SysType) zk <- replicate(unpack(0));
    Vector#(`STATE_DIM, Vector#(`STATE_DIM, SysType)) pk <- replicate(replicate(unpack(0)));

    for (int i = 0; i < `STATE_DIM; i = i + 1) pk[i][i] = fromRational(500, 1);
    zk[0] = fromRational(39366, 100);
    zk[1] = fromRational(3004, 10);

    Reg#(Bool) xk_done <- mkReg(False);
    Reg#(Bool) pk_done <- mkReg(False);

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
        let pk = kalman.get_pk();

        for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			for (int j = 0; j < `STATE_DIM; j = j + 1) begin
				fxptWrite(5, pk[i][j]);
                $write("  ");
			end
            $write("\n");
		end

        pk_done <= 1'b1;
    endrule

    rule get_xk;
        let xk = kalman.get_xk();
        for (int i = 0; i < `STATE_DIM; i = i + 1) begin
			fxptWrite(5, xk[i]);
            $write("  ");
        end
        $write("\n");

        xk_done <= 1'b1;
    endrule

    rule finish;
        if (xk_done && pk_done) $finish();
    endrule

endmodule

endpackage