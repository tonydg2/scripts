
# read taps, convert to hex in Xilinx coe format
# also output print spacing


set fileName "taps.coe"
set fid [open $fileName r]
set foutid [open "tapsXil.coe" w]

puts $foutid "radix=16;"
puts $foutid "coefdata="

set prevLine ""
# Read and print each line
while {[gets $fid line] >= 0} {
  if {$prevLine ne ""} {
    puts $foutid $prevLine,
  }
  set tap [expr $line * (2**31 - 1)]
  set tapRnd [::tcl::mathfunc::round $tap]
  set tapRnd [expr {$tapRnd & 0xFFFFFFFF}] ;# forces 32bit val
  set tapHex [format "%08x" $tapRnd]
  #puts "$line\t=\t$tapRnd\t=\t0x$tapHex"
  #puts [format "Value1 = %-15s Value2 = %-15s Value3 = %-15s" $val1 $val2 $val3]
  #set outVal [format "Value1 = %-22s Value2 = %-12s Value3 = %-10s" $line $tapRnd $tapHex]
  set outVal [format "%-22s = %-12s = 0x%-12s" $line $tapRnd $tapHex]
  puts $outVal
  set prevLine $tapHex
  #puts $foutid $tapHex,
  #puts [format "%-15s" $line]
}

if {$prevLine ne ""} {
  puts $foutid $prevLine\;
}
close $fid
close $foutid
exit

