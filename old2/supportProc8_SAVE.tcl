
proc findModuleName {fileName} {
  set fid [open $fileName r]
  set text [read $fid] 
  close $fid 
  if {[regexp -nocase {module\s+(\S+)} $text match moduleName]} {
    return $moduleName
  } else {
    error "ERROR parsing for module name in $fileName. EXITING"
  }
}

proc verifyModuleNames {moduleList} {
  if {[llength $moduleList] <= 1} {return} ;# only one module so just return
  set firstFile [lindex $moduleList 0] 
  foreach modFile $moduleList {
    if {$modFile ne $firstFile} {
      error "ERROR: each module name in RM directories must be identical."
    }
  }
  return
}

proc getDFXconfigs {} {
  upvar hdlDir hdlDir
  upvar RMs RMs
  upvar RPs RPs 
  upvar RPlen RPlen
  upvar MaxRMs MaxRMs
  # first get all directories in hdl that have 'RM*' name
  set RMDirs [glob -nocomplain -tails -directory $hdlDir -type d RM*]
  if {$RMDirs==""} {return} ;# no RMs therefore no DFX - DONE

  # now search each RM Dir to get RMs for each
  foreach x $RMDirs {
    set     filesVerilog      [glob -nocomplain -tails -directory $hdlDir/$x *.v]
    append  filesVerilog " "  [glob -nocomplain -tails -directory $hdlDir/$x *.sv]
    set filesVerilog          [lsort $filesVerilog]
    set rmModName ""
    foreach vFile $filesVerilog {
      append rmModName " " [findModuleName $hdlDir/$x/$vFile]
    }
    verifyModuleNames $rmModName ;# verify all match otherwise error/quit
    if {[expr {[llength $filesVerilog] > $MaxRMs}]} {set MaxRMs [llength $filesVerilog]} ;# need number of RMs in RP that has the most RMs
    set RParray($x) $filesVerilog 
    set RPname [lindex $rmModName 0]
    set RPinstArray($x) $RPname

  }
  set RMs [lsort -stride 2 -index 0 [array get RParray]]
  set RPs [lsort -stride 2 -index 0 [array get RPinstArray]]
  set RPlen [expr [llength $RMs]/2]
  #puts $RMDirs
}

