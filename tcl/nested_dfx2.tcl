#----------------------------------------------------------------------------------------------
# get full static with cnt_top set as blackbox and reconfigurable
  # temp modified syn.tcl
  # static_synth.dcp
#----------------------------------------------------------------------------------------------
# synth cnt_top OOC full with both child modules

set partNum "xczu3eg-sbva484-1-i"
set_part $partNum
read_verilog ../../hdl/common/led_cnt.sv 
read_verilog ../../hdl/led_cnt_A.sv 
read_verilog ../../hdl/led_cnt2_A.sv 
read_verilog ../../hdl/led_cnt_top_A.sv 
synth_design -mode out_of_context -top led_cnt_top -part $partNum
write_checkpoint cnt_TOP_A_synth.dcp

#----------------------------------------------------------------------------------------------
# synth cnt_top OOC full with BLACKBOX child modules

set partNum "xczu3eg-sbva484-1-i"
set_part $partNum
read_verilog ../../hdl/led_cnt_top_A.sv 
synth_design -mode out_of_context -top led_cnt_top -part $partNum
write_checkpoint cnt_TOP_A_synth_BlackBox.dcp

#----------------------------------------------------------------------------------------------
#assemble static with cnt_top and imp

open_checkpoint static_synth.dcp
read_checkpoint -cell led_cnt_top_inst cnt_TOP_A_synth.dcp
  opt_design
  place_design
  phys_opt_design
  route_design

write_checkpoint static_cnt_TOP.dcp

#----------------------------------------------------------------------------------------------
open_checkpoint static_cnt_TOP.dcp
pr_subdivide -cell led_cnt_top_inst -subcells {led_cnt_top_inst/led_cnt2_pr_inst led_cnt_top_inst/led_cnt_pr_inst} cnt_TOP_A_synth_BlackBox.dcp
read_checkpoint -cell led_cnt_top_inst/led_cnt2_pr_inst cnt2_A_synth.dcp 
read_checkpoint -cell led_cnt_top_inst/led_cnt_pr_inst cnt_A_synth.dcp 
read_xdc ../../xdc/dfx_cnt.xdc
  opt_design
  place_design
  route_design
write_checkpoint cnt_TOP_A_cntA_cnt2A_routed.dcp
# SUCCESS 1st config.

#----------------------------------------------------------------------------------------------
update_design -black_box -cell led_cnt_top_inst/led_cnt2_pr_inst
update_design -black_box -cell led_cnt_top_inst/led_cnt_pr_inst
#lock_design -level routing
#write_checkpoint top_cnt_static.dcp
read_checkpoint -cell led_cnt_top_inst/led_cnt2_pr_inst cnt2_C_synth.dcp 
read_checkpoint -cell led_cnt_top_inst/led_cnt_pr_inst cnt_C_synth.dcp 
#dont need to read xdc, already in from first config
  opt_design
  place_design
  route_design
write_checkpoint cnt_TOP_A_cntC_cnt2C_routed.dcp
# SUCCESS 2nd config.

#----------------------------------------------------------------------------------------------
# full bit, and two lower level partials cnt_A and cnt2_A
open_checkpoint cnt_TOP_A_cntA_cnt2A_routed.dcp
write_bitstream BIT_AAA/configAAA
# SUCCESS
#----------------------------------------------------------------------------------------------
# full bit, and two lower level partials cnt_C and cnt2_C
open_checkpoint cnt_TOP_A_cntC_cnt2C_routed.dcp
write_bitstream BIT_ACC/configACC
# SUCCESS
#----------------------------------------------------------------------------------------------
# upper partial of cnt top containing cnt_A and cnt2_A
open_checkpoint cnt_TOP_A_cntA_cnt2A_routed.dcp
pr_recombine -cell led_cnt_top_inst
# no need for full bitstream, as it was already generated above at AAA
write_bitstream -cell led_cnt_top_inst BIT_AAA/cnt_top_AAA_partial.bit
# SUCCESS
#----------------------------------------------------------------------------------------------
# upper partial of cnt top containing cnt_C and cnt2_C
open_checkpoint cnt_TOP_A_cntC_cnt2C_routed.dcp
pr_recombine -cell led_cnt_top_inst
# no need for full bitstream, as it was already generated above at ACC
write_bitstream -cell led_cnt_top_inst BIT_ACC/cnt_top_ACC_partial.bit
# SUCCESS

