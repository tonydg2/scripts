
proc printArray {} {
  upvar RMs RMs
  foreach {RP RM} $RMs {
    puts -nonewline "\n$RP:"
    foreach x $RM {puts -nonewline "$x "}
  }
  puts "\n---\n"
}


source supportProc.tcl
set hdlDir "/mnt/TDG_512/projects/0_u96_dfx/hdl"
set RMs ""
set RPs ""
set RRs ""
set partNum "x898hi-1"
set rmDir "output_products"
#set RPlist ""
#set RPinst "" 
getDFXconfigs

puts $RMs 
puts $RPs 
puts "---"

set RPlen [llength $RMs] 
if {$RPlen ne [llength $RPs]} {error "RPs and RMs don't match. EXITING"}
set RPlen [expr $RPlen/2]
puts "RPlen:$RPlen"


for {set idx 0} {$idx <$RPlen} {incr idx} {
  set curRPdir  [lindex $RPs [expr 2*$idx]]
  if {$curRPdir ne [lindex $RMs [expr 2*$idx]]} {error "PROBLEM, STOPPING"}
  set curPRmod [lindex $RPs [expr 2*$idx + 1]]
  set curRMs    [lindex $RMs [expr 2*$idx + 1]]
  puts "Running $curRPdir, RP module $curPRmod, with RMs: $curRMs"
  foreach x $curRMs {
    puts "read_verilog $hdlDir/$curRPdir/$x"
    puts "synth_design -mode out_of_context -top $curPRmod -part $partNum"
    puts "write_checkpoint -force $rmDir/$curRPdir/$curRPdir\_post_synth_$x.dcp\n"
  }



}

puts "***"

if {!("-skipRM" in $argv) & !($RRs == "")} {puts "execute"}