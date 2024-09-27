# notes 
# dcp folder

pr_subdivide

report_property [get_cells led_cnt_top_inst]

#----------------------------------------------------------------------------------------------
read_verilog ../../hdl/common/led_cnt.sv 
read_verilog ../../hdl/led_cnt_A.sv 
synth_design -mode out_of_context -top led_cnt_pr -part xczu3eg-sbva484-1-i
write_checkpoint cnt_A_synth.dcp

read_verilog ../../hdl/zOFF_RM0/led_cnt_C.sv 
synth_design -mode out_of_context -top led_cnt_pr -part xczu3eg-sbva484-1-i
write_checkpoint cnt_C_synth.dcp

read_verilog ../../hdl/zOFF_RM1/led_cnt2_A.sv 
synth_design -mode out_of_context -top led_cnt2_pr -part xczu3eg-sbva484-1-i
write_checkpoint cnt2_A_synth.dcp

read_verilog ../../hdl/zOFF_RM1/led_cnt2_C.sv
synth_design -mode out_of_context -top led_cnt2_pr -part xczu3eg-sbva484-1-i
write_checkpoint cnt2_C_synth.dcp

read_verilog ../../hdl/led_cnt_top_A.sv 
synth_design -mode out_of_context -top led_cnt_top -part xczu3eg-sbva484-1-i
write_checkpoint cnt_top_A_synth.dcp

#----------------------------------------------------------------------------------------------
read_verilog ../../hdl/common/led_cnt.sv 
read_verilog ../../hdl/led_cnt_A.sv 
read_verilog ../../hdl/led_cnt2_A.sv 
read_verilog ../../hdl/led_cnt_top_A.sv 
synth_design -mode out_of_context -top led_cnt_top -part xczu3eg-sbva484-1-i
write_checkpoint cnt_top_A_synth2.dcp


#----------------------------------------------------------------------------------------------
open_checkpoint static_synth.dcp
set_property HD.RECONFIGURABLE true [get_cells led_cnt_top_inst]
  opt_design
  place_design
  phys_opt_design
  route_design
write_checkpoint static_route2.dcp 

#open_checkpoint cnt_top_A_synth.dcp


open_checkpoint static_route2.dcp 
pr_subdivide -cell led_cnt_top_inst -subcells {led_cnt_top_inst/led_cnt2_pr_inst led_cnt_top_inst/led_cnt_pr_inst} cnt_top_A_synth2.dcp
  opt_design;place_design;phys_opt_design;route_design




open_checkpoint static_route.dcp 
set_property HD.RECONFIGURABLE true [get_cells led_cnt_top_inst]
update_design -cell led_cnt_top_inst -black_box
read_checkpoint -cell led_cnt_top_inst cnt_top_A_synth.dcp
  opt_design
  place_design
  phys_opt_design
  route_design




open_checkpoint static_route.dcp 
set_property HD.RECONFIGURABLE true [get_cells led_cnt_top_inst]
pr_subdivide -cell led_cnt_top_inst -subcells {led_cnt_pr_inst led_cnt2_pr_inst} cnt_top_A_synth.dcp

 



#set_property HD.RECONFIGURABLE true [get_cells led_cnt_top_inst/led_cnt_pr_inst]
#set_property HD.RECONFIGURABLE true [get_cells led_cnt_top_inst/led_cnt2_pr_inst]
