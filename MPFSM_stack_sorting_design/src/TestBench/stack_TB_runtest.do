SetActiveLib -work
comp -include "$dsn\src\Stack.vhd" 
comp -include "$dsn\src\TestBench\stack_TB.vhd" 
asim +access +r TESTBENCH_FOR_stack 
wave 
wave -noreg clk
wave -noreg enabled
wave -noreg read_write
wave -noreg write_data_port
wave -noreg read_data_port
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\stack_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_stack 
