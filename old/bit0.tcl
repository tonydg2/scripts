# bitstream gen
# Args passed in for this script: $TOP_ENTITY $outputDir $rpCell
set topEntity [lindex $argv 0]
set outputDir [lindex $argv 1]
set rpCell    [lindex $argv 2]

open_checkpoint $outputDir/static_route_UPDATED.dcp
write_bitstream -force $outputDir/config1

open_checkpoint $outputDir/config2_routed.dcp
write_bitstream -force -cell $rpCell $outputDir/RM_led_cnt_B_partial.bit

write_debug_probes -force $outputDir/$topEntity  ;#

write_hw_platform -fixed -force $outputDir/$topEntity.xsa



#--------------------------------------------------------------------------------------------------
# full configuration ONLY, partial RM is included as this is a full configuration, but this
#   won't generate the partial bitsream with it:
# >write_bitstream -no_partial_bitfile config1


# Static only bitstream
# run write_bitstream on the checkpoint that has empty RPs (after update_design -black_box and 
#   update_design -buffer_ports have run)
# UG909
