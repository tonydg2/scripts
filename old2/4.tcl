source proc4.tcl
set partialBuild false

if {("-a" in $argv) | 
    ("-b" in $argv)
    } {set partialBuild true}


puts $partialBuild


test4 


set val "184ae0ae"
puts $val
set val [string toupper $val]
puts $val

set RMs ""

if {$RMs==""} {
  set DFXrun false
} else { ;# comment
  set DFXrun true
}

puts $DFXrun

foreach x $RMs {puts "x:$x"}