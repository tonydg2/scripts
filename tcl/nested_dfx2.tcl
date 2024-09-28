#----------------------------------------------------------------------------------------------
# get full static with cnt_top set as blackbox and reconfigurable
  # temp modified syn.tcl
  # static_synth.dcp
#----------------------------------------------------------------------------------------------
set partNum "xczu3eg-sbva484-1-i" ;
set_part $partNum ;

read_verilog ../../hdl/common/led_cnt.sv ;
read_verilog ../../hdl/led_cnt_A.sv ;
synth_design -mode out_of_context -top led_cnt_pr -part xczu3eg-sbva484-1-i ;
write_checkpoint cnt_A_synth.dcp ;

read_verilog ../../hdl/zOFF_RM0/led_cnt_C.sv ;
synth_design -mode out_of_context -top led_cnt_pr -part xczu3eg-sbva484-1-i ;
write_checkpoint cnt_C_synth.dcp ;

read_verilog ../../hdl/zOFF_RM1/led_cnt2_A.sv ;
synth_design -mode out_of_context -top led_cnt2_pr -part xczu3eg-sbva484-1-i ;
write_checkpoint cnt2_A_synth.dcp ;

read_verilog ../../hdl/zOFF_RM1/led_cnt2_C.sv ;
synth_design -mode out_of_context -top led_cnt2_pr -part xczu3eg-sbva484-1-i ;
write_checkpoint cnt2_C_synth.dcp ;
# SUCCESS

#----------------------------------------------------------------------------------------------
# synth cnt_top OOC full with both child modules

set partNum "xczu3eg-sbva484-1-i";
set_part $partNum;
read_verilog ../../hdl/common/led_cnt.sv ;
read_verilog ../../hdl/led_cnt_top_A.sv ;
read_verilog ../../hdl/led_cnt_A.sv ;
read_verilog ../../hdl/led_cnt2_A.sv ;
synth_design -mode out_of_context -top led_cnt_top -part $partNum;
write_checkpoint cnt_TOP_A_synth.dcp;
# SUCCESS
#----------------------------------------------------------------------------------------------
# synth cnt_top OOC full with BLACKBOX child modules

set partNum "xczu3eg-sbva484-1-i";
set_part $partNum;
read_verilog ../../hdl/led_cnt_top_A.sv ;
synth_design -mode out_of_context -top led_cnt_top -part $partNum;
write_checkpoint cnt_TOP_A_synth_BlackBox.dcp;
# SUCCESS


#----------------------------------------------------------------------------------------------
#assemble static with cnt_top and imp

open_checkpoint static_synth.dcp;
read_checkpoint -cell led_cnt_top_inst cnt_TOP_A_synth.dcp;
  opt_design;
  place_design;
  route_design;

write_checkpoint static_cnt_TOP.dcp;
# SUCCESS
#----------------------------------------------------------------------------------------------
open_checkpoint static_cnt_TOP.dcp;
pr_subdivide -cell led_cnt_top_inst -subcells {led_cnt_top_inst/led_cnt2_pr_inst led_cnt_top_inst/led_cnt_pr_inst} cnt_TOP_A_synth_BlackBox.dcp;
read_checkpoint -cell led_cnt_top_inst/led_cnt2_pr_inst cnt2_A_synth.dcp ;
read_checkpoint -cell led_cnt_top_inst/led_cnt_pr_inst cnt_A_synth.dcp ;
read_xdc ../../xdc/dfx_cnt.xdc;
  opt_design;
  place_design;
  route_design;
write_checkpoint cnt_TOP_A_cntA_cnt2A_routed.dcp;
# SUCCESS 1st config.

#----------------------------------------------------------------------------------------------
# continue or open cnt_TOP_A_cntA_cnt2A_routed.dcp
update_design -black_box -cell led_cnt_top_inst/led_cnt2_pr_inst;
update_design -black_box -cell led_cnt_top_inst/led_cnt_pr_inst;
#lock_design -level routing
#write_checkpoint top_cnt_static.dcp
read_checkpoint -cell led_cnt_top_inst/led_cnt2_pr_inst cnt2_C_synth.dcp ;
read_checkpoint -cell led_cnt_top_inst/led_cnt_pr_inst cnt_C_synth.dcp ;
#dont need to read xdc, already in from first config
  opt_design;
  place_design;
  route_design;
write_checkpoint cnt_TOP_A_cntC_cnt2C_routed.dcp;
# SUCCESS 2nd config.

#----------------------------------------------------------------------------------------------
# full bit, and two lower level partials cnt_A and cnt2_A
open_checkpoint cnt_TOP_A_cntA_cnt2A_routed.dcp;
file mkdir BIT_AAA;
write_bitstream BIT_AAA/configAAA;
write_hw_platform -fixed -force AAA_platform.xsa;

# SUCCESS
#----------------------------------------------------------------------------------------------
# full bit, and two lower level partials cnt_C and cnt2_C
open_checkpoint cnt_TOP_A_cntC_cnt2C_routed.dcp;
file mkdir BIT_ACC;
write_bitstream BIT_ACC/configACC;
# SUCCESS
#----------------------------------------------------------------------------------------------
# upper partial of cnt top containing cnt_A and cnt2_A
open_checkpoint cnt_TOP_A_cntA_cnt2A_routed.dcp;
pr_recombine -cell led_cnt_top_inst;
# no need for full bitstream, as it was already generated above at AAA
write_bitstream -cell led_cnt_top_inst BIT_AAA/cnt_top_AAA_partial.bit;
# SUCCESS
#----------------------------------------------------------------------------------------------
# upper partial of cnt top containing cnt_C and cnt2_C
open_checkpoint cnt_TOP_A_cntC_cnt2C_routed.dcp;
pr_recombine -cell led_cnt_top_inst;
# no need for full bitstream, as it was already generated above at ACC
write_bitstream -cell led_cnt_top_inst BIT_ACC/cnt_top_ACC_partial.bit;
# SUCCESS

#----------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------
# synth cnt_top OOC full with BLACKBOX child modules

set partNum "xczu3eg-sbva484-1-i";
set_part $partNum;
read_verilog ../../hdl/zOFF_cnt_top/led_cnt_top_B.sv ;
synth_design -mode out_of_context -top led_cnt_top -part $partNum;
write_checkpoint cnt_TOP_B_synth_BlackBox.dcp;
# SUCCESS

#----------------------------------------------------------------------------------------------
open_checkpoint static_cnt_TOP.dcp;
pr_subdivide -cell led_cnt_top_inst -subcells {led_cnt_top_inst/led_cnt2_pr_inst led_cnt_top_inst/led_cnt_pr_inst} cnt_TOP_B_synth_BlackBox.dcp;
read_checkpoint -cell led_cnt_top_inst/led_cnt2_pr_inst cnt2_A_synth.dcp ;
read_checkpoint -cell led_cnt_top_inst/led_cnt_pr_inst cnt_A_synth.dcp ;
read_xdc ../../xdc/dfx_cnt.xdc;
  opt_design;
  place_design;
  route_design;
write_checkpoint cnt_TOP_B_cntA_cnt2A_routed.dcp;
# SUCCESS

#----------------------------------------------------------------------------------------------
# only get one upper partial of top cnt B, already have all lower partials from above
open_checkpoint cnt_TOP_B_cntA_cnt2A_routed.dcp;
pr_recombine -cell led_cnt_top_inst;
# no need for full bitstream, as it was already generated above at AAA
file mkdir BIT_BAA;
write_bitstream -cell led_cnt_top_inst BIT_BAA/cnt_top_BAA_partial.bit;

# SUCCESS
