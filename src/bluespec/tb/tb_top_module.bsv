package tb_top_module;

`include "types.bsv"

import KalmanAlgo::*;

// latency in cycles of kalman
`define LATENCY 1;

module mk_tb_top_module;
    Kalman_Ifc kalman <- mkKalman;
    Reg#(int) cntr <- mkReg(0);

    VecType init_xk <- replicate(unpack(0));
    MatTypeSD_noregs init <- replicate(replicate(unpack(0)));

    VecTypeSD xk <- replicateM(mkReg(unpack(0)));
    VecTypeMD zk <- replicateM(mkReg(unpack(0)));
    MatTypeSD Pk <- replicate(replicateM(mkReg(unpack(0))));

    rule rl_cntr;
        cntr <= cntr + 1;
    endrule

    rule rl_test;
        if (cntr == 0) begin
            for (int i =0; i < `STATE_DIM; i = i + 1) Pk[i][i] <= fromRational(500, 1);
            zk[0] <= fromRational(39366, 100);
            zk[1] <= fromRational(3004, 10);
        end
        
        if (cntr == 1) begin
            kalman.put_xk_uk(xk, uk);
            kalman.put_Pk(Pk);
            kalman.put_zk(zk);
        end
        
        //repeat every LATENCY multiple
        if (cntr == LATENCY + 1) begin
            xk = kalman.get_xk();
            Pk = kalman.get_Pk();
        end
    endrule
endmodule

endpackage