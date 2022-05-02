if echo $* | grep -e "-v" -q
then
    bsc -verilog -vdir verilog -bdir src -u tb/tb_mat_mult.bsv
    echo "************"
else
    bsc -verilog -vdir verilog -bdir src -u tb/tb_mat_mult.bsv
    echo "************"
    bsc -vdir verilog -e tb_mat_mult -u verilog/tb_mat_mult.v
    echo "************"
    echo "SIMULATION_START"
    ./a.out
    echo "SIMULATION_END"
fi