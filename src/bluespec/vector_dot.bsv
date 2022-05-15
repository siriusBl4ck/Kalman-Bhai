package vector_dot;

interface Vector_ifc#(type t);
    method Action put_a (t input1);     //Method to put the value of an element of the first vector.
    method Action put_b (t input2);     //Method to put the value of an element of the second vector.
    method Action end_value (Bool d_a); //Method to pass the flag to indicate if the inputs passed are the last
    method ActionValue#(t) dot_result;  //The final result can be received from here and is enabled only when the output is ready
    method Bool final_done;             //Method to check if output is ready
endinterface

(* synthesize *)
module mkVectorDot(Vector_ifc#(M_type));
    
    //Stage 1 registers
    Reg#(Maybe#(M_type)) a <- mkReg(tagged Invalid);
    Reg#(Maybe#(M_type)) b <- mkReg(tagged Invalid);
    Reg#(Bool) flag_stage1 <- mkReg(True);  

    //Stage 2 registers
    Reg#(Maybe#(M_type)) prod <- mkReg(unpack(0));      
    Reg#(M_type) accum_sum    <- mkReg(unpack(0));
    Reg#(M_type) final_result <- mkReg(unpack(0));
    Reg#(Bool) flag_stage2    <- mkReg(True);

    //Stage 3 registers
    Reg#(Bool) flag_stage3 <- mkReg(True);
    Reg#(Bool) done        <- mkReg(False);


    //Stage 1
    rule stage1_multiplication;
        if( isValid(a) && isValid(b) )
        begin
            prod <= tagged Valid( a.Valid * b.Valid );
            flag_stage2 <= flag_stage1;

            a <= tagged Invalid;        //This is done so that the next stage doesn't get junk or repeated values
            b <= tagged Invalid;        //This also means that the values need not be passed continously

        end

        else
        begin
            prod <= tagged Invalid;
            flag_stage2 <= True;    //Reset value is being given to flag_stage2
        end
    endrule


    //Stage 2
    rule stage2_accumulated_sum ( isValid(prod) );
        final_result <= accum_sum + prod.Valid;

        if( flag_stage2 ) 
        begin
            done <= True;
            accum_sum <= 0;     //Reset is being given to accum_sum
        end

        else 
        begin
            accum_sum <= accum_sum + prod.Valid;
            done <= False;
        end

        flag_stage3 <= flag_stage2;
    endrule


    method Action put_a (M_type input1);
        a <= tagged Valid(input1);
    endmethod
    
    method Action put_b (M_type input2);
        b <= tagged Valid(input2);
    endmethod
    
    method Action end_value (Bool d_a);
        flag_stage1 <= d_a;
    endmethod


    //Stage 3
    method ActionValue#(M_type) dot_result if (flag_stage3);
        flag_stage3 <= False;   
        return final_result;
    endmethod
    method Bool final_done;
        return done;
    endmethod
endmodule

endpackage


