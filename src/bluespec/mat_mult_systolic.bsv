// To be noted
// Here I have added a valid bit to pe module which might not be necessary in select situations and can be removed to save FFs. 
// Only modification needed is make validAB always 1 in pe module and remove the reg

package mat_mult_systolic;
    import pe::*;
    import FixedPoint::*;
    `include "types.bsv"

    interface Ifc_mat_mult_systolic;
        method Action feed_inp_stream(VecType a_stream, VecType b_stream);
        method MatType get_out_stream();
    endinterface

    (* synthesize *)
    module mat_mult_systolic(Ifc_mat_mult_systolic);
        Vector#(`MAT_DIM, Vector#(`MAT_DIM, Ifc_pe)) pe <- replicateM(replicateM(mk_pe));

        Vector#(`MAT_DIM, Wire#(SysType)) wr_inp_a <- replicateM(mkDWire(unpack(0)));
        Vector#(`MAT_DIM, Wire#(SysType)) wr_inp_b <- replicateM(mkDWire(unpack(0)));
        PulseWire wr_inp_rdy <- mkPulseWire;

        `ifdef VERBOSE
        Reg#(Bit#(1)) rg_stage0_rdy <- mkReg(0);
        Vector#(`MAT_DIM, Reg#(SysType)) rg_inp_a <- replicateM(mkReg(unpack(0)));
        Vector#(`MAT_DIM, Reg#(SysType)) rg_inp_b <- replicateM(mkReg(unpack(0)));
        rule stage0_latch;      //REMOVE later
            if (wr_inp_rdy) begin
                for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                    $display($time, " [MULT] [stage0] latching A[%d] ", i);
                    fxptWrite(5, wr_inp_a[i]);
                    $display("\n");
                    $display($time, " [MULT] [stage0] latching B[%d] ", i);
                    fxptWrite(5, wr_inp_b[i]);
                    $display("\n");
                    
                    rg_inp_a[i] <= wr_inp_a[i];
                    rg_inp_b[i] <= wr_inp_b[i];
                end

                rg_stage0_rdy <= 1'b1;
            end
            else rg_stage0_rdy <= 1'b0;
        endrule
        `endif

        rule systole;
            SysType lv_pe_a[`MAT_DIM][`MAT_DIM];
            SysType lv_pe_b[`MAT_DIM][`MAT_DIM];

            if (wr_inp_rdy)
                // feed the new inputs to the systolic array
                for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                    lv_pe_a[i][0] = wr_inp_a[i];
                    lv_pe_b[0][i] = wr_inp_b[i];

                    if (i != 0) begin
                        lv_pe_a[0][i] = pe[0][i - 1].getA();
                        lv_pe_b[i][0] = pe[i - 1][0].getB();
                    end
                end

            for (int i = 1; i < `MAT_DIM; i = i + 1)
                for (int j = 1; j < `MAT_DIM; j= j + 1) 
                    if (pe[i][j - 1].validAB && pe[i - 1][j].validAB) begin
                        lv_pe_a[i][j] = pe[i][j - 1].getA();
                        lv_pe_b[i][j] = pe[i - 1][j].getB();
                    end
                    else begin
                        lv_pe_a[i][j] = unpack(0);
                        lv_pe_b[i][j] = unpack(0); 
                    end               

            //propagate the systolic array
            for (int i = 0; i < `MAT_DIM; i = i + 1)
                for (int j = 0; j < `MAT_DIM; j= j + 1) begin
                    pe[i][j].putA(lv_pe_a[i][j]);
                    pe[i][j].putB(lv_pe_b[i][j]);

                    `ifdef VERBOSE
                    if (lv_pe_a[i][j] != unpack(0)) begin
                        $display("\nprop: %d, %d", i, j, $time);
                        fxptWrite(5, lv_pe_a[i][j]);
                        fxptWrite(5, lv_pe_b[i][j]);
                        $display("\n");
                    end
                    `endif
                end
        endrule

        method Action feed_inp_stream(VecType a_stream, VecType b_stream);
            for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                wr_inp_a[i] <= a_stream[i];
                wr_inp_b[i] <= b_stream[i];
            end   

            wr_inp_rdy.send();
        endmethod

        method MatType get_out_stream();
            MatType out_stream = defaultValue;

            for (int i = 0; i < `MAT_DIM; i = i + 1)
                for (int j = 0; j < `MAT_DIM; j = j + 1)
                    out_stream[i][j] = pe[i][j].getC();

            return out_stream;
        endmethod
    endmodule
endpackage