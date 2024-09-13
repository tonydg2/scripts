# generate block design with associated dependencies
# UG994, UG892

set bdDir   ../bd
set hdlDir  ../hdl

set partNum   "xczu3eg-sbva484-1-i"
set projName  "PRJ3"
set topBD     "top_bd"

set_part $partNum
create_project $projName -part $partNum -in_memory
set_property TARGET_LANGUAGE Verilog [current_project]
#set_property BOARD_PART <board_part_name> [current_project]
set_property DEFAULT_LIB work [current_project]
set_property SOURCE_MGMT_MODE All [current_project]

read_verilog  $hdlDir/axil_reg32.v
read_verilog  $hdlDir/led_cnt.sv 
read_verilog  $hdlDir/led_cnt_wrapper.v 
read_verilog  $hdlDir/user_init_64b.sv 
#read_verilog  $hdlDir/user_init_64b_wrapper.v
read_verilog  $hdlDir/user_init_64b_wrapper_zynq.v

source $bdDir/top_bd.tcl

#--------------------------------------------------------------------------------------------------
# TODO: have option to to full in-memory build. Also build with already generated BD project:
# in-memory : ".srcs/..."
# project   : ../$projName/$projName.srcs/...
#   both need to work during later implementation...
#--------------------------------------------------------------------------------------------------
set bdFile        ".srcs/sources_1/bd/$topBD/$topBD.bd"
set wrapperFile   ".gen/sources_1/bd/$topBD/hdl/$topBD\_wrapper.v"

make_wrapper -files [get_files $bdFile] -top
read_verilog $wrapperFile
set_property synth_checkpoint_mode None [get_files $bdFile]
generate_target all [get_files $bdFile]

#if {$genProj} {
  set_property top [file rootname [file tail $wrapperFile]] [current_fileset]  
  save_project_as $projName ../$projName -force
#  
#}

