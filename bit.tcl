# bitstream gen
set topEntity   "top_io"
set outputDir   "../output_products"
set rpCell      "led_cnt_pr_inst"


open_checkpoint $outputDir/static_route_UPDATED.dcp
write_bitstream -force $outputDir/config1

open_checkpoint $outputDir/config2_routed.dcp
write_bitstream -force -cell $rpCell $outputDir/RM_led_cnt_B_partial.bit

write_debug_probes -force $outputDir/$topEntity  ;#

write_hw_platform -fixed -force $outputDir/$topEntity.xsa

