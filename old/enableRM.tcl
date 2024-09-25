set dir "../hdl"
set RMdirs [glob -nocomplain -directory $dir -type d zOFF_RM*]
if {$RMdirs == ""} {puts "NOTHING TO DO"}
foreach x $RMdirs {
  set val [string range [file tail $x] 5 end]
  file rename $x $dir/$val
}

set delFils [glob -nocomplain -directory $dir led_cnt*]
if {$delFils == ""} {puts "NOTHING TO DO 2"}
foreach x $delFils {
  file delete $x
}
