proc printArray {} {
  upvar RPs RPs
  foreach {RP RM} [array get RPs] {
    puts -nonewline "\n$RP:"
    foreach x $RM {puts -nonewline "$x "}
  }
  puts "\n---\n"
}
proc printArray2 {} {
  upvar newA newA
  foreach {RP RM} [array get newA] {
    puts -nonewline "\n$RP:"
    foreach x $RM {puts -nonewline "$x "}
  }
  puts "\n---\n"
}

array set RPs {
  RM0 {a b c}
  RM1 {dd g}
}

#foreach {RMDir RMs} [array get RPs] {
#  puts "RMDir: $RMDir, RMs: $RMs"
#}

printArray

array set RPs {RM2 "yy hh"}

printArray

#lsort -index 0 [array get RPs]

set contents [lsort -stride 2 -index 0 [array get RPs]]

puts $contents



