//
// Generated by Bluespec Compiler, version 2021.12.1-27-g9a7d5e05 (build 9a7d5e05)
//
// On Sun May  1 12:21:58 IST 2022
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
// CLK                            I     1 clock
// RST_N                          I     1 reset
// putA_in_a                      I    32
// putB_in_b                      I    32
// EN_putA                        I     1
// EN_putB                        I     1
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
	     RDY_getC);
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

  // signals for module outputs
  wire [31 : 0] getA, getB, getC;
  wire RDY_getA, RDY_getB, RDY_getC, RDY_putA, RDY_putB;

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

  // rule scheduling signals
  wire WILL_FIRE_RL_mac;

  // declarations used by system tasks
  // synopsys translate_off
  reg [63 : 0] v__h794;
  reg [63 : 0] v__h885;
  reg [63 : 0] v__h484;
  // synopsys translate_on

  // remaining internal signals
  wire [63 : 0] IF_IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0_ETC___d28,
		x__h565;
  wire [32 : 0] x__h539;
  wire [31 : 0] IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0___d11,
		IF_wr_in_b_whas__3_THEN_wr_in_b_wget__4_ELSE_0___d15,
		x__h648,
		x__h668;
  wire [16 : 0] in1_i__h547, in2_i__h694;
  wire [15 : 0] rg_out_c_BITS_31_TO_16__q1, x65_BITS_47_TO_32__q2;

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

  // rule RL_mac
  assign WILL_FIRE_RL_mac = EN_putA && EN_putB ;

  // register rg_out_a
  assign rg_out_a$D_IN = IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0___d11 ;
  assign rg_out_a$EN = 1'd1 ;

  // register rg_out_b
  assign rg_out_b$D_IN =
	     IF_wr_in_b_whas__3_THEN_wr_in_b_wget__4_ELSE_0___d15 ;
  assign rg_out_b$EN = 1'd1 ;

  // register rg_out_c
  assign rg_out_c$D_IN = x__h539[31:0] ;
  assign rg_out_c$EN = WILL_FIRE_RL_mac ;

  // remaining internal signals
  assign IF_IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0_ETC___d28 =
	     x__h648 * x__h668 ;
  assign IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0___d11 =
	     EN_putA ? putA_in_a : 32'd0 ;
  assign IF_wr_in_b_whas__3_THEN_wr_in_b_wget__4_ELSE_0___d15 =
	     EN_putB ? putB_in_b : 32'd0 ;
  assign in1_i__h547 = { x65_BITS_47_TO_32__q2[15], x65_BITS_47_TO_32__q2 } ;
  assign in2_i__h694 =
	     { rg_out_c_BITS_31_TO_16__q1[15], rg_out_c_BITS_31_TO_16__q1 } ;
  assign rg_out_c_BITS_31_TO_16__q1 = rg_out_c[31:16] ;
  assign x65_BITS_47_TO_32__q2 = x__h565[47:32] ;
  assign x__h539 =
	     { in1_i__h547, x__h565[31:16] } +
	     { in2_i__h694, rg_out_c[15:0] } ;
  assign x__h565 =
	     (IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0___d11[31] &&
	      !IF_wr_in_b_whas__3_THEN_wr_in_b_wget__4_ELSE_0___d15[31] ||
	      IF_wr_in_b_whas__3_THEN_wr_in_b_wget__4_ELSE_0___d15[31] &&
	      !IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0___d11[31]) ?
	       -IF_IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0_ETC___d28 :
	       IF_IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0_ETC___d28 ;
  assign x__h648 =
	     IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0___d11[31] ?
	       (EN_putA ? -putA_in_a : 32'd0) :
	       IF_wr_in_a_whas_THEN_wr_in_a_wget__0_ELSE_0___d11 ;
  assign x__h668 =
	     IF_wr_in_b_whas__3_THEN_wr_in_b_wget__4_ELSE_0___d15[31] ?
	       (EN_putB ? -putB_in_b : 32'd0) :
	       IF_wr_in_b_whas__3_THEN_wr_in_b_wget__4_ELSE_0___d15 ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        rg_out_a <= `BSV_ASSIGNMENT_DELAY 32'd0;
	rg_out_b <= `BSV_ASSIGNMENT_DELAY 32'd0;
	rg_out_c <= `BSV_ASSIGNMENT_DELAY 32'd0;
      end
    else
      begin
        if (rg_out_a$EN) rg_out_a <= `BSV_ASSIGNMENT_DELAY rg_out_a$D_IN;
	if (rg_out_b$EN) rg_out_b <= `BSV_ASSIGNMENT_DELAY rg_out_b$D_IN;
	if (rg_out_c$EN) rg_out_c <= `BSV_ASSIGNMENT_DELAY rg_out_c$D_IN;
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
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_putA)
	begin
	  v__h794 = $time;
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_putA) $display(v__h794, " [MAC] method reached, putA\n");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_putB)
	begin
	  v__h885 = $time;
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_putB) $display(v__h885, " [MAC] method reached, putA\n");
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_mac)
	begin
	  v__h484 = $time;
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_mac)
	$display(v__h484, " [MAC] rule reached, performing compute\n");
  end
  // synopsys translate_on
endmodule  // mk_pe

