# TODO
# - have multiple topRPs and rpCells, use foreach to loop through all (if possible cleanly)
# - have topRP/rpCell passed in as arg for multiple PR regions? maybe not...
#   * how to do multiple PR regions cleanly all with distinct RM files, etc.
#   * what about nested RMs
#   ** maybe pass in a directory and topRP name??
# Args passed in for this script: hdlDir,partNum,RMs(list),rmDir,topRP
set hdlDir      [lindex $argv 0]
set partNum     [lindex $argv 1]
set RMs         [lindex $argv 2]
set rmDir       [lindex $argv 3]  ;# output products dir
set topRP       [lindex $argv 4]

#if {[file exists $rmDir]} {file delete -force $rmDir}

if {$RMs==""} {
  puts "\n*** No Reconfigurable Modules provided, contintinuing as NON-DFX PROJECT. ***\n"
  return
} else {
  puts "\n***\nDFX PROJECT. Reconfigurable Modules for synthesis:\n$RMs\n***\n"
}

set     commonFilesVerilog      [glob -nocomplain -tails -directory $hdlDir/common *.v]
append  commonFilesVerilog " "  [glob -nocomplain -tails -directory $hdlDir/common *.sv]

foreach x $commonFilesVerilog {
  read_verilog  $hdlDir/common/$x
}

foreach x $RMs {
  read_verilog  $hdlDir/RM0/$x.sv
  synth_design -mode out_of_context -top $topRP -part $partNum
  write_checkpoint -force $rmDir/RM_post_synth_$x.dcp
}

