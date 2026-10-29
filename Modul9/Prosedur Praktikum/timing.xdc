# 1. Definisi Clock 100 MHz (Periode 10 ns)
create_clock -period 10.000 -name sys_clk [get_ports clk]

# 2. Constraint Input (Port a dan b)
set_input_delay -clock sys_clk 2.000 [get_ports {a[*] b[*]}]

# 3. Constraint Output (Port result)
set_output_delay -clock sys_clk 2.000 [get_ports {result[*]}]