
set TOP_ENTITY "top_io"

append argv " TOP_ENTITY $TOP_ENTITY";# for use in build.tcl

set buildCmd "tclsh test2.tcl $argv" ;# is there a better way...?

puts "test\n"
puts "argv = $argv\n\n"

if {[catch {exec /bin/bash -c "$buildCmd" >@stdout} cmdErr]} {
    puts "\n\nERROR\n\n$cmdErr\n"
    exit
}

if {![file exists test3.tcl]} {
  puts "NOT exist"
} else {puts "exists"}

