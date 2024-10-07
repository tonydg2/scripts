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

proc readVhdl {dir} {
  set     files     [glob -nocomplain -tails -directory $dir *.vhd]
  foreach x $files {
    read_vhdl  -vhdl2008 $dir/$x
  }
}


set hdlDir    [lindex $argv 0]
set partNum   [lindex $argv 1]
set topEntity [lindex $argv 2]
set dcpDir    [lindex $argv 3]
set xdcDir    [lindex $argv 4]
set noIP      [lindex $argv 5]

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

readVerilog $hdlDir
readVhdl $hdlDir
#readVerilog $hdlDir/common 

#set filesXDC [glob -nocomplain -tails -directory $xdcDir *.xdc]
#foreach x $filesXDC {
#  read_xdc  $xdcDir/$x
#}


#--------------------------------------------------------------------------------------------------
# synth 
#--------------------------------------------------------------------------------------------------

synth_design -mode out_of_context -top $topEntity -part $partNum
write_checkpoint -force $dcpDir/top_synth.dcp

