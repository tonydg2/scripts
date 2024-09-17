set startTime [clock seconds]
after 30
source procs.tcl
buildTimeEnd
puts "done"


set timeVar [getTimeStamp]
puts $timeVar

argsTest $argv

helpMsg $argv
