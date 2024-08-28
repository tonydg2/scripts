
puts "----------------\ntest2\n"
puts "argv = $argv\n\n"

set idx [lsearch -exact $argv TOP_ENTITY]
puts "idx=$idx"
set topEnt [lindex $argv [expr $idx + 1]]
puts "topEnt= $topEnt"

set topEnt2 [lindex $argv [expr [lsearch -exact $argv TOP_ENTITY] + 1]]
puts "topEnt2= $topEnt2"

