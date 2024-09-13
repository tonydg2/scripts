
set rpCell "led_cnt_pr_inst"
set outputDir   "../output_products"


open_checkpoint $outputDir/post_synth_STATIC.dcp
#read_xdc top_impl.xdc
set_property HD.RECONFIGURABLE true [get_cells $rpCell]
read_checkpoint -cell $rpCell $outputDir/post_synth_led_cnt_A.dcp
opt_design
place_design
route_design
write_checkpoint $outputDir/config1_routed.dcp
write_checkpoint -cell $rpCell $outputDir/rp1_A_route_design.dcp
update_design -cell $rpCell -black_box
lock_design -level routing
write_checkpoint $outputDir/static_routed.dcp

#--------------------------------------------------------------------------------------------------

open_checkpoint $outputDir/static_routed.dcp
read_checkpoint -cell $rpCell $outputDir/post_synth_led_cnt_B.dcp
opt_design
place_design
route_design
write_checkpoint $outputDir/config2_routed.dcp
write_checkpoint -cell $rpCell $outputDir/rp1_B_route_design.dcp
