# bitstream gen
# Args passed in for this script: $TOP_ENTITY $outputDir $rpCell
set topEntity [lindex $argv 0]
set outputDir [lindex $argv 1]
set rpCell    [lindex $argv 2]

# generating bitstream for static will still provide an 'empty' RP bitsream in addition to the 
# empty full static bitsream
open_checkpoint $outputDir/static_route.dcp
#set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
#write_bitstream -force $outputDir/static ;# includes full static and 'empty' RP bitsreams
write_bitstream -no_partial_bitfile $outputDir/static ;# full static only


open_checkpoint $outputDir/config_1_routed.dcp
#write_bitstream -force $outputDir/config1 ;# full config1 and partial RP
write_bitstream -force -no_partial_bitfile $outputDir/config1
# do these commands separately to give custom name for partial
write_bitstream -force -cell $rpCell $outputDir/RM_led_cnt_A_partial.bit

open_checkpoint $outputDir/config_2_routed.dcp
write_bitstream -force -no_partial_bitfile $outputDir/config2
write_bitstream -force -cell $rpCell $outputDir/RM_led_cnt_B_partial.bit


#  open_checkpoint $outputDir/config2_routed.dcp
#  write_bitstream -force -cell $rpCell $outputDir/RM_led_cnt_B_partial.bit




write_debug_probes  -force $outputDir/$topEntity
write_hw_platform   -fixed -force $outputDir/$topEntity.xsa



#--------------------------------------------------------------------------------------------------
# full configuration ONLY, partial RM is included as this is a full configuration, but this
#   won't generate the partial bitsream with it:
# >write_bitstream -no_partial_bitfile config1

# partial only
# >write_bitstream -force -cell $rpCell config1_partial

# Static only bitstream
# run write_bitstream on the checkpoint that has empty RPs (after update_design -black_box and 
#   update_design -buffer_ports have run)
# UG909
