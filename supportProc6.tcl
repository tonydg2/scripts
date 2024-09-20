
# RPs : module name of each RM (same for each RP)
# RMs : filename for each RM (unique all with same module name)

proc findModuleName {fileName} {
  set fid [open $fileName r]
  set text [read $fid] 
  close $fid 
  if {[regexp -nocase {module\s+(\S+)} $text match moduleName]} {
    return $moduleName
  } else {
    puts "ERROR parsing for module name in $fileName. EXITING"
    exit
  }
}

proc verifyModuleNames {moduleList} {
  if {[llength $moduleList] <= 1} {return} ;# only one module so just return
  set firstFile [lindex $moduleList 0] 
  foreach modFile $moduleList {
    if {$modFile ne $firstFile} {
      puts "ERROR: each module name in RM directories must be identical."
      exit ;#return 0
    }
  }
  return
}

proc getDFXconfigs {} {
  upvar hdlDir hdlDir
  
  upvar RMs RMs
  upvar RPs RPs 

  #upvar RPlist RPlist
  #upvar RPinst RPinst

  # first get all directories in hdl that have 'RM*' name
  set RMDirs [glob -nocomplain -tails -directory $hdlDir -type d RM*]
  #puts $RMDirs
  if {$RMDirs==""} {return} ;# no RMs therefore no DFX - DONE

  # now search each RM Dir to get RMs for each
  foreach x $RMDirs {
    set     filesVerilog      [glob -nocomplain -tails -directory $hdlDir/$x *.v]
    append  filesVerilog " "  [glob -nocomplain -tails -directory $hdlDir/$x *.sv]
    set filesVerilog [lsort $filesVerilog]
    set rmModName ""
    foreach vFile $filesVerilog {
      append rmModName " " [findModuleName $hdlDir/$x/$vFile]
    }
    #puts $rmModName
    verifyModuleNames $rmModName ;# verify all match otherwise error/quit
    #puts $filesVerilog
    #array set RParray {$x $filesVerilog}
    set RParray($x) $filesVerilog 

    set RPname [lindex $rmModName 0]
    #set RPinstArray($x) "$RPname\_inst"
    set RPinstArray($x) $RPname

  }

  set RMs [lsort -stride 2 -index 0 [array get RParray]]
  #return $RPlist

  set RPs [lsort -stride 2 -index 0 [array get RPinstArray]]

}


#glob -nocomplain -tails -directory $hdlDir/common *.v]