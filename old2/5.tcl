#
set hdlDir "/mnt/TDG_512/projects/0_u96_dfx/hdl"

#set     filesVerilog      [glob -nocomplain -tails -directory $hdlDir *.v]
#append  filesVerilog " "  [glob -nocomplain -tails -directory $hdlDir *.sv]
#
#
#foreach x $filesVerilog {
#  puts $x
#}


  set     filesVerilog      [glob -nocomplain -tails -directory $hdlDir/RM0 *.v]
  append  filesVerilog " "  [glob -nocomplain -tails -directory $hdlDir/RM0 *.sv]

  set files {}
  foreach x $filesVerilog {
    puts $x
    lappend files [file rootname $x]
  }
puts "\n"
set files [lsort $files]
foreach x $files {puts $x}