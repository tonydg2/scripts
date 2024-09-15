# synth script for non-DFX project, or for static portion of DFX project
# Args passed in for this script:$hdlDir $partNum $topBD $TOP_ENTITY $dcpDir $xdcDir $projName

set hdlDir    [lindex $argv 0]
set partNum   [lindex $argv 1]
set topBD     [lindex $argv 2]
set topEntity [lindex $argv 3]
set dcpDir    [lindex $argv 4]
set xdcDir    [lindex $argv 5]
set projName  [lindex $argv 6]

#set projName "DEFAULT_PROJECT"

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

#set bdFile        ".srcs/sources_1/bd/$topBD/$topBD.bd"
#set wrapperFile   ".gen/sources_1/bd/$topBD/hdl/$topBD\_wrapper.v"
set bdFile        "../$projName/$projName.srcs/sources_1/bd/$topBD/$topBD.bd"
set wrapperFile   "../$projName/$projName.gen/sources_1/bd/$topBD/hdl/$topBD\_wrapper.v"

read_bd $bdFile
read_verilog $wrapperFile

synth_design -top $topEntity -part $partNum
write_checkpoint -force $dcpDir/static_synth.dcp

