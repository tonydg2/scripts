proc buildTimeEnd {} {
  upvar startTime startTime
  set endTime     [clock seconds]
  set buildTime   [expr $endTime - $startTime]
  set buildMin    [expr $buildTime / 60]
  set buildSecRem [expr $buildTime % 60]
  puts "\nBuild Time: $buildMin min:$buildSecRem sec"
  puts "------------------------------------------"

}

proc getTimeStamp {} {
  set val "B00192"
  return $val
}

proc argsTest args {
  puts $args
}

proc helpMsg argv {
  if {("-h" in $argv) ||("-help" in $argv)} {
    puts "\t-proj : Generate project only."
    puts "\t-name <PROJECT_NAME> : Name of project (used with -proj). Default name used if not specified."
    puts "\t-clean : Clean build generated files and logs from scripts directory."
    puts "\t-verbose : Prints all tcl commands during build time."
    puts "\t-no_bd : For debug, create project with everything except adding block design or block design containers, to be added manually."
    puts "\t-bd <BD TCL Script Name : Name of BD tcl script, default 'top_bd' if not specified. ** FOR DEBUG ONLY ** Top level BD must remain \n\
          \t  'top_bd', this is only designed for tcl scripts with names differing from 'top_bd.tcl'"
    puts "\t-h, -help : Help."
  #exit
  }
}

proc argsTest2 {inVar argv} {
  puts $inVar
  puts $argv
  
  if {("-h" in $argv) ||("-help" in $argv)} { puts "help is here"}

}