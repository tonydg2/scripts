
#puts "testing 9"
#
#source 9procs.tcl 
#
#puts "ending 9"
#
#puts ""



#set ipDir "/mnt/TDG_512/projects/1_u96_dfx/ip"

#set files [glob -nocomplain  $ipDir/**/*.xci]
#
#foreach x $files {
#  #puts $x
#  puts [file rootname [file tail $x]]
#}
#

set ipDir "./ip"

set files [glob -nocomplain -tails -directory $ipDir *] 

foreach x $files {
  if {$x == "tcl"} {continue} else {file delete -force $ipDir/$x}
}