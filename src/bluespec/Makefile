
default:
	@echo "To compile and simulate Mat mult, run make mat_mult"
	@echo "To compile and simulate PE, run make pe"

mat_mult: 
	@echo "Compiling tb_mat_mult.bsv..."
	bsc -verilog -vdir verilog -bdir bsv_build -D VERBOSE -u tb/tb_mat_mult.bsv
	bsc -vdir verilog -e tb_mat_mult -u verilog/tb_mat_mult.v
	./a.out

pe:
	@echo "Compiling pe_tb.bsv..."
	bsc -verilog -vdir verilog -bdir bsv_build -u tb/pe_tb.bsv
	bsc -vdir verilog -e mk_tb_pe -u verilog/mk_pe.v 
	./a.out

clean:
	rm verilog/* bsv_build/* a.out