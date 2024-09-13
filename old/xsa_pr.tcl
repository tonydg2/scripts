set outputDir   "../output_products"

open_checkpoint $outputDir/config1_routed.dcp

write_debug_probes  -force $outputDir/config1_routed
write_hw_platform   -include_bit -fixed -force $outputDir/config1_routed.xsa

