source "helpers.tcl"
source "flow_helpers.tcl"
source "sky130hd/sky130hd.vars"


source "helpers.tcl"
source "flow_helpers.tcl"
source "sky130hd/sky130hd.vars"
set synth_verilog "uart_netlist.v"
set design "uart"
set top_module "uart"
set sdc_file "uart_sky130.sdc"
# --- Adjusted Area for Efficient Layout ---

# UART design area targeting ~70% utilization
set die_area  {0 0 110 110}
set core_area {5 5  95 95}


include -echo "flow.tcl"



