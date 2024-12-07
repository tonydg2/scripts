
source supportProc8_SAVE.tcl
set hdlDir "/mnt/TDG_512/projects/0_u96_dfx/hdl"
set RMs ""
set RPs ""
set RPlen ""
set MaxRMs ""
set partNum "x898hi-1"
set outputDir   "../output_products"
set dcpDir      "$outputDir/dcp"
set rmDir       $dcpDir
getDFXconfigs

puts "---"
puts "RMs: $RMs"
puts "RPs: $RPs"
puts "RPlen: $RPlen"
puts "MaxRMs: $MaxRMs"
puts "---"

#for {set idx 0} {$idx <$RPlen} {incr idx} {
#  set curRPdir  [lindex $RPs [expr 2*$idx]]
#  set curRPmod  [lindex $RPs [expr 2*$idx + 1]]
#  set curRMs    [lindex $RMs [expr 2*$idx + 1]]
#  set curRPinst "$curRPmod\_inst"
#  puts "\n*** Running P&R $curRPdir, RP inst $curRPmod, with RMs: $curRMs ***\n"
#  foreach x $curRMs {
#    puts $x 
#  }
#}

##    set idx 0
##    foreach RP $RPs {
##      set cfg_$idx ""
##      if {[expr {$idx % 2}] == 0 } {
##        if {$RP ne [lindex $RMs $idx]} {error "PROBLEM"}
##      } else {
##        append cfg_$idx " " [lindex $RMs $idx]
##      }
##      incr idx
##    }
##    
##    append cfg1 [lindex [lindex $RMs 1] 0] " " [lindex [lindex $RMs 3] 0] " " [lindex [lindex $RMs 5] 0]
##    puts "cfg1: $cfg1"
##    append cfg2 [lindex [lindex $RMs 1] 1] " " [lindex [lindex $RMs 3] 1] " " [lindex [lindex $RMs 5] 1]
##    puts "cfg2: $cfg2"
##    append cfg3 [lindex [lindex $RMs 1] 2] " " [lindex [lindex $RMs 3] 2] " " [lindex [lindex $RMs 5] 2]
##    puts "cfg3: $cfg3"
##    
##    set RMsLen [llength [lindex $RMs 1]]
##    puts "len $RMsLen"
##    
##    unset cfg1 cfg2 cfg3
##    
##   # RPlen determines number of configs to get all partials
##   for {set x 0} {$x < $RPlen} {incr x} {
##     for {set y 0} {$y < $MaxRMs} {incr y} {
##       
##       #if [lindex [lindex $RMs ]]
##       #append cfg$x
##     }
##     append cfg$x 
##   }
##


#    set cfg1 ""
#    for {set x 1} {$x < [llength $RPs]} {incr x 2} {
#      append cfg1 [file rootname [lindex [lindex $RMs $x] 0]] " "
#    }




##       
##       puts "CONFIG: $cfg1"
##       # build config1 and generate partials
##       
##       for {set x 1} {$x < [llength $RMs]} {incr x 2} {
##         for {set y 1} {$y < [llength [lindex $RMs $x]]} {incr y 1} {
##           set [lindex $cfg1 $x] [lindex [lindex $RMs $x] $y] 
##           puts $cfg1 
##         }
##       }




# this works!
for {set config 0} {$config < $MaxRMs} {incr config} {
  set cfgName "CONFIG"
  #MaxRMs
  for {set x 1} {$x < [llength $RPs]} {incr x 2} {
    set curRPinst "[lindex $RPs $x]_inst"
    set curRPdir [lindex $RPs [expr $x-1]]  
    if {[lindex [lindex $RMs $x] $config] == ""} {
      # next is empty, so leave as previous and skip read_checkpoint
      continue
    } else {
      set RM [file rootname [lindex [lindex $RMs $x] $config]]
    }
    #puts "assembling config RP:$curRPinst in $curRPdir with $RM"
    puts "read_checkpoint -cell $curRPinst $rmDir/$curRPdir/$curRPdir\_post_synth_$RM.dcp"
    append cfgName "-" $curRPdir\_$RM
  }

  puts "place_n_route $cfgName"
  if {$config == 0} {puts "write_bitstream -force -no_partial_bitfile $outputDir/$cfgName.bit"}
  

  #loop thru again for assembled config partials
  for {set x 1} {$x < [llength $RPs]} {incr x 2} {
    set curRPinst "[lindex $RPs $x]_inst"
    set curRPdir [lindex $RPs [expr $x-1]]  
    if {[lindex [lindex $RMs $x] $config] == ""} {
      # next is empty, so leave as previous and skip read_checkpoint
      continue
    } else {
      set RM [file rootname [lindex [lindex $RMs $x] $config]]
      puts "write_bitstream -force -cell $curRPinst $outputDir/$curRPdir\_$RM\_partial.bit"
    }
  }
  puts ""
}

set DFXrun true 
set staticDFX true 
if {$DFXrun && $staticDFX} {puts "tuuu"}




#    #---------------------------------------------------------------------------------------------------------
#    set cfg1 ""
#    set cfgName "CONFIG"
#    #MaxRMs
#    for {set x 1} {$x < [llength $RPs]} {incr x 2} {
#      append cfg1 [file rootname [lindex [lindex $RMs $x] 0]] " "
#      set curRPinst "[lindex $RPs $x]_inst"
#      set curRPdir [lindex $RPs [expr $x-1]]  
#      set RM [file rootname [lindex [lindex $RMs $x] 0]]
#      #puts "assembling config RP:$curRPinst in $curRPdir with $RM"
#      puts "read_checkpoint -cell $curRPinst $rmDir/$curRPdir/$curRPdir\_post_synth_$RM.dcp"
#      append cfgName "-" $curRPdir\_$RM
#    }
#    
#    # place_n_route $cfgName
#    puts "write_bitstream -force -no_partial_bitfile $outputDir/$cfgName.bit"
#    #puts "CONFIG1 is $cfg1\n$cfgName"
#    puts ""
#    
#    #loop thru again for assembled config partials
#    for {set x 1} {$x < [llength $RPs]} {incr x 2} {
#      set curRPinst "[lindex $RPs $x]_inst"
#      set curRPdir [lindex $RPs [expr $x-1]]  
#      set RM [file rootname [lindex [lindex $RMs $x] 0]]
#      puts "write_bitstream -force -cell $curRPinst $outputDir/$curRPdir\_$RM\_partial.bit"
#    }
#    puts ""
#    #---------------------------------------------------------------------------------------------------------



# now skip initial RM for each RP, assemble and build the remaining RMs
#  set idx 0
#  set cfgIdx 0
#  set cfgDone false
#  foreach RMsInRP $RMs {
#    if {[expr {$idx % 2}] == 0 } {incr idx;continue}
#    set curRP [lindex $RPs $idx]
#    set RMidx 0
#    foreach curRM $RMsInRP {
#      if {$RMidx == 0} {incr RMidx;continue} ;# skip first RM of each RP, already done above
#      if {[llength $curRM] > [expr $RMidx + 1]} {puts "here";incr RMidx;continue}
#      #puts "\tPartial: $curRP [file rootname $curRM]"
#      # PLACE & ROUTE - INNEFICIENT. WANT TO MINIMIZE NUMBER OF P&Rs TO GET ALL PARTIALS
#      write_bitstream -force -cell $curRPinst $outputDir/$curRPdir\_$RM\_partial.bit
#      incr RMidx
#    }
#    incr idx
#    incr cfgIdx
#  }


#  set idx 0
#  set cfgIdx 0
#  set cfgDone false
#  foreach RMsInRP $RMs {
#    if {[expr {$idx % 2}] == 0 } {incr idx;continue}
#    set curRP [lindex $RPs $idx]
#    set RMidx 0
#    foreach curRM $RMsInRP {
#      if {$RMidx == 0} {incr RMidx;continue} ;# skip first RM of each RP, already done above
#      if {[llength $curRM] > [expr $RMidx + 1]} {puts "here";incr RMidx;continue}
#      puts "\tPartial: $curRP [file rootname $curRM]"
#      incr RMidx
#    }
#    incr idx
#    incr cfgIdx
#  }



#    set idx 0
#    set cfgIdx 0
#    set cfgDone false
#    foreach RMsInRP $RMs {
#      if {[expr {$idx % 2}] == 0 } {incr idx;continue}
#      set curRP [lindex $RPs $idx]
#      set RMidx 0
#      foreach curRM $RMsInRP {
#        #if {$RMidx == 0} {incr RMidx;continue}
#        if {[llength $curRM] > [expr $RMidx + 1]} {puts "here";incr RMidx;continue}
#        #puts "RM: [file rootname $curRM], in RP: $curRP. idx=$idx, RMidx=$RMidx, cfgIdx=$cfgIdx"
#        lset cfg1 $cfgIdx [file rootname $curRM]
#        #puts "Update config: [file rootname $curRM] \tcfg=$cfg1"
#        if {!$cfgDone} {puts "BUILD FULL CONFIG: $cfg1";set cfgDone true}
#        #puts "CONFIG: $cfg1   -   Bitstream $curRP [file rootname $curRM]"
#        puts "\tPartial: $curRP [file rootname $curRM]"
#        incr RMidx
#      }
#      incr idx
#      incr cfgIdx
#    }

