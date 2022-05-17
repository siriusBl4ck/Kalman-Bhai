// To be noted
// Here I have added a valid bit to pe module which might not be necessary in select situations and can be removed to save FFs. 
// Only modification needed is make validAB always 1 in pe module and remove the reg

package mat_mult_systolic;
    import pe::*;
    import FixedPoint::*;
    `include "types.bsv"

    interface Ifc_mat_imm;
        method Action putAB (MatType inpA, MatType inpB);
        method Action start;
        method VecType getC;
        method int getk;
    endinterface

    module mkmat_imm (Ifc_mat_imm);
        Reg#(int) cntr <- mkReg(0);
        //Reg#(MatType) C <- mkReg(defaultValue);

        Wire#(VecType) inp_Astream <- mkDWire(replicate(0)), inp_Bstream <- mkDWire(replicate(0));
        Wire#(MatType) out_C <- mkDWire (replicate(replicate(0)));

        PulseWire starter <- mkPulseWire;
        PulseWire out_ready <- mkPulseWire;

    	Ifc_mat_mult_systolic mult_mod <- mat_mult_systolic;

        
        rule r1 (starter);
            mult_mod.feed_inp_stream(inp_Astream, inp_Bstream);

            if (cntr == 3*`MAT_DIM+5) begin
                cntr <= 0;
            end
            else
                cntr <= cntr+1;
        endrule

        rule r2 (starter);
            let z = mult_mod.get_out_stream;
            out_C <= z;
            out_ready.send();
        endrule


        method Action start;
            starter.send();
        endmethod


        method Action putAB (MatType inpA, MatType inpB);
            for(int i=0; i<`MAT_DIM; i=i+1) begin
                if ((cntr-i < `MAT_DIM) &&(i<=cntr)) begin
                    // Pk*F.Transpose
                    inp_Astream[i] <= Pk[i][CP_cntr-i];
                    inp_Bstream[i] <= F[i][CP_cntr-i];
                end 
            end
        endmethod

        method getC (VecType C) if (out_ready);
            return out_C;
        endmethod

        method int getk if (out_ready);
            return cntr-`MAT_DIM-7;
        endmethod
    endmodule



    interface Ifc_mat_mult_systolic;
        method Action feed_inp_stream(VecType a_stream, VecType b_stream);
        method VecType get_out_stream;
        method Action reset_mod;
    endinterface

    (* synthesize *)
    module mat_mult_systolic(Ifc_mat_mult_systolic);
        Vector#(`MAT_DIM, Vector#(`MAT_DIM, Ifc_pe)) pe <- replicateM(replicateM(mk_pe));

        Vector#(`MAT_DIM, Wire#(SysType)) wr_inp_a <- replicateM(mkDWire(unpack(0)));
        Vector#(`MAT_DIM, Wire#(SysType)) wr_inp_b <- replicateM(mkDWire(unpack(0)));
        PulseWire wr_inp_rdy <- mkPulseWire;
        Reg#(Bool) incr <- mkReg(False);

        Reg#(int) cntr <- mkReg(0);

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

                end
        endrule

        rule inc_cntr (incr);
            if (cntr == 3*`MAT_DIM-1) begin
                cntr <= 0;
                incr <= False;
            end
            else
                cntr <= cntr+1;
        endrule

        method Action feed_inp_stream(VecType a_stream, VecType b_stream);
            $display($time, "\nfeed_inp %d\n", cntr);
            for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                wr_inp_a[i] <= a_stream[i];
                wr_inp_b[i] <= b_stream[i];
            end   

            incr <= True;

            wr_inp_rdy.send();
        endmethod


        method VecType get_out_stream if (cntr > `MAT_DIM);
            VecType out_stream = replicate(0);
            

            for (int i=0; i<`MAT_DIM; i=i+1) begin
                if (cntr-i-`MAT_DIM-1 < `MAT_DIM)
                    out_stream[i] = pe[i][cntr-i-`MAT_DIM-1].getC();
            end
            return out_stream;
        endmethod

        method Action reset_mod;
            for(int i=0; i<`MAT_DIM; i=i+1)
                for(int j=0; j<`MAT_DIM; j=j+1)
                    pe[i][j].reset_mod();
        endmethod

    endmodule
endpackage