// To be noted
// Here I have added a valid bit to pe module which might not be necessary in select situations and can be removed to save FFs. 
// Only modification needed is make validAB always 1 in pe module and remove the reg

package mat_mult_systolic;
    import pe::*;
    import FixedPoint::*;
    `include "types.bsv"

    interface Ifc_mat_imm;
        method Action putAB (MatType inpA, MatType inpB);
        method Action rst;
        method VecType getC;
        method int getk;
    endinterface

module mkmat_imm(Ifc_mat_imm);
    Ifc_mat_mult_systolic myMult <- mat_mult_systolic;
    
    Reg#(VecType) inp_Astream <- mkReg(unpack(0));
    Reg#(VecType) inp_Bstream <- mkReg(unpack(0));
    Reg#(VecType) out_stream <- mkReg(unpack(0));
    Reg#(MatType) matA <- mkReg(replicate(replicate(unpack(0))));
    Reg#(MatType) matB <- mkReg(replicate(replicate(unpack(0))));
    Reg#(int) rg_cntr <- mkReg(0);
    Reg#(Bool) inp_rdy <- mkReg(False), out_rdy <- mkDWire(False);

    rule cntr;
        if (inp_rdy) rg_cntr <= rg_cntr + 1;
        else rg_cntr <= 0;
    endrule

    rule feed_stream;
        // if (inp_rdy && rg_cntr <= 2 * `MAT_DIM - 1)
        //     myMult.feed_inp_stream(inp_Astream, inp_Bstream);
    endrule

    rule make_streams (inp_rdy);
        VecType a_in = replicate(0);
        VecType b_in = replicate(0);
        for(int i=0; i<`MAT_DIM; i=i+1) begin
            if ((rg_cntr-i < `MAT_DIM) &&(i<=rg_cntr)) begin
                a_in[i] = matB[i][rg_cntr-i];
                b_in[i] = matA[rg_cntr-i][i];

                //$display("\nlvA[%d, %d]\n", i, rg_cntr-i);
                //fxptWrite(5, lv_mat_A[i][rg_cntr-i]);
                $display("\na\n");
                fxptWrite(5, a_in[i]);
                $display("\nb\n");
                fxptWrite(5, b_in[i]);
            end
        end 

        // inp_Astream <= a_in;
        // inp_Bstream <= b_in;

        if (inp_rdy && rg_cntr <= 2 * `MAT_DIM - 1)
            myMult.feed_inp_stream(a_in, b_in);
    endrule

    method Action putAB (MatType inpA, MatType inpB);
        matA <= inpA;
        matB <= inpB;
        inp_rdy <= True;
    endmethod

    method VecType getC;
        let z = myMult.get_out_stream;
        VecType outr = z;

        return outr;
    endmethod

    method int getk;
        return rg_cntr-`MAT_DIM-7;
    endmethod

    method Action rst;
        rg_cntr <= 0;
        inp_rdy <= False;
        inp_Astream <= unpack(0);
        inp_Bstream <= unpack(0);
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