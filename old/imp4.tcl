# implementation
# required DCPs:  $dcpDir/static_synthsynth.dcp
#                 $rmDir/post_synth_$x.dcp (all RMs)
#
# Args passed in for this script: $RMs(list) $rmDir $dcpDir $rpCell

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

set RMs       [lindex $argv 0]
set rmDir     [lindex $argv 1]
set dcpDir    [lindex $argv 2]
set rpCell    [lindex $argv 3]
set RPs       [lindex $argv 4]
set RPlen     [lindex $argv 5]
set outputDir [lindex $argv 6]
set buildTime [lindex $argv 7]


if {$RMs==""} {set DFXrun false} else {set DFXrun true}
#--------------------------------------------------------------------------------------------------

# This is looping through to generate all partial bitstreams only. This can be skipped if only static is desired or other config...
# need to loop through and read_checkpoint for ALL RP instances, i.e., something needs to be in each RP
for {set idx 0} {$idx <$RPlen} {incr idx} {
  set curRPdir  [lindex $RPs [expr 2*$idx]]
  set curRPmod  [lindex $RPs [expr 2*$idx + 1]]
  set curRMs    [lindex $RMs [expr 2*$idx + 1]]
  set curRPinst "$curRPmod\_inst"
  puts "\n*** Running P&R $curRPdir, RP inst $curRPmod, with RMs: $curRMs ***\n"
  foreach x $curRMs {
    open_checkpoint $dcpDir/static_synth.dcp                                         
    #set_property HD.RECONFIGURABLE true [get_cells $curRPinst]                       
    read_checkpoint -cell $curRPinst $rmDir/$curRPdir/$curRPdir\_post_synth_[file rootname $x].dcp   
    place_n_route "$x\_$idx"                                                         
    write_bitstream -force -cell $curRPinst $outputDir/$curRPdir\_$x\_partial.bit    
    #write_checkpoint -force $dcpDir/config_$idx\_routed.dcp                          
  }
}

# one full config... how to select which, default first RM in each RP...
# start with default
if {$DFXrun} {
  puts "DFX IMPLEMENTATION FULL CONFIG"
  open_checkpoint $dcpDir/static_synth.dcp
  # looping through to have one full config. so a single RM for each RP
  set cfgName "CONFIG"
  for {set idx 0} {$idx <$RPlen} {incr idx} {
    set curRPdir  [lindex $RPs [expr 2*$idx]]
    set curRPmod  [lindex $RPs [expr 2*$idx + 1]]
    set curRMs    [lindex $RMs [expr 2*$idx + 1]] ;# these are filenames with .sv!!
    set curRPinst "$curRPmod\_inst"
    set cfgRM [file rootname [lindex $curRMs 0]] ;# not looping through RMs for each RP, only grabbing the first one for this 'default' config. need another way to have user selectable
    #set_property HD.RECONFIGURABLE true [get_cells $curRPinst]                          
    read_checkpoint -cell $curRPinst $rmDir/$curRPdir/$curRPdir\_post_synth_$cfgRM.dcp  
    append cfgName "-$curRPdir\_$cfgRM"
  }
  # config has been assembled
  place_n_route $cfgName                                                                  
  set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*]                  
  source ./load_git_hash.tcl                                                             
  set_property BITSTREAM.CONFIG.USR_ACCESS $buildTime [current_design]                   
  write_checkpoint -force $dcpDir/$cfgName                                                
  write_bitstream -force -no_partial_bitfile $outputDir/$cfgName                          
  foreach {ignore RPmod} $RPs {
    update_design -cell "$RPmod\_inst" -black_box               
  }
  lock_design       -level routing                                                        
} else { ;# non-DFX                                                                       
  puts "NON-DFX IMPLEMENTATION"
  open_checkpoint $dcpDir/static_synth.dcp                                                
  place_n_route "static"                                                                  
}

#--------------------------------------------------------------------------------------------------
# If DFX, at least one full configuration, and empty static...
#if {$DFXrun} {
#  open_checkpoint $dcpDir/config_1_routed.dcp 
#  update_design     -cell $rpCell -black_box  
#  lock_design       -level routing            
#} else {
#  open_checkpoint $dcpDir/static_synth.dcp    
#  place_n_route "static"                      
#}

report_timing_summary -file $dcpDir/timing_summary_static_route.rpt
#report_timing -sort_by group -max_paths 100 -path_type summary -file $dcpDir/static_route_timing.rpt
#report_clock_utilization   -file $dcpDir/static_route_clk_util.rpt
#report_utilization         -file $dcpDir/static_route_post_route_util.rpt
#report_power               -file $dcpDir/static_route_power.rpt
#report_drc                 -file $dcpDir/static_route_drc.rpt

set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*]                  
source ./load_git_hash.tcl                                                             
set_property BITSTREAM.CONFIG.USR_ACCESS $buildTime [current_design]                   
write_bitstream   -force -no_partial_bitfile $outputDir/static                            
write_checkpoint  -force $dcpDir/static_route.dcp ;# complete checkpoint if non-DFX run 


#  open_checkpoint $dcpDir/post_route.dcp ;# should this be static_route?
#  set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*] ;# do this on the the first (post_route/config1) so later will be based on it...
#  source ./load_git_hash.tcl
#  # this is just config1 updated with githash, need to do this with static too.
#  # need to do this with static and ALL configs... or they won't have the githash...
#  write_checkpoint -force $dcpDir/static_route_UPDATED.dcp ;



