# implementation
# required DCPs:  $dcpDir/static_synthsynth.dcp
#                 $rmDir/post_synth_$x.dcp (all RMs)
#
# Args passed in for this script: $RMs(list) $rmDir $dcpDir $rpCell

proc place_n_route {name} {
  opt_design
  place_design
  phys_opt_design
  route_design
  # update git hash for every config, TODO: add catch for instance existance
  set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*]
  source ./load_git_hash.tcl
  #report_timing_summary -file $dcpDir/timing_summary_$name.rpt
}

set RMs     [lindex $argv 0]
set rmDir   [lindex $argv 1]
set dcpDir  [lindex $argv 2]
set rpCell  [lindex $argv 3]

if {$RMs==""} {set DFXrun false} else {set DFXrun true}

# Run each configuration in a DFX run, if non-DFX this will be skipped
set idx 1
foreach x $RMs { ;# this will be skipped if RMs is empty (non-DFX build)
  open_checkpoint $dcpDir/static_synth.dcp
  set_property HD.RECONFIGURABLE true [get_cells $rpCell]
  read_checkpoint -cell $rpCell $rmDir/RM_post_synth_$x.dcp
  place_n_route "$x\_$idx"
  write_checkpoint -force $dcpDir/config_$idx\_routed.dcp
  incr idx
}

if {$DFXrun} {
  open_checkpoint $dcpDir/config_1_routed.dcp
  update_design     -cell $rpCell -black_box
  lock_design       -level routing
} else {
  open_checkpoint $dcpDir/static_synth.dcp
  place_n_route "static"
}

report_timing_summary -file $dcpDir/timing_summary_static_route.rpt
#report_timing -sort_by group -max_paths 100 -path_type summary -file $dcpDir/static_route_timing.rpt
#report_clock_utilization   -file $dcpDir/static_route_clk_util.rpt
#report_utilization         -file $dcpDir/static_route_post_route_util.rpt
#report_power               -file $dcpDir/static_route_power.rpt
#report_drc                 -file $dcpDir/static_route_drc.rpt


write_checkpoint  -force $dcpDir/static_route.dcp ;# complete checkpoint if non-DFX run


#  open_checkpoint $dcpDir/post_route.dcp ;# should this be static_route?
#  set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*] ;# do this on the the first (post_route/config1) so later will be based on it...
#  source ./load_git_hash.tcl
#  # this is just config1 updated with githash, need to do this with static too.
#  # need to do this with static and ALL configs... or they won't have the githash...
#  write_checkpoint -force $dcpDir/static_route_UPDATED.dcp ;



