
proc readVerilogCommon {dir} {
  set     filesVerilog      [glob -nocomplain -tails -directory $dir *.v]
  append  filesVerilog " "  [glob -nocomplain -tails -directory $dir *.sv]

  foreach x $filesVerilog {
    read_verilog  $dir/$x
  }
}

proc readVerilogRM {dir curRPdir curRPmod  partNum rmDir} {
  set     filesVerilog      [glob -nocomplain -tails -directory $dir/$curRPdir *.v]
  append  filesVerilog " "  [glob -nocomplain -tails -directory $dir/$curRPdir  *.sv]
  set     filesVerilog      [lsort $filesVerilog]

  foreach x $filesVerilog {
    read_verilog  $dir/$curRPdir/$x
    synth_design -mode out_of_context -top $curRPmod -part $partNum
    write_checkpoint -force $rmDir/$curRPdir/$curRPdir\_post_synth_[file rootname $x].dcp
  }
}
#--------------------------------------------------------------------------------------------------
# main script 
#--------------------------------------------------------------------------------------------------

set hdlDir      [lindex $argv 0]
set partNum     [lindex $argv 1]
set rmDir       [lindex $argv 2]  ;# output products dir

readVerilogCommon "$hdlDir/common"

readVerilogRM $hdlDir "RM0" "led_cnt_pr"  $partNum $rmDir
readVerilogRM $hdlDir "RM1" "led_cnt2_pr" $partNum $rmDir
readVerilogRM $hdlDir "RM2" "led_cnt3_pr" $partNum $rmDir




