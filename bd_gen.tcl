# generate block design with associated dependencies
# UG994, UG892
# Args passed in for this script: hdlDir,partNum,bdDir,projName,topBD

set hdlDir    [lindex $argv 0]
set partNum   [lindex $argv 1]
set bdDir     [lindex $argv 2]
set projName  [lindex $argv 3]
set topBD     [lindex $argv 4]

set_part $partNum
create_project $projName -part $partNum -in_memory
set_property TARGET_LANGUAGE Verilog [current_project]
#set_property BOARD_PART <board_part_name> [current_project]
set_property DEFAULT_LIB work [current_project]
set_property SOURCE_MGMT_MODE All [current_project]

set     filesVerilog            [glob -nocomplain -tails -directory $hdlDir *.v]
append  filesVerilog        " " [glob -nocomplain -tails -directory $hdlDir *.sv]
set     commonFilesVerilog      [glob -nocomplain -tails -directory $hdlDir/common *.v]
append  commonFilesVerilog  " " [glob -nocomplain -tails -directory $hdlDir/common *.sv]

foreach x $filesVerilog {
  read_verilog  $hdlDir/$x
}

foreach x $commonFilesVerilog {
  read_verilog  $hdlDir/common/$x
}

source $bdDir/$topBD.tcl

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

