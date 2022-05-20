// To be noted
// Here I have added a valid bit to pe module which might not be necessary in select situations and can be removed to save FFs. 
// Only modification needed is make validAB always 1 in pe module and remove the reg

package mat_mult_systolic;
    import pe::*;
    import FixedPoint::*;
    `include "types.bsv"

    interface Ifc_mat_imm;
        method Action putAB (MatType inpA, MatType inpB);
        method ActionValue#(MatType) getC;
        method Bool is_out_rdy();
        method Action reset_systole();
    endinterface

    module mkmat_imm(Ifc_mat_imm);
        Ifc_mat_mult_systolic myMult <- mat_mult_systolic;
        
        //Reg#(VecType) inp_Astream <- mkReg(unpack(0));
        //Reg#(VecType) inp_Bstream <- mkReg(unpack(0));
        //Reg#(VecType) out_stream <- mkReg(unpack(0));
        Reg#(MatType) out_mat <- mkReg(replicate(replicate(unpack(0))));
        Reg#(MatType) matA <- mkReg(replicate(replicate(unpack(0)))), matB <- mkReg(replicate(replicate(unpack(0))));
        Reg#(int) rg_cntr <- mkReg(0);
        Reg#(Bool) inp_rdy <- mkReg(True), out_rdy <- mkReg(False);

        rule cntr (!inp_rdy);
            if (rg_cntr == 3*`MAT_DIM+5) begin
                $display("[mult] ENDING");
                rg_cntr <= 0;
                inp_rdy <= True;
                out_rdy <= True;
            end 
            else begin
                rg_cntr <= rg_cntr+1;
            end
            
            $display("[mult] rg_cntr %d\n", rg_cntr);
        endrule

        rule make_streams (!inp_rdy);
            VecType inp_Astream = replicate(0), inp_Bstream = replicate(0);

            for(int i=0; i<`MAT_DIM; i=i+1) begin
                if ((rg_cntr-i < `MAT_DIM) &&(i<=rg_cntr)) begin
                    inp_Astream[i] = matA[i][rg_cntr-i];
                    inp_Bstream[i] = matB[rg_cntr-i][i];
                    
                    /*if ((inp_Astream[i] != 0) || (inp_Bstream[i] != 0)) begin
                    $display("\na\n");
                    fxptWrite(5, inp_Astream[i]);
                    $display("\nb\n");
                    fxptWrite(5, inp_Bstream[i]);
                    end*/
                end 
            end
            /*
            VecType a_in = replicate(0);
            VecType b_in = replicate(0);

            if (rg_cntr <= 2 * `MAT_DIM - 1) begin
                for (int i=0; i<`MAT_DIM; i=i+1) begin
                    if (inp_Astream[i] !=0) begin
                        
                    $display("make_streams %d\n", rg_cntr);
                    fxptWrite(5, inp_Astream[i]);
                    $display("\n");
                    end
                end 
            */

            myMult.feed_inp_stream(inp_Astream, inp_Bstream);
        endrule

        rule out_stream (!out_rdy);
            let z <- myMult.get_out_stream;

            MatType temp_out = replicate(replicate(0));
            temp_out = out_mat;

            for (int i=0; i<`MAT_DIM; i=i+1) begin
                int k = rg_cntr-i-`MAT_DIM-2;
                $display("\n[mult]incoming %d\n", k);
                fxptWrite(5, z[i]);
                $display("\n");
                if ((k>=0) && (k < `MAT_DIM)) begin
                    temp_out[i][k] = z[i];
                    $display($time, " hooo %d,%d, %d\n", i, k, rg_cntr);
                    if (z[i] != 0) fxptWrite(5, z[i]);
                end
            end
            out_mat <= temp_out;
            
            $display("temp_out\n");
            for (int i=0; i<`MAT_DIM; i=i+1) begin
                for(int j=0; j<`MAT_DIM; j=j+1) begin
                    $write(" ");
                    fxptWrite(5, temp_out[i][j]);
                end
                $write("\n");
            end


        endrule


        method Action putAB (MatType inpA, MatType inpB);
            $display("[mult_mod] putAB");
            matA <= inpA;
            matB <= inpB;
            inp_rdy <= False;
            out_rdy <= False;
        endmethod

        method ActionValue#(MatType) getC;
            //$display("hi");
            // inp_rdy <= True;
            return out_mat;
        endmethod

        method Action reset_systole();
            myMult.reset_mod;
        endmethod

        method Bool is_out_rdy();
            return out_rdy;
        endmethod
    endmodule


    interface Ifc_mat_mult_systolic;
        method Action feed_inp_stream(VecType a_stream, VecType b_stream);
        method ActionValue#(VecType) get_out_stream;
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
            //$display($time, "\nfeed_inp %d\n", cntr);
            for (int i = 0; i < `MAT_DIM; i = i + 1) begin
                wr_inp_a[i] <= a_stream[i];
                wr_inp_b[i] <= b_stream[i];
            end   

            incr <= True;

            wr_inp_rdy.send();
        endmethod


        method ActionValue#(VecType) get_out_stream if (cntr > `MAT_DIM);
            VecType out_stream = replicate(0);

            for (int i=0; i<`MAT_DIM; i=i+1) begin
                if (cntr-i-`MAT_DIM-1 < `MAT_DIM) begin
                    out_stream[i] = pe[i][cntr-i-`MAT_DIM-1].getC();
                    /*$display("\n", $time, "get_out:");
                    fxptWrite(5, out_stream[i]);
                    $display("\n");*/
                end
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