# TODO: - option for NO-BD (fabric only) 
#       - option for multiple separate BDs...

# synth script for non-DFX project, or for static portion of DFX project

proc readVerilog {dir} {
  set     files     [glob -nocomplain -tails -directory $dir *.v]
  append  files " " [glob -nocomplain -tails -directory $dir *.sv]
  foreach x $files {
    read_verilog  $dir/$x
  }
}

set hdlDir    [lindex $argv 0]
set partNum   [lindex $argv 1]
set topBD     [lindex $argv 2]
set topEntity [lindex $argv 3]
set dcpDir    [lindex $argv 4]
set xdcDir    [lindex $argv 5]
set projName  [lindex $argv 6]
set RPs       [lindex $argv 7]
set noIP      [lindex $argv 8]

set_part $partNum

#--------------------------------------------------------------------------------------------------
# read non-BD IP
#--------------------------------------------------------------------------------------------------
# IP must be in ../ip/<ipName>/<ipName>.xci
# IP already generated in the gen_ip.tcl script
if {!$noIP} {
  set ipDir "../ip"
  set xciFiles [glob -nocomplain  $ipDir/**/*.xci]
  foreach x $xciFiles {
    set xciRootName [file rootname [file tail $x]]
    read_ip $ipDir/$xciRootName/$xciRootName.xci
    set_property generate_synth_checkpoint false [get_files $ipDir/$xciRootName/$xciRootName.xci]
    generate_target all [get_files $ipDir/$xciRootName/$xciRootName.xci] 
  }
}
#--------------------------------------------------------------------------------------------------
# read HDL/XDC 
#--------------------------------------------------------------------------------------------------
#set projName "DEFAULT_PROJECT"

# top file synthesized first. there are black box modules (module definitions in addition to instances)
# with these, if the top module that has these black boxes read first, if the actual module is read AFTER, 
# it will overwrite the black box with the ACTUAL module. Otherwise, if the module is read first, then the top 
# file where the module (blackbox) is defined, it will overwrite the actual module read first, and make it an 
# empty black box.
read_verilog $hdlDir/top/$topEntity.sv 

readVerilog $hdlDir
readVerilog $hdlDir/bd 
readVerilog $hdlDir/common 

set filesXDC [glob -nocomplain -tails -directory $xdcDir *.xdc]
foreach x $filesXDC {
  read_xdc  $xdcDir/$x
}

#--------------------------------------------------------------------------------------------------
# read BD 
#--------------------------------------------------------------------------------------------------
# in-memory or saved BD project
if {$projName == "DEFAULT_PROJECT"} {
  set bdFile        ".srcs/sources_1/bd/$topBD/$topBD.bd"
  set wrapperFile   ".gen/sources_1/bd/$topBD/hdl/$topBD\_wrapper.v"
} else {
  set bdFile        "../$projName/$projName.srcs/sources_1/bd/$topBD/$topBD.bd"
  set wrapperFile   "../$projName/$projName.gen/sources_1/bd/$topBD/hdl/$topBD\_wrapper.v"
}

read_bd $bdFile
read_verilog $wrapperFile

#--------------------------------------------------------------------------------------------------
# synth 
#--------------------------------------------------------------------------------------------------

synth_design -top $topEntity -part $partNum
if {!($RPs=="")} {foreach {ignore RP} $RPs {set_property HD.RECONFIGURABLE true [get_cells $RP\_inst]}}


set initFF_data "AB5F0077"
set initFF_cells_path [get_cells -hierarchical *timestamp_scripts_inst*]
source ./tcl/initFF32.tcl
set initFF_cells_path [get_cells -hierarchical *time_stamp_top_inst*]
source ./tcl/initFF32.tcl
set initFF_cells_path [get_cells -hierarchical *time_stamp_click_uart_inst*]
source ./tcl/initFF32.tcl
set initFF_cells_path [get_cells -hierarchical *time_stamp_click_lcd_inst*]
source ./tcl/initFF32.tcl



write_checkpoint -force $dcpDir/top_synth.dcp

