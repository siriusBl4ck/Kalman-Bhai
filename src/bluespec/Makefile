
default:
	@echo "To compile and simulate Mat mult, run make mat_mult"
	@echo "To compile and simulate PE, run make pe"
	@echo "To compile KalmanAlgo.bsv, run make kalman"

kalman:
	bsc -verilog -vdir verilog -bdir bsv_build -u tb/tb_top_module.bsv 
	bsc -vdir verilog -e mk_tb_top_module -u verilog/mk_tb_top_module.v
	timeout 10 ./a.out > test.log

mat_mult: 
	@echo "Compiling tb_mat_mult.bsv..."
	bsc -verilog -vdir verilog -bdir bsv_build -u tb/tb_mult.bsv
	bsc -vdir verilog -e mk_tb_mult -u verilog/mk_tb_mult.v
	./a.out

pe:
	@echo "Compiling pe_tb.bsv..."
	bsc -verilog -vdir verilog -bdir bsv_build -u tb/pe_tb.bsv
	bsc -vdir verilog -e mk_tb_pe -u verilog/mk_pe.v 
	./a.out

mat_inv:
	@echo "Compiling tb_new_mat_inv.bsv..."
	bsc -verilog -vdir verilog -bdir bsv_build -u tb/tb_new_mat_inv.bsv
	bsc -vdir verilog -e mkTb_new_mat_inv -u verilog/mkTb_new_mat_inv.v 
	./a.out

clean:
	rm verilog/* bsv_build/* a.out
	rm -rf web* xsim* xel* .Xil
	rm *.tcl *.wdb
