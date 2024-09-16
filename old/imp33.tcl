# implementation
# required DCPs:  $dcpDir/static_synthsynth.dcp
#                 $rmDir/post_synth_$x.dcp (all RMs)
#
# Args passed in for this script: $RMs(list) $rmDir $dcpDir $rpCell
set RMs     [lindex $argv 0]
set rmDir   [lindex $argv 1]
set dcpDir  [lindex $argv 2]
set rpCell  [lindex $argv 3]

# open full static region synth checkpoint
open_checkpoint $dcpDir/static_synth.dcp

# RP cell in static region
set_property HD.RECONFIGURABLE true [get_cells $rpCell]

set idx 1;
foreach x $RMs {
  if {$idx==1} {
    # read RM synth checkpoint
    read_checkpoint -cell $rpCell $rmDir/RM_post_synth_$x.dcp
    opt_design
    place_design
    phys_opt_design
    route_design
    
    set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*]
    source ./load_git_hash.tcl

#    write_checkpoint  -force $dcpDir/post_route.dcp  ;#this is config1 (includes RM)
    write_checkpoint  -force $dcpDir/config_$idx\_routed.dcp  ;#this is config1 (includes RM)
    #write_checkpoint  -force -cell $rpCell $dcpDir/route_$x.dcp ;# this is only the current RM, don't need for now
    update_design     -cell $rpCell -black_box ;# this removes the current RM, so we can create static that has no RMs in it
    lock_design       -level routing
    write_checkpoint  -force $dcpDir/static_route.dcp ;# true static, no RMs
    incr idx
  } else {
    open_checkpoint $dcpDir/static_route.dcp
    read_checkpoint -cell $rpCell $rmDir/RM_post_synth_$x.dcp ;# next RM
    opt_design
    place_design
    route_design
    write_checkpoint -force $dcpDir/config_$idx\_routed.dcp ;# config2,etc.
    incr idx
  }
}

#  open_checkpoint $dcpDir/post_route.dcp ;# should this be static_route?
#  set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*] ;# do this on the the first (post_route/config1) so later will be based on it...
#  source ./load_git_hash.tcl
#  # this is just config1 updated with githash, need to do this with static too.
#  # need to do this with static and ALL configs... or they won't have the githash...
#  write_checkpoint -force $dcpDir/static_route_UPDATED.dcp ;



