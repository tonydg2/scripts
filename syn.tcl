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

set     filesVerilog            [glob -nocomplain -tails -directory $hdlDir *.v]
append  filesVerilog        " " [glob -nocomplain -tails -directory $hdlDir *.sv]
set     commonFilesVerilog      [glob -nocomplain -tails -directory $hdlDir/common *.v]
append  commonFilesVerilog  " " [glob -nocomplain -tails -directory $hdlDir/common *.sv]
set     filesXDC                [glob -nocomplain -tails -directory $xdcDir *.xdc]

foreach x $filesVerilog {
  read_verilog  $hdlDir/$x
}

foreach x $commonFilesVerilog {
  read_verilog  $hdlDir/common/$x
}

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
write_checkpoint -force $dcpDir/static_synth.dcp

