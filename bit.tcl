# bitstream gen
# TODO: arg to create all configs, or static only, which RMs, etc...
# Args passed in for this script: $TOP_ENTITY $outputDir $rpCell
set topEntity [lindex $argv 0]
set outputDir [lindex $argv 1]
set rpCell    [lindex $argv 2]
set RMs       [lindex $argv 3]
set buildTime [lindex $argv 4]
set dcpDir    [lindex $argv 5]

open_checkpoint $dcpDir/static_route.dcp
set_property BITSTREAM.CONFIG.USR_ACCESS $buildTime [current_design]
write_bitstream -force -no_partial_bitfile $outputDir/static ;# full static only

# Only create full bitsream for first config
set idx 1;
foreach x $RMs {
  if {$idx==1} {
    open_checkpoint $dcpDir/config_$idx\_routed.dcp
    set_property BITSTREAM.CONFIG.USR_ACCESS $buildTime [current_design]
    write_bitstream -force -no_partial_bitfile $outputDir/config_$idx
    write_bitstream -force -cell $rpCell $outputDir/$x\_partial.bit
    incr idx
  } else {
    open_checkpoint $dcpDir/config_$idx\_routed.dcp
    write_bitstream -force -cell $rpCell $outputDir/$x\_partial.bit
    incr idx
  }
}

# this may need update
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
