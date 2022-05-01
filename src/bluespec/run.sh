bsc -verilog -vdir verilog -bdir src -u tb/pe_tb.bsv
echo "************"
bsc -vdir verilog -e mk_tb_pe -u verilog/mk_tb_pe.v
echo "************"
echo "SIMULATION_START"
./a.out
echo "SIMULATION_END"