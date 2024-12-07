#
puts $argv
puts $argc
puts "\n"

puts [lindex $argv 0]
puts "\n"

for {set x 0} {$x<$argc} {incr x} {
  puts [lindex $argv $x]
}

puts "\n"

foreach x $argv {puts $x}

