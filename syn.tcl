# synth script for non-DFX project, or for static portion of DFX project

set partNum   "xczu3eg-sbva484-1-i"
set topEntity "top_io"

set outputDir ../output_products
set hdlDir    ../hdl
set xdcDir    ../xdc 
set simDir    ../sim 

#set projName "DEFAULT_PROJECT"
set projName  "PRJ3"

read_verilog  $hdlDir/top_io.sv 
read_verilog  $hdlDir/led_cnt.sv 
read_verilog  $hdlDir/led_cnt_wrapper.v 
read_verilog  $hdlDir/user_init_64b.sv 
read_verilog  $hdlDir/user_init_64b_wrapper_zynq.v
read_verilog  $hdlDir/axil_reg32.v
read_verilog  $hdlDir/axil_reg32_A.v

# implementation only
read_xdc $xdcDir/pins.xdc 
read_xdc $xdcDir/dfx.xdc 

set topBD         "top_bd"
#set bdFile        ".srcs/sources_1/bd/$topBD/$topBD.bd"
#set wrapperFile   ".gen/sources_1/bd/$topBD/hdl/$topBD\_wrapper.v"
set bdFile        "../$projName/$projName.srcs/sources_1/bd/$topBD/$topBD.bd"
set wrapperFile   "../$projName/$projName.gen/sources_1/bd/$topBD/hdl/$topBD\_wrapper.v"

read_bd $bdFile
read_verilog $wrapperFile

synth_design -top $topEntity -part $partNum
write_checkpoint -force $outputDir/synth.dcp

