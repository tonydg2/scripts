# implementation

set outputDir   "../output_products"
set rpCell      "led_cnt_pr_inst"
set rmDir       "../output_products_RM"
set RM1         "led_cnt_A"
set RM2         "led_cnt_B"

# open full static region synth checkpoint
open_checkpoint $outputDir/synth.dcp

# RP cell in static region
set_property HD.RECONFIGURABLE true [get_cells $rpCell]

# read RM synth checkpoint
read_checkpoint -cell $rpCell $rmDir/post_synth_$RM1.dcp

opt_design
place_design
phys_opt_design

route_design
write_checkpoint -force $outputDir/post_route.dcp

write_checkpoint  -force -cell $rpCell $outputDir/route_$RM1.dcp
update_design     -cell $rpCell -black_box
lock_design       -level routing
write_checkpoint  -force $outputDir/static_route.dcp

open_checkpoint $outputDir/static_route.dcp
read_checkpoint -cell $rpCell $rmDir/post_synth_$RM2.dcp
opt_design
place_design
route_design
write_checkpoint -force $outputDir/config2_routed.dcp

open_checkpoint $outputDir/post_route.dcp 
set githash_cells_path [get_cells -hierarchical *user_init_64b_inst*]
source ./load_git_hash.tcl
write_checkpoint -force $outputDir/static_route_UPDATED.dcp



