
proc printArray {} {
  upvar RMs RMs
  foreach {RP RM} $RMs {
    puts -nonewline "\n$RP:"
    foreach x $RM {puts -nonewline "$x "}
  }
  puts "\n---\n"
}


source supportProc.tcl
set hdlDir "/mnt/TDG_512/projects/0_u96_dfx/hdl"
set RMs ""
set RPs ""

#set RPlist ""
#set RPinst "" 
getDFXconfigs

puts $RMs 
puts $RPs 


#set RMs [getDFXconfigs]
#puts $RMs
#printArray

#foreach x $RMs {puts $x}

#puts "RMs: $RMs"
#puts "RPs: $RPs"

#---------------------------------------------------------------------------
#set fid [open "$hdlDir/RM0/led_cnt_A.sv" r]
#set text [read $fid] 
#close $fid
## Use a regular expression to find the word 'module' followed by any whitespace and capture the next word
#if {[regexp -nocase {module\s+(\S+)} $text match moduleName]} {
#    puts $moduleName
#} else {
#    puts "No module found"
#}
#puts $text