
set rmDir       "../RM_products"
set hdlDir      "../hdl"
set partNum     "xczu3eg-sbva484-1-i"
set topRP       "led_cnt_pr"
set RM1         "led_cnt_A"
set RM2         "led_cnt_B"
set rpCell      "led_cnt_pr_inst"


read_verilog  $hdlDir/$RM1.sv 
synth_design -mode out_of_context -top $topRP -part $partNum
write_checkpoint -force $rmDir/post_synth_$RM1.dcp

read_verilog  $hdlDir/$RM2.sv 
synth_design -mode out_of_context -top $topRP -part $partNum
write_checkpoint -force $rmDir/post_synth_$RM2.dcp
