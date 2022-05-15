package tb_new_mat_inv;

`include "types.bsv"

import FixedPoint::*;
import total_mat_inv::*;

(*synthesize*)
module mkTb_new_mat_inv(Empty);
	Ifc_mat_inv myInv <- mk_mat_inv;
    Reg#(int) cntr <- mkReg(0);

    MatType mymat1 = defaultValue;
    mymat1[0][0] = fromRational(1,1);
    mymat1[0][1] = fromRational(1,1);
    mymat1[0][2] = fromRational(1,1);
    mymat1[1][0] = fromRational(4,1);
    mymat1[1][1] = fromRational(4,1);
    mymat1[1][2] = fromRational(6,1);
    mymat1[2][0] = fromRational(7,1);
    mymat1[2][1] = fromRational(8,1);
    mymat1[2][2] = fromRational(9,1);

    MatType mymat2 = defaultValue;
    mymat2[0][0] = fromRational(5,1);
    mymat2[0][1] = fromRational(11,1);
    mymat2[0][2] = fromRational(34,1);
    mymat2[1][0] = fromRational(29,1);
    mymat2[1][1] = fromRational(9,1);
    mymat2[1][2] = fromRational(3,1);
    mymat2[2][0] = fromRational(17,1);
    mymat2[2][1] = fromRational(61,1);
    mymat2[2][2] = fromRational(2,1);

    rule count;
        cntr <= cntr + 1;
    endrule

    rule rl_test;
        if (cntr == 0) begin
            myInv.put(mymat2);
        end
    endrule

    rule rl_get;
        if (cntr > 0 && myInv.isRdy) begin
            MatType inverse = myInv.get();
            $display($time, "[tb] tmp_A_inv:");
            for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                for (int j = 0; j < `MAT_DIM; j = j + 1) begin
                    fxptWrite(5, inverse[i][j]);
                    $write(" ");
                end
                $display("\n");
            end
            $finish();
        end
    endrule
endmodule

endpackage