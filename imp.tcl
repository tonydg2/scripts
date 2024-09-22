# !! NOTE!! This will only work with RMs/RPs as hardcoded below. Manual script to aid in debugging
# or remembering all the loops in the automated branch. Works, but meant only for reference.


#--------------------------------------------------------------------------------------------------
# proc for P&R commands
#--------------------------------------------------------------------------------------------------
proc place_n_route {name} {
  opt_design
  place_design
  phys_opt_design
  route_design
  # update git hash for every config, TODO: add catch for instance existance
  #set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*]
  #source ./load_git_hash.tcl
  #report_timing_summary -file $dcpDir/timing_summary_$name.rpt
}

#--------------------------------------------------------------------------------------------------
# main script 
#--------------------------------------------------------------------------------------------------

set rmDir     [lindex $argv 0]
set dcpDir    [lindex $argv 1]
set outputDir [lindex $argv 2]
set buildTime [lindex $argv 3]

#--------------------------------------------------------------------------------------------------

# first build a full config with all RPs populated
open_checkpoint $dcpDir/static_synth.dcp
read_checkpoint -cell led_cnt_pr_inst $rmDir/RM0/RM0_post_synth_led_cnt_A.dcp
read_checkpoint -cell led_cnt2_pr_inst $rmDir/RM1/RM1_post_synth_led_cnt2_A.dcp
read_checkpoint -cell led_cnt3_pr_inst $rmDir/RM2/RM2_post_synth_led_cnt3_A.dcp
# all RPs now populated
place_n_route "congig_A"
set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*]                  
source ./load_git_hash.tcl                                                             
set_property BITSTREAM.CONFIG.USR_ACCESS $buildTime [current_design]                   
write_checkpoint -force $dcpDir/config_A.dcp
report_timing_summary -file $dcpDir/timing_summary_config_A.rpt
write_bitstream -force -no_partial_bitfile $outputDir/bit/config_A.bit
write_bitstream -force -cell led_cnt_pr_inst  $outputDir/bit/RM0/led_cnt_A_partial.bit
write_bitstream -force -cell led_cnt2_pr_inst $outputDir/bit/RM1/led_cnt2_A_partial.bit
write_bitstream -force -cell led_cnt3_pr_inst $outputDir/bit/RM2/led_cnt3_A_partial.bit

# now replace RPs with alternate RMs. only to get partials, don't bother with full config
update_design -cell led_cnt_pr_inst -black_box
read_checkpoint -cell led_cnt_pr_inst $rmDir/RM0/RM0_post_synth_led_cnt_B.dcp
update_design -cell led_cnt2_pr_inst -black_box
read_checkpoint -cell led_cnt2_pr_inst $rmDir/RM1/RM1_post_synth_led_cnt2_B.dcp
place_n_route "congig_B"
write_bitstream -force -cell led_cnt_pr_inst  $outputDir/bit/RM0/led_cnt_B_partial.bit
write_bitstream -force -cell led_cnt2_pr_inst $outputDir/bit/RM1/led_cnt2_B_partial.bit

# replace RP again for last partial needed
update_design -cell led_cnt_pr_inst -black_box
read_checkpoint -cell led_cnt_pr_inst $rmDir/RM0/RM0_post_synth_led_cnt_C.dcp
place_n_route "congig_C"
write_bitstream -force -cell led_cnt_pr_inst  $outputDir/bit/RM0/led_cnt_C_partial.bit

# now get full static with empty RPs
update_design -cell led_cnt_pr_inst -black_box
update_design -cell led_cnt2_pr_inst -black_box
update_design -cell led_cnt3_pr_inst -black_box
lock_design -level routing                                                        
set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*]                  
source ./load_git_hash.tcl                                                             
set_property BITSTREAM.CONFIG.USR_ACCESS $buildTime [current_design]                   
write_bitstream   -force -no_partial_bitfile $outputDir/bit/static ;# static with empty RPs 
write_checkpoint  -force $dcpDir/static_route.dcp ;# static with empty RPs 
report_timing_summary -file $dcpDir/timing_summary_static_route.rpt


# this may need updates - what if ILAs inside RPs...?
write_debug_probes  -force $outputDir/ila_probes

# what if RPs include AXI I/Fs? difference between static and configs? Shouldn't be...
write_hw_platform   -fixed -force $outputDir/platform.xsa




