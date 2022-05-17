//
// Generated by Bluespec Compiler, version 2021.07-1-gaf77efcd (build af77efcd)
//
// On Mon May 16 22:55:31 IST 2022
//
//
// Ports:
// Name                         I/O  size props
// RDY_putA                       O     1 const
// RDY_putB                       O     1 const
// getA                           O    32 reg
// RDY_getA                       O     1 const
// getB                           O    32 reg
// RDY_getB                       O     1 const
// getC                           O    32 reg
// RDY_getC                       O     1 const
// validAB                        O     1 reg
// RDY_validAB                    O     1 const
// RDY_reset_mod                  O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 reset
// putA_in_a                      I    32
// putB_in_b                      I    32
// EN_putA                        I     1
// EN_putB                        I     1
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

module mk_pe(CLK,
	     RST_N,

	     putA_in_a,
	     EN_putA,
	     RDY_putA,

	     putB_in_b,
	     EN_putB,
	     RDY_putB,

	     getA,
	     RDY_getA,

	     getB,
	     RDY_getB,

	     getC,
	     RDY_getC,

	     validAB,
	     RDY_validAB,

	     EN_reset_mod,
	     RDY_reset_mod);
  input  CLK;
  input  RST_N;

  // action method putA
  input  [31 : 0] putA_in_a;
  input  EN_putA;
  output RDY_putA;

  // action method putB
  input  [31 : 0] putB_in_b;
  input  EN_putB;
  output RDY_putB;

  // value method getA
  output [31 : 0] getA;
  output RDY_getA;

  // value method getB
  output [31 : 0] getB;
  output RDY_getB;

  // value method getC
  output [31 : 0] getC;
  output RDY_getC;

  // value method validAB
  output validAB;
  output RDY_validAB;

  // action method reset_mod
  input  EN_reset_mod;
  output RDY_reset_mod;

  // signals for module outputs
  wire [31 : 0] getA, getB, getC;
  wire RDY_getA,
       RDY_getB,
       RDY_getC,
       RDY_putA,
       RDY_putB,
       RDY_reset_mod,
       RDY_validAB,
       validAB;

  // register rg_out_a
  reg [31 : 0] rg_out_a;
  wire [31 : 0] rg_out_a$D_IN;
  wire rg_out_a$EN;

  // register rg_out_b
  reg [31 : 0] rg_out_b;
  wire [31 : 0] rg_out_b$D_IN;
  wire rg_out_b$EN;

  // register rg_out_c
  reg [31 : 0] rg_out_c;
  wire [31 : 0] rg_out_c$D_IN;
  wire rg_out_c$EN;

  // register valid_a_b
  reg valid_a_b;
  wire valid_a_b$D_IN, valid_a_b$EN;

  // inputs to muxes for submodule ports
  wire MUX_rg_out_c$write_1__SEL_2;

  // remaining internal signals
  wire [63 : 0] IF_IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0_0__ETC___d27,
		x__h561;
  wire [32 : 0] x__h535;
  wire [31 : 0] IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0___d10,
		IF_wr_in_b_whas__2_THEN_wr_in_b_wget__3_ELSE_0___d14,
		x__h644,
		x__h664;
  wire [16 : 0] in1_i__h543, in2_i__h690;
  wire [15 : 0] rg_out_c_BITS_31_TO_16__q1, x61_BITS_47_TO_32__q2;

  // action method putA
  assign RDY_putA = 1'd1 ;

  // action method putB
  assign RDY_putB = 1'd1 ;

  // value method getA
  assign getA = rg_out_a ;
  assign RDY_getA = 1'd1 ;

  // value method getB
  assign getB = rg_out_b ;
  assign RDY_getB = 1'd1 ;

  // value method getC
  assign getC = rg_out_c ;
  assign RDY_getC = 1'd1 ;

  // value method validAB
  assign validAB = valid_a_b ;
  assign RDY_validAB = 1'd1 ;

  // action method reset_mod
  assign RDY_reset_mod = 1'd1 ;

  // inputs to muxes for submodule ports
  assign MUX_rg_out_c$write_1__SEL_2 = EN_putA && EN_putB ;

  // register rg_out_a
  assign rg_out_a$D_IN = IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0___d10 ;
  assign rg_out_a$EN = 1'b1 ;

  // register rg_out_b
  assign rg_out_b$D_IN =
	     IF_wr_in_b_whas__2_THEN_wr_in_b_wget__3_ELSE_0___d14 ;
  assign rg_out_b$EN = 1'b1 ;

  // register rg_out_c
  assign rg_out_c$D_IN = EN_reset_mod ? 32'd0 : x__h535[31:0] ;
  assign rg_out_c$EN = EN_putA && EN_putB || EN_reset_mod ;

  // register valid_a_b
  assign valid_a_b$D_IN = !EN_reset_mod && MUX_rg_out_c$write_1__SEL_2 ;
  assign valid_a_b$EN = 1'b1 ;

  // remaining internal signals
  assign IF_IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0_0__ETC___d27 =
	     x__h644 * x__h664 ;
  assign IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0___d10 =
	     EN_putA ? putA_in_a : 32'd0 ;
  assign IF_wr_in_b_whas__2_THEN_wr_in_b_wget__3_ELSE_0___d14 =
	     EN_putB ? putB_in_b : 32'd0 ;
  assign in1_i__h543 = { x61_BITS_47_TO_32__q2[15], x61_BITS_47_TO_32__q2 } ;
  assign in2_i__h690 =
	     { rg_out_c_BITS_31_TO_16__q1[15], rg_out_c_BITS_31_TO_16__q1 } ;
  assign rg_out_c_BITS_31_TO_16__q1 = rg_out_c[31:16] ;
  assign x61_BITS_47_TO_32__q2 = x__h561[47:32] ;
  assign x__h535 =
	     { in1_i__h543, x__h561[31:16] } +
	     { in2_i__h690, rg_out_c[15:0] } ;
  assign x__h561 =
	     (IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0___d10[31] &&
	      !IF_wr_in_b_whas__2_THEN_wr_in_b_wget__3_ELSE_0___d14[31] ||
	      IF_wr_in_b_whas__2_THEN_wr_in_b_wget__3_ELSE_0___d14[31] &&
	      !IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0___d10[31]) ?
	       -IF_IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0_0__ETC___d27 :
	       IF_IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0_0__ETC___d27 ;
  assign x__h644 =
	     IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0___d10[31] ?
	       (EN_putA ? -putA_in_a : 32'd0) :
	       IF_wr_in_a_whas_THEN_wr_in_a_wget_ELSE_0___d10 ;
  assign x__h664 =
	     IF_wr_in_b_whas__2_THEN_wr_in_b_wget__3_ELSE_0___d14[31] ?
	       (EN_putB ? -putB_in_b : 32'd0) :
	       IF_wr_in_b_whas__2_THEN_wr_in_b_wget__3_ELSE_0___d14 ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        rg_out_a <= `BSV_ASSIGNMENT_DELAY 32'd0;
	rg_out_b <= `BSV_ASSIGNMENT_DELAY 32'd0;
	rg_out_c <= `BSV_ASSIGNMENT_DELAY 32'd0;
	valid_a_b <= `BSV_ASSIGNMENT_DELAY 1'd0;
      end
    else
      begin
        if (rg_out_a$EN) rg_out_a <= `BSV_ASSIGNMENT_DELAY rg_out_a$D_IN;
	if (rg_out_b$EN) rg_out_b <= `BSV_ASSIGNMENT_DELAY rg_out_b$D_IN;
	if (rg_out_c$EN) rg_out_c <= `BSV_ASSIGNMENT_DELAY rg_out_c$D_IN;
	if (valid_a_b$EN) valid_a_b <= `BSV_ASSIGNMENT_DELAY valid_a_b$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    rg_out_a = 32'hAAAAAAAA;
    rg_out_b = 32'hAAAAAAAA;
    rg_out_c = 32'hAAAAAAAA;
    valid_a_b = 1'h0;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mk_pe
