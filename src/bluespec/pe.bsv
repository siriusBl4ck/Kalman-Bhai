package pe;

    `include "types.bsv"

    interface Ifc_pe;
        method Action putA(SysType in_a);
        method Action putB(SysType in_b);
        method SysType getA();
        method SysType getB();
        method SysType getC();
        method Bool validAB();
    endinterface

    (* synthesize *)
    module mk_pe(Ifc_pe);
        Wire#(SysType) wr_in_a <- mkDWire(unpack(0));
        Wire#(SysType) wr_in_b <- mkDWire(unpack(0));

        Wire#(Bool) wr_valid_a <- mkDWire(False);
        Wire#(Bool) wr_valid_b <- mkDWire(False);

        Reg#(SysType) rg_out_a <- mkReg(unpack(0));
        Reg#(SysType) rg_out_b <- mkReg(unpack(0));
        Reg#(SysType) rg_out_c <- mkReg(unpack(0));
        Reg#(Bool) valid_a_b <- mkReg(False);

        rule mac;
            if (wr_valid_a && wr_valid_b) begin
                //TODO: Replace with an efficient MAC architecture ✅
                //$display($time, " [MAC] rule reached, performing compute\n");
                SysType lv_mult = fxptTruncate(fxptMult(wr_in_a, wr_in_b)); //NOT GENERALISED
                rg_out_c <= fxptTruncate(fxptAdd(lv_mult, rg_out_c));
                valid_a_b <= True;
            end
            else
                valid_a_b <= False;
        endrule

        rule propagate;
            rg_out_a <= wr_in_a;
            rg_out_b <= wr_in_b;
        endrule

        method Action putA(SysType in_a);
            //$display($time, " [MAC] method reached, putA\n");
            wr_in_a <= in_a;
            wr_valid_a <= True;
        endmethod

        method Action putB(SysType in_b);
            //$display($time, " [MAC] method reached, putA\n");
            wr_in_b <= in_b;
            wr_valid_b <= True;
        endmethod

        method SysType getA = rg_out_a;
        method SysType getB = rg_out_b;
        method Bool validAB = valid_a_b;
        method SysType getC = rg_out_c;
    endmodule
endpackage