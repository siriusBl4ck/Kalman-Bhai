package pe_tb;
import pe::*;
import FixedPoint::*;


(* synthesize *)
module mk_tb_pe(Empty);
    Ifc_pe myPE <- mk_pe;
    Reg#(SysType) rg_a <- mkReg(unpack(0));
    Reg#(SysType) rg_b <- mkReg(unpack(0));
    Reg#(Bit#(4)) rg_cntr <- mkReg(0);

    rule cntr;
        rg_cntr <= rg_cntr + 1;
    endrule

    rule test;
        if (rg_cntr == 0) begin
            rg_a <= fromRational(1, 10);
            rg_b <= fromRational(1, 20);
        end

        if (rg_cntr == 3) begin
            $display($time, " [TB] doing the put\n");
            myPE.putA(rg_a);
            myPE.putB(rg_b);

            rg_a <= fromRational(1, 3);
            rg_b <= fromRational(1, 2);
        end

        if (rg_cntr == 5) begin
            $display($time, " [TB] doing the put\n");
            myPE.putA(rg_a);
            myPE.putB(rg_b);
        end

        $display($time, "\nMAC: ");
        SysType lv_c = myPE.getC();
        fxptWrite(5, lv_c);
        $display("\n");

        if (rg_cntr == 10) begin
            $finish;
        end        
    endrule
endmodule

endpackage