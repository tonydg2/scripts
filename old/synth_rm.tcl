
set topRP       "led_cnt_pr"
set hdlDir      "../hdl"
set partNum     "xczu3eg-sbva484-1-i"
set RM1         "led_cnt_A"
set RM2         "led_cnt_B"
set outputDir   "../output_products"

#create_project -in_memory -part $partNum 

read_verilog  $hdlDir/$RM1.sv 
synth_design -mode out_of_context -top $topRP -part $partNum
write_checkpoint -force $outputDir/post_synth_$RM1

#close_project -delete

#--------------------------------------------------------------------------------------------------
read_verilog  $hdlDir/$RM2.sv 
synth_design -mode out_of_context -top $topRP -part $partNum
write_checkpoint -force $outputDir/post_synth_$RM2

