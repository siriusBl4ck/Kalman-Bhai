package pe;

`include "types.bsv"

interface Ifc_pe;
    method Action putA(SysType in_a);
    method Action putB(SysType in_b);
    method SysType getA();
    method SysType getB();
    method SysType getC();
endinterface

(* synthesize *)
module mk_pe(Ifc_pe);
    Wire#(SysType) wr_in_a <- mkDWire(unpack(0));
    Wire#(SysType) wr_in_b <- mkDWire(unpack(0));

    Wire#(Bit#(1)) wr_valid_a <- mkDWire(unpack(0));
    Wire#(Bit#(1)) wr_valid_b <- mkDWire(unpack(0));

    Reg#(SysType) rg_out_a <- mkReg(unpack(0));
    Reg#(SysType) rg_out_b <- mkReg(unpack(0));
    Reg#(SysType) rg_out_c <- mkReg(unpack(0));

    rule mac (wr_valid_a && wr_valid_b);
        //TODO: Replace with an efficient MAC architecture
        rg_out_c <= wr_in_a * wr_in_b + rg_out_c;
    endrule

    rule propagate;
        rg_out_a <= wr_in_a;
        rg_out_b <= wr_in_b;
    endrule

    method Action putA(SysType in_a);
        wr_in_a <= in_a;
        wr_valid_a <= 1'b1;
    endmethod

    method Action putB(SysType in_b);
        wr_in_b <= in_b;
        wr_valid_b <= 1'b1;
    endmethod

    method SysType getA();
        return rg_out_a;
    endmethod

    method SysType getB();
        return rg_out_b;
    endmethod

    method SysType getC();
        return rg_out_c;
    endmethod
endmodule

endpackage