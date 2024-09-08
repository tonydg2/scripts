
set rpCell "led_cnt_pr_inst"
set outputDir   "../output_products"

open_checkpoint $outputDir/config1_routed.dcp
write_bitstream -force $outputDir/config1


# partial bitstream of RM only
open_checkpoint $outputDir/config2_routed.dcp
write_bitstream -force -cell $rpCell $outputDir/RM_led_cnt_B_partial.bit

