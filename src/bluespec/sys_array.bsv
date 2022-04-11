package sys_array;

`include "types.bsv"

import Vector::*;
import pe::*;

interface Ifc_mat_mult_systolic_3x3;
    method Action feed_inp_stream(InpStreamType a_stream, InpStreamType b_stream);
    method OutStreamType get_out_stream();
endinterface

(* synthesize *)
module mat_mult_systolic_3x3(Ifc_mat_mult_systolic_3x3);
    Ifc_pe pe_00 <- mk_pe;
    Ifc_pe pe_01 <- mk_pe;
    Ifc_pe pe_02 <- mk_pe;

    Ifc_pe pe_10 <- mk_pe;
    Ifc_pe pe_11 <- mk_pe;
    Ifc_pe pe_12 <- mk_pe;

    Ifc_pe pe_20 <- mk_pe;
    Ifc_pe pe_21 <- mk_pe;
    Ifc_pe pe_22 <- mk_pe;

    rule systole;
        SysType lv_pe01_a = pe_00.getA();
        SysType lv_pe02_a = pe_01.getA();
        SysType lv_pe11_a = pe_10.getA();
        SysType lv_pe12_a = pe_11.getA();
        SysType lv_pe21_a = pe_20.getA();
        SysType lv_pe22_a = pe_21.getA();

        SysType lv_pe10_b = pe_00.getB();
        SysType lv_pe11_b = pe_01.getB();
        SysType lv_pe12_b = pe_02.getB();
        SysType lv_pe20_b = pe_10.getB();
        SysType lv_pe21_b = pe_11.getB();
        SysType lv_pe22_b = pe_12.getB();

        pe_01.putA(lv_pe01_a);
        pe_02.putA(lv_pe02_a);

        pe_10.putB(lv_pe10_b);
        pe_20.putB(lv_pe20_b);

        pe_11.putA(lv_pe11_a);
        pe_11.putB(lv_pe11_b);

        pe_12.putA(lv_pe12_a);
        pe_12.putB(lv_pe12_b);

        pe_21.putA(lv_pe21_a);
        pe_21.putB(lv_pe21_b);

        pe_22.putA(lv_pe22_a);
        pe_22.putB(lv_pe22_b);
    endrule

    method Action feed_inp_stream(InpStreamType a_stream, InpStreamType b_stream);
        SysType lv_a_0 = a_stream[1 * INP_LEN - 1 : 0 * INP_LEN];
        SysType lv_a_1 = a_stream[2 * INP_LEN - 1 : 1 * INP_LEN];
        SysType lv_a_2 = a_stream[3 * INP_LEN - 1 : 2 * INP_LEN];

        SysType lv_b_0 = b_stream[1 * INP_LEN - 1 : 0 * INP_LEN];
        SysType lv_b_1 = b_stream[2 * INP_LEN - 1 : 1 * INP_LEN];
        SysType lv_b_2 = b_stream[3 * INP_LEN - 1 : 2 * INP_LEN];

        pe_00.putA(lv_a_0);
        pe_10.putA(lv_a_1);
        pe_20.putA(lv_a_2);

        pe_00.putB(lv_b_0);
        pe_01.putB(lv_b_1);
        pe_02.putB(lv_b_2);
    endmethod

    method OutStreamType get_out_stream();
        OutStreamType out_stream = {pe_00.getC(), pe_01.getC(), pe_02.getC(),
                                    pe_10.getC(), pe_11.getC(), pe_12.getC(),
                                    pe_20.getC(), pe_21.getC(), pe_22.getC()};
        return out_stream;
    endmethod
endmodule

endpackage