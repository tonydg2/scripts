# synth script for non-DFX project, or for static portion of DFX project
# Args passed in for this script:$hdlDir $partNum $topBD $TOP_ENTITY $dcpDir $xdcDir $projName

proc readVerilog {dir} {
  set     files     [glob -nocomplain -tails -directory $dir *.v]
  append  files " " [glob -nocomplain -tails -directory $dir *.sv]
  foreach x $files {
    puts "\n *** $dir/$x *** \n"
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

set     filesXDC                [glob -nocomplain -tails -directory $xdcDir *.xdc]
foreach x $filesXDC {
  read_xdc  $xdcDir/$x
}

#set bdFile        ".srcs/sources_1/bd/$topBD/$topBD.bd"
#set wrapperFile   ".gen/sources_1/bd/$topBD/hdl/$topBD\_wrapper.v"
set bdFile        "../$projName/$projName.srcs/sources_1/bd/$topBD/$topBD.bd"
set wrapperFile   "../$projName/$projName.gen/sources_1/bd/$topBD/hdl/$topBD\_wrapper.v"

read_bd $bdFile
read_verilog $wrapperFile

synth_design -top $topEntity -part $partNum
if {!($RPs=="")} {foreach {ignore RP} $RPs {set_property HD.RECONFIGURABLE true [get_cells $RP\_inst]}}
write_checkpoint -force $dcpDir/static_synth.dcp

