//
// Generated by Bluespec Compiler, version 2021.07-1-gaf77efcd (build af77efcd)
//
// On Mon May 16 22:55:32 IST 2022
//
//
// Ports:
// Name                         I/O  size props
// RDY_feed_inp_stream            O     1 const
// get_out_stream                 O    96
// RDY_get_out_stream             O     1
// RDY_reset_mod                  O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 reset
// feed_inp_stream_a_stream       I    96
// feed_inp_stream_b_stream       I    96
// EN_feed_inp_stream             I     1
// EN_reset_mod                   I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mat_mult_systolic(CLK,
			 RST_N,

			 feed_inp_stream_a_stream,
			 feed_inp_stream_b_stream,
			 EN_feed_inp_stream,
			 RDY_feed_inp_stream,

			 get_out_stream,
			 RDY_get_out_stream,

			 EN_reset_mod,
			 RDY_reset_mod);
  input  CLK;
  input  RST_N;

  // action method feed_inp_stream
  input  [95 : 0] feed_inp_stream_a_stream;
  input  [95 : 0] feed_inp_stream_b_stream;
  input  EN_feed_inp_stream;
  output RDY_feed_inp_stream;

  // value method get_out_stream
  output [95 : 0] get_out_stream;
  output RDY_get_out_stream;

  // action method reset_mod
  input  EN_reset_mod;
  output RDY_reset_mod;

  // signals for module outputs
  wire [95 : 0] get_out_stream;
  wire RDY_feed_inp_stream, RDY_get_out_stream, RDY_reset_mod;

  // register cntr
  reg [31 : 0] cntr;
  wire [31 : 0] cntr$D_IN;
  wire cntr$EN;

  // register incr
  reg incr;
  wire incr$D_IN, incr$EN;

  // ports of submodule pe_0_0
  wire [31 : 0] pe_0_0$getA,
		pe_0_0$getB,
		pe_0_0$getC,
		pe_0_0$putA_in_a,
		pe_0_0$putB_in_b;
  wire pe_0_0$EN_putA, pe_0_0$EN_putB, pe_0_0$EN_reset_mod;

  // ports of submodule pe_0_1
  wire [31 : 0] pe_0_1$getA,
		pe_0_1$getB,
		pe_0_1$getC,
		pe_0_1$putA_in_a,
		pe_0_1$putB_in_b;
  wire pe_0_1$EN_putA, pe_0_1$EN_putB, pe_0_1$EN_reset_mod, pe_0_1$validAB;

  // ports of submodule pe_0_2
  wire [31 : 0] pe_0_2$getB, pe_0_2$getC, pe_0_2$putA_in_a, pe_0_2$putB_in_b;
  wire pe_0_2$EN_putA, pe_0_2$EN_putB, pe_0_2$EN_reset_mod, pe_0_2$validAB;

  // ports of submodule pe_1_0
  wire [31 : 0] pe_1_0$getA,
		pe_1_0$getB,
		pe_1_0$getC,
		pe_1_0$putA_in_a,
		pe_1_0$putB_in_b;
  wire pe_1_0$EN_putA, pe_1_0$EN_putB, pe_1_0$EN_reset_mod, pe_1_0$validAB;

  // ports of submodule pe_1_1
  wire [31 : 0] pe_1_1$getA,
		pe_1_1$getB,
		pe_1_1$getC,
		pe_1_1$putA_in_a,
		pe_1_1$putB_in_b;
  wire pe_1_1$EN_putA, pe_1_1$EN_putB, pe_1_1$EN_reset_mod, pe_1_1$validAB;

  // ports of submodule pe_1_2
  wire [31 : 0] pe_1_2$getB, pe_1_2$getC, pe_1_2$putA_in_a, pe_1_2$putB_in_b;
  wire pe_1_2$EN_putA, pe_1_2$EN_putB, pe_1_2$EN_reset_mod, pe_1_2$validAB;

  // ports of submodule pe_2_0
  wire [31 : 0] pe_2_0$getA, pe_2_0$getC, pe_2_0$putA_in_a, pe_2_0$putB_in_b;
  wire pe_2_0$EN_putA, pe_2_0$EN_putB, pe_2_0$EN_reset_mod, pe_2_0$validAB;

  // ports of submodule pe_2_1
  wire [31 : 0] pe_2_1$getA, pe_2_1$getC, pe_2_1$putA_in_a, pe_2_1$putB_in_b;
  wire pe_2_1$EN_putA, pe_2_1$EN_putB, pe_2_1$EN_reset_mod, pe_2_1$validAB;

  // ports of submodule pe_2_2
  wire [31 : 0] pe_2_2$getC, pe_2_2$putA_in_a, pe_2_2$putB_in_b;
  wire pe_2_2$EN_putA, pe_2_2$EN_putB, pe_2_2$EN_reset_mod;

  // inputs to muxes for submodule ports
  wire MUX_incr$write_1__PSEL_1, MUX_incr$write_1__SEL_1;

  // declarations used by system tasks
  // synopsys translate_off
  reg [63 : 0] v__h7177;
  // synopsys translate_on

  // remaining internal signals
  reg [15 : 0] CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q3,
	       CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q4,
	       CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q1,
	       CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q2,
	       CASE_x762_0_pe_0_0getC_BITS_15_TO_0_1_pe_0_1_ETC__q6,
	       CASE_x762_0_pe_0_0getC_BITS_31_TO_16_1_pe_0_1_ETC__q5;
  wire [31 : 0] SEL_ARR_pe_0_0_getC__15_BITS_31_TO_16_16_pe_0__ETC___d128,
		SEL_ARR_pe_1_0_getC__7_BITS_31_TO_16_8_pe_1_1__ETC___d110,
		SEL_ARR_pe_2_0_getC__8_BITS_31_TO_16_9_pe_2_1__ETC___d91,
		cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1___d95,
		cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1___d76,
		x__h8762;

  // action method feed_inp_stream
  assign RDY_feed_inp_stream = 1'd1 ;

  // value method get_out_stream
  assign get_out_stream =
	     { ((cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1___d76 ^ 32'h80000000) <
		32'h80000003) ?
		 SEL_ARR_pe_2_0_getC__8_BITS_31_TO_16_9_pe_2_1__ETC___d91 :
		 32'd0,
	       ((cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1___d95 ^ 32'h80000000) <
		32'h80000003) ?
		 SEL_ARR_pe_1_0_getC__7_BITS_31_TO_16_8_pe_1_1__ETC___d110 :
		 32'd0,
	       ((x__h8762 ^ 32'h80000000) < 32'h80000003) ?
		 SEL_ARR_pe_0_0_getC__15_BITS_31_TO_16_16_pe_0__ETC___d128 :
		 32'd0 } ;
  assign RDY_get_out_stream = (cntr ^ 32'h80000000) > 32'h80000003 ;

  // action method reset_mod
  assign RDY_reset_mod = 1'd1 ;

  // submodule pe_0_0
  mk_pe pe_0_0(.CLK(CLK),
	       .RST_N(RST_N),
	       .putA_in_a(pe_0_0$putA_in_a),
	       .putB_in_b(pe_0_0$putB_in_b),
	       .EN_putA(pe_0_0$EN_putA),
	       .EN_putB(pe_0_0$EN_putB),
	       .EN_reset_mod(pe_0_0$EN_reset_mod),
	       .RDY_putA(),
	       .RDY_putB(),
	       .getA(pe_0_0$getA),
	       .RDY_getA(),
	       .getB(pe_0_0$getB),
	       .RDY_getB(),
	       .getC(pe_0_0$getC),
	       .RDY_getC(),
	       .validAB(),
	       .RDY_validAB(),
	       .RDY_reset_mod());

  // submodule pe_0_1
  mk_pe pe_0_1(.CLK(CLK),
	       .RST_N(RST_N),
	       .putA_in_a(pe_0_1$putA_in_a),
	       .putB_in_b(pe_0_1$putB_in_b),
	       .EN_putA(pe_0_1$EN_putA),
	       .EN_putB(pe_0_1$EN_putB),
	       .EN_reset_mod(pe_0_1$EN_reset_mod),
	       .RDY_putA(),
	       .RDY_putB(),
	       .getA(pe_0_1$getA),
	       .RDY_getA(),
	       .getB(pe_0_1$getB),
	       .RDY_getB(),
	       .getC(pe_0_1$getC),
	       .RDY_getC(),
	       .validAB(pe_0_1$validAB),
	       .RDY_validAB(),
	       .RDY_reset_mod());

  // submodule pe_0_2
  mk_pe pe_0_2(.CLK(CLK),
	       .RST_N(RST_N),
	       .putA_in_a(pe_0_2$putA_in_a),
	       .putB_in_b(pe_0_2$putB_in_b),
	       .EN_putA(pe_0_2$EN_putA),
	       .EN_putB(pe_0_2$EN_putB),
	       .EN_reset_mod(pe_0_2$EN_reset_mod),
	       .RDY_putA(),
	       .RDY_putB(),
	       .getA(),
	       .RDY_getA(),
	       .getB(pe_0_2$getB),
	       .RDY_getB(),
	       .getC(pe_0_2$getC),
	       .RDY_getC(),
	       .validAB(pe_0_2$validAB),
	       .RDY_validAB(),
	       .RDY_reset_mod());

  // submodule pe_1_0
  mk_pe pe_1_0(.CLK(CLK),
	       .RST_N(RST_N),
	       .putA_in_a(pe_1_0$putA_in_a),
	       .putB_in_b(pe_1_0$putB_in_b),
	       .EN_putA(pe_1_0$EN_putA),
	       .EN_putB(pe_1_0$EN_putB),
	       .EN_reset_mod(pe_1_0$EN_reset_mod),
	       .RDY_putA(),
	       .RDY_putB(),
	       .getA(pe_1_0$getA),
	       .RDY_getA(),
	       .getB(pe_1_0$getB),
	       .RDY_getB(),
	       .getC(pe_1_0$getC),
	       .RDY_getC(),
	       .validAB(pe_1_0$validAB),
	       .RDY_validAB(),
	       .RDY_reset_mod());

  // submodule pe_1_1
  mk_pe pe_1_1(.CLK(CLK),
	       .RST_N(RST_N),
	       .putA_in_a(pe_1_1$putA_in_a),
	       .putB_in_b(pe_1_1$putB_in_b),
	       .EN_putA(pe_1_1$EN_putA),
	       .EN_putB(pe_1_1$EN_putB),
	       .EN_reset_mod(pe_1_1$EN_reset_mod),
	       .RDY_putA(),
	       .RDY_putB(),
	       .getA(pe_1_1$getA),
	       .RDY_getA(),
	       .getB(pe_1_1$getB),
	       .RDY_getB(),
	       .getC(pe_1_1$getC),
	       .RDY_getC(),
	       .validAB(pe_1_1$validAB),
	       .RDY_validAB(),
	       .RDY_reset_mod());

  // submodule pe_1_2
  mk_pe pe_1_2(.CLK(CLK),
	       .RST_N(RST_N),
	       .putA_in_a(pe_1_2$putA_in_a),
	       .putB_in_b(pe_1_2$putB_in_b),
	       .EN_putA(pe_1_2$EN_putA),
	       .EN_putB(pe_1_2$EN_putB),
	       .EN_reset_mod(pe_1_2$EN_reset_mod),
	       .RDY_putA(),
	       .RDY_putB(),
	       .getA(),
	       .RDY_getA(),
	       .getB(pe_1_2$getB),
	       .RDY_getB(),
	       .getC(pe_1_2$getC),
	       .RDY_getC(),
	       .validAB(pe_1_2$validAB),
	       .RDY_validAB(),
	       .RDY_reset_mod());

  // submodule pe_2_0
  mk_pe pe_2_0(.CLK(CLK),
	       .RST_N(RST_N),
	       .putA_in_a(pe_2_0$putA_in_a),
	       .putB_in_b(pe_2_0$putB_in_b),
	       .EN_putA(pe_2_0$EN_putA),
	       .EN_putB(pe_2_0$EN_putB),
	       .EN_reset_mod(pe_2_0$EN_reset_mod),
	       .RDY_putA(),
	       .RDY_putB(),
	       .getA(pe_2_0$getA),
	       .RDY_getA(),
	       .getB(),
	       .RDY_getB(),
	       .getC(pe_2_0$getC),
	       .RDY_getC(),
	       .validAB(pe_2_0$validAB),
	       .RDY_validAB(),
	       .RDY_reset_mod());

  // submodule pe_2_1
  mk_pe pe_2_1(.CLK(CLK),
	       .RST_N(RST_N),
	       .putA_in_a(pe_2_1$putA_in_a),
	       .putB_in_b(pe_2_1$putB_in_b),
	       .EN_putA(pe_2_1$EN_putA),
	       .EN_putB(pe_2_1$EN_putB),
	       .EN_reset_mod(pe_2_1$EN_reset_mod),
	       .RDY_putA(),
	       .RDY_putB(),
	       .getA(pe_2_1$getA),
	       .RDY_getA(),
	       .getB(),
	       .RDY_getB(),
	       .getC(pe_2_1$getC),
	       .RDY_getC(),
	       .validAB(pe_2_1$validAB),
	       .RDY_validAB(),
	       .RDY_reset_mod());

  // submodule pe_2_2
  mk_pe pe_2_2(.CLK(CLK),
	       .RST_N(RST_N),
	       .putA_in_a(pe_2_2$putA_in_a),
	       .putB_in_b(pe_2_2$putB_in_b),
	       .EN_putA(pe_2_2$EN_putA),
	       .EN_putB(pe_2_2$EN_putB),
	       .EN_reset_mod(pe_2_2$EN_reset_mod),
	       .RDY_putA(),
	       .RDY_putB(),
	       .getA(),
	       .RDY_getA(),
	       .getB(),
	       .RDY_getB(),
	       .getC(pe_2_2$getC),
	       .RDY_getC(),
	       .validAB(),
	       .RDY_validAB(),
	       .RDY_reset_mod());

  // inputs to muxes for submodule ports
  assign MUX_incr$write_1__PSEL_1 = incr && !EN_feed_inp_stream ;
  assign MUX_incr$write_1__SEL_1 = MUX_incr$write_1__PSEL_1 && cntr == 32'd8 ;

  // register cntr
  assign cntr$D_IN = (cntr == 32'd8) ? 32'd0 : cntr + 32'd1 ;
  assign cntr$EN = MUX_incr$write_1__PSEL_1 ;

  // register incr
  assign incr$D_IN = !MUX_incr$write_1__SEL_1 ;
  assign incr$EN =
	     MUX_incr$write_1__PSEL_1 && cntr == 32'd8 || EN_feed_inp_stream ;

  // submodule pe_0_0
  assign pe_0_0$putA_in_a =
	     EN_feed_inp_stream ? feed_inp_stream_a_stream[31:0] : 32'd0 ;
  assign pe_0_0$putB_in_b =
	     EN_feed_inp_stream ? feed_inp_stream_b_stream[31:0] : 32'd0 ;
  assign pe_0_0$EN_putA = 1'd1 ;
  assign pe_0_0$EN_putB = 1'd1 ;
  assign pe_0_0$EN_reset_mod = EN_reset_mod ;

  // submodule pe_0_1
  assign pe_0_1$putA_in_a = pe_0_0$getA ;
  assign pe_0_1$putB_in_b =
	     EN_feed_inp_stream ? feed_inp_stream_b_stream[63:32] : 32'd0 ;
  assign pe_0_1$EN_putA = 1'd1 ;
  assign pe_0_1$EN_putB = 1'd1 ;
  assign pe_0_1$EN_reset_mod = EN_reset_mod ;

  // submodule pe_0_2
  assign pe_0_2$putA_in_a = pe_0_1$getA ;
  assign pe_0_2$putB_in_b =
	     EN_feed_inp_stream ? feed_inp_stream_b_stream[95:64] : 32'd0 ;
  assign pe_0_2$EN_putA = 1'd1 ;
  assign pe_0_2$EN_putB = 1'd1 ;
  assign pe_0_2$EN_reset_mod = EN_reset_mod ;

  // submodule pe_1_0
  assign pe_1_0$putA_in_a =
	     EN_feed_inp_stream ? feed_inp_stream_a_stream[63:32] : 32'd0 ;
  assign pe_1_0$putB_in_b = pe_0_0$getB ;
  assign pe_1_0$EN_putA = 1'd1 ;
  assign pe_1_0$EN_putB = 1'd1 ;
  assign pe_1_0$EN_reset_mod = EN_reset_mod ;

  // submodule pe_1_1
  assign pe_1_1$putA_in_a =
	     (pe_1_0$validAB && pe_0_1$validAB) ? pe_1_0$getA : 32'd0 ;
  assign pe_1_1$putB_in_b =
	     (pe_1_0$validAB && pe_0_1$validAB) ? pe_0_1$getB : 32'd0 ;
  assign pe_1_1$EN_putA = 1'd1 ;
  assign pe_1_1$EN_putB = 1'd1 ;
  assign pe_1_1$EN_reset_mod = EN_reset_mod ;

  // submodule pe_1_2
  assign pe_1_2$putA_in_a =
	     (pe_1_1$validAB && pe_0_2$validAB) ? pe_1_1$getA : 32'd0 ;
  assign pe_1_2$putB_in_b =
	     (pe_1_1$validAB && pe_0_2$validAB) ? pe_0_2$getB : 32'd0 ;
  assign pe_1_2$EN_putA = 1'd1 ;
  assign pe_1_2$EN_putB = 1'd1 ;
  assign pe_1_2$EN_reset_mod = EN_reset_mod ;

  // submodule pe_2_0
  assign pe_2_0$putA_in_a =
	     EN_feed_inp_stream ? feed_inp_stream_a_stream[95:64] : 32'd0 ;
  assign pe_2_0$putB_in_b = pe_1_0$getB ;
  assign pe_2_0$EN_putA = 1'd1 ;
  assign pe_2_0$EN_putB = 1'd1 ;
  assign pe_2_0$EN_reset_mod = EN_reset_mod ;

  // submodule pe_2_1
  assign pe_2_1$putA_in_a =
	     (pe_2_0$validAB && pe_1_1$validAB) ? pe_2_0$getA : 32'd0 ;
  assign pe_2_1$putB_in_b =
	     (pe_2_0$validAB && pe_1_1$validAB) ? pe_1_1$getB : 32'd0 ;
  assign pe_2_1$EN_putA = 1'd1 ;
  assign pe_2_1$EN_putB = 1'd1 ;
  assign pe_2_1$EN_reset_mod = EN_reset_mod ;

  // submodule pe_2_2
  assign pe_2_2$putA_in_a =
	     (pe_2_1$validAB && pe_1_2$validAB) ? pe_2_1$getA : 32'd0 ;
  assign pe_2_2$putB_in_b =
	     (pe_2_1$validAB && pe_1_2$validAB) ? pe_1_2$getB : 32'd0 ;
  assign pe_2_2$EN_putA = 1'd1 ;
  assign pe_2_2$EN_putB = 1'd1 ;
  assign pe_2_2$EN_reset_mod = EN_reset_mod ;

  // remaining internal signals
  assign SEL_ARR_pe_0_0_getC__15_BITS_31_TO_16_16_pe_0__ETC___d128 =
	     { CASE_x762_0_pe_0_0getC_BITS_31_TO_16_1_pe_0_1_ETC__q5,
	       CASE_x762_0_pe_0_0getC_BITS_15_TO_0_1_pe_0_1_ETC__q6 } ;
  assign SEL_ARR_pe_1_0_getC__7_BITS_31_TO_16_8_pe_1_1__ETC___d110 =
	     { CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q3,
	       CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q4 } ;
  assign SEL_ARR_pe_2_0_getC__8_BITS_31_TO_16_9_pe_2_1__ETC___d91 =
	     { CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q1,
	       CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q2 } ;
  assign cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1___d95 =
	     ((cntr - 32'd1) - 32'd3) - 32'd1 ;
  assign cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1___d76 =
	     ((cntr - 32'd2) - 32'd3) - 32'd1 ;
  assign x__h8762 = (cntr - 32'd3) - 32'd1 ;
  always@(cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1___d76 or
	  pe_2_0$getC or pe_2_1$getC or pe_2_2$getC)
  begin
    case (cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1___d76)
      32'd0:
	  CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q1 =
	      pe_2_0$getC[31:16];
      32'd1:
	  CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q1 =
	      pe_2_1$getC[31:16];
      32'd2:
	  CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q1 =
	      pe_2_2$getC[31:16];
      default: CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q1 =
		   16'b1010101010101010 /* unspecified value */ ;
    endcase
  end
  always@(cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1___d76 or
	  pe_2_0$getC or pe_2_1$getC or pe_2_2$getC)
  begin
    case (cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1___d76)
      32'd0:
	  CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q2 =
	      pe_2_0$getC[15:0];
      32'd1:
	  CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q2 =
	      pe_2_1$getC[15:0];
      32'd2:
	  CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q2 =
	      pe_2_2$getC[15:0];
      default: CASE_cntr_2_MINUS_2_4_MINUS_3_5_MINUS_1_6_0_pe_ETC__q2 =
		   16'b1010101010101010 /* unspecified value */ ;
    endcase
  end
  always@(cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1___d95 or
	  pe_1_0$getC or pe_1_1$getC or pe_1_2$getC)
  begin
    case (cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1___d95)
      32'd0:
	  CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q3 =
	      pe_1_0$getC[31:16];
      32'd1:
	  CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q3 =
	      pe_1_1$getC[31:16];
      32'd2:
	  CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q3 =
	      pe_1_2$getC[31:16];
      default: CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q3 =
		   16'b1010101010101010 /* unspecified value */ ;
    endcase
  end
  always@(cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1___d95 or
	  pe_1_0$getC or pe_1_1$getC or pe_1_2$getC)
  begin
    case (cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1___d95)
      32'd0:
	  CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q4 =
	      pe_1_0$getC[15:0];
      32'd1:
	  CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q4 =
	      pe_1_1$getC[15:0];
      32'd2:
	  CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q4 =
	      pe_1_2$getC[15:0];
      default: CASE_cntr_2_MINUS_1_3_MINUS_3_4_MINUS_1_5_0_pe_ETC__q4 =
		   16'b1010101010101010 /* unspecified value */ ;
    endcase
  end
  always@(x__h8762 or pe_0_0$getC or pe_0_1$getC or pe_0_2$getC)
  begin
    case (x__h8762)
      32'd0:
	  CASE_x762_0_pe_0_0getC_BITS_31_TO_16_1_pe_0_1_ETC__q5 =
	      pe_0_0$getC[31:16];
      32'd1:
	  CASE_x762_0_pe_0_0getC_BITS_31_TO_16_1_pe_0_1_ETC__q5 =
	      pe_0_1$getC[31:16];
      32'd2:
	  CASE_x762_0_pe_0_0getC_BITS_31_TO_16_1_pe_0_1_ETC__q5 =
	      pe_0_2$getC[31:16];
      default: CASE_x762_0_pe_0_0getC_BITS_31_TO_16_1_pe_0_1_ETC__q5 =
		   16'b1010101010101010 /* unspecified value */ ;
    endcase
  end
  always@(x__h8762 or pe_0_0$getC or pe_0_1$getC or pe_0_2$getC)
  begin
    case (x__h8762)
      32'd0:
	  CASE_x762_0_pe_0_0getC_BITS_15_TO_0_1_pe_0_1_ETC__q6 =
	      pe_0_0$getC[15:0];
      32'd1:
	  CASE_x762_0_pe_0_0getC_BITS_15_TO_0_1_pe_0_1_ETC__q6 =
	      pe_0_1$getC[15:0];
      32'd2:
	  CASE_x762_0_pe_0_0getC_BITS_15_TO_0_1_pe_0_1_ETC__q6 =
	      pe_0_2$getC[15:0];
      default: CASE_x762_0_pe_0_0getC_BITS_15_TO_0_1_pe_0_1_ETC__q6 =
		   16'b1010101010101010 /* unspecified value */ ;
    endcase
  end

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        cntr <= `BSV_ASSIGNMENT_DELAY 32'd0;
	incr <= `BSV_ASSIGNMENT_DELAY 1'd0;
      end
    else
      begin
        if (cntr$EN) cntr <= `BSV_ASSIGNMENT_DELAY cntr$D_IN;
	if (incr$EN) incr <= `BSV_ASSIGNMENT_DELAY incr$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    cntr = 32'hAAAAAAAA;
    incr = 1'h0;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_feed_inp_stream)
	begin
	  v__h7177 = $time;
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_feed_inp_stream)
	$display(v__h7177, "\nfeed_inp %d\n", $signed(cntr));
  end
  // synopsys translate_on
endmodule  // mat_mult_systolic

