# support procedures

#--------------------------------------------------------------------------------------------------
# Vivado command
#--------------------------------------------------------------------------------------------------
proc vivadoCmd {fileName args} {
  upvar VivadoSettingsFile VivadoSettingsFile
  upvar argv argv
  if {"-verbose" in $argv} {
    set buildCmd "vivado -mode batch -source $fileName -nojournal -tclargs $args" ;# is there a better way...?
  } else {
    set buildCmd "vivado -mode batch -source $fileName -nojournal -notrace -tclargs $args" 
  }

  ## sh points to dash instead of bash by default in Ubuntu
  #if {[catch {exec sh -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} 
  if {[catch {exec /bin/bash -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} {
    puts "COMMAND ERROR:\n$cmdErr";exit;
  }
}
#--------------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------------
proc getProjName {} {
  upvar argv argv
  upvar argc argc
  set defaultProjName "DEFAULT_PROJECT"
  if {"-name" in $argv} {
    set projNameIdx [lsearch $argv "-name"]
    set projNameIdx [expr $projNameIdx + 1]
    if {$projNameIdx == $argc} {
      set projName $defaultProjName
    } else {
      set projName [lindex $argv $projNameIdx]
    }
  } else {
    set projName $defaultProjName
  }
  return $projName
}
#--------------------------------------------------------------------------------------------------
# TODO; add arg for primary RM to be built with first config?
#--------------------------------------------------------------------------------------------------
proc getRMs {} {
  upvar hdlDir hdlDir
  
  set     filesVerilog      [glob -nocomplain -tails -directory $hdlDir/RM0 *.v]
  append  filesVerilog " "  [glob -nocomplain -tails -directory $hdlDir/RM0 *.sv]

  set files {} 
  foreach x $filesVerilog {
    lappend files [file rootname $x]
  }
  return [lsort $files] ;# default ascii sort
}
#--------------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------------
proc checkPartialBuild {} {
  upvar argv argv
  if {("-skipRM"  in $argv) |
      ("-skipBD"  in $argv) |
      ("-skipSYN" in $argv) |
      ("-skipIMP" in $argv) |
      ("-skipBIT" in $argv)
  } {return true} else {return false}
}

#--------------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------------
proc buildTimeEnd {} {
  upvar startTime startTime
  upvar buildTimeStamp buildTimeStamp
  upvar ghash_msb ghash_msb
  
  set endTime     [clock seconds]
  set buildTime   [expr $endTime - $startTime]
  set buildMin    [expr $buildTime / 60]
  set buildSecRem [expr $buildTime % 60]
  
  puts "\n------------------------------------------"
  puts "** BUILD COMPLETE **"
  puts "Timestamp: $buildTimeStamp"
  puts "Git Hash: $ghash_msb"
  puts "\nBuild Time: $buildMin min:$buildSecRem sec"
  puts "------------------------------------------"

}

#--------------------------------------------------------------------------------------------------
# parse log file for Xilinx generated TIMESTAMP
#--------------------------------------------------------------------------------------------------
proc getTimeStampXlnx {} {
  set searchVal "Overwriting \"TIMESTAMP\" with"
  set trimRVal "\" for option USR_ACCESS"
  set timeStampVal "FFFFFFFF"
  catch {set fid [open vivado.log r]}
  while {[gets $fid line] > -1} {
    set idx [string first $searchVal $line 0]
    if {$idx > -1} {
      set timeStampVal [string range $line 30 37]
    }
  }
  close $fid
  return $timeStampVal
}

#--------------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------------
proc getGitHash {} {
  if {[catch {exec git rev-parse HEAD}]} {
    set ghash_msb "GIT_ERROR"
  } else {
    set git_hash  [exec git rev-parse HEAD]
    set ghash_msb [string range $git_hash 0 7]
  }
  return [string toupper $ghash_msb]
}

#--------------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------------
proc helpMsg {} {
    upvar argv argv
  if {("-h" in $argv) ||("-help" in $argv)} {
    puts "\t-proj : Generate project only."
    puts "\t-name <PROJECT_NAME> : Name of project (used with -proj). Default name used if not specified."
    puts "\t-clean : Clean build generated files and logs from scripts directory."
    puts "\t-verbose : Prints all tcl commands during build time."
    puts "\t-no_bd : For debug, create project with everything except adding block design or block design containers, to be added manually."
    puts "\t-bd <BD TCL Script Name : Name of BD tcl script, default 'top_bd' if not specified. ** FOR DEBUG ONLY ** Top level BD must remain \n\
          \t  'top_bd', this is only designed for tcl scripts with names differing from 'top_bd.tcl'"
    puts "\t-h, -help : Help."
  exit
  }
}

#--------------------------------------------------------------------------------------------------
# cleans old generated files prior to build if previous failed/exited abnormaly
#--------------------------------------------------------------------------------------------------
proc cleanProc {} {
  puts "\nCLEANING TEMP FILES"
  set dirs2Clean ".tmpCRC .Xil .srcs .gen hd_visual clockInfo.txt"
  append files2Clean [glob -nocomplain *.log] " " [glob -nocomplain *.jou] $dirs2Clean
  foreach x $files2Clean {file delete -force $x}
}

#--------------------------------------------------------------------------------------------------
# moves generated files into output dir at end of successful build
#--------------------------------------------------------------------------------------------------
proc endCleanProc {} {
  upvar outputDir outputDir
  set cleanFiles "tight_setup_hold_pins.txt cascaded_blocks.txt wdi_info.xml clockInfo.txt hd_visual"
  # append will not add spaces automatically, so must add them manually
  append cleanFiles " " [glob -nocomplain *.log] " " [glob -nocomplain *.jou]
  file mkdir $outputDir/gen
  foreach x $cleanFiles {
    if {[file exists $x]} {
      #file rename -force $x $outputDir/gen/$x
      if {[catch {file rename -force $x $outputDir/gen/$x} err]} {
        puts "WARNING. Problem in endCleanProc: $err"
      }
    }
  }
}
#--------------------------------------------------------------------------------------------------
# If output_products exists from previous build, keep and rename to previous, delete old previous
#--------------------------------------------------------------------------------------------------
proc outputDirGen {} {
  upvar outputDir outputDir
  upvar buildTimeStamp timeStampVal
  upvar ghash_msb ghash_msb
  upvar TOP_ENTITY TOP_ENTITY
  upvar RPs RPs 

  if {[file exists $outputDir]} {
    append newOutputDir $outputDir "_previous"
    file delete -force $newOutputDir
    file rename -force $outputDir $newOutputDir
  }
  file mkdir $outputDir
  #file mkdir $outputDir/bit
  set buildFolder $timeStampVal\_$ghash_msb
  file mkdir $outputDir/$buildFolder

  # "write_bitstream -force" won't create non-existent folders like write_checkpoint does
  # remove this if xilinx version is ever fixed...?
  #set idx 0
  #foreach x $RPs {if {[expr {$idx % 2}] == 0 } {incr idx;file mkdir $outputDir/bit/$x ;continue} else {incr idx;continue}}

  return "$outputDir/$buildFolder"
}

#--------------------------------------------------------------------------------------------------
# TODO: this won't work yet
# need 
#--------------------------------------------------------------------------------------------------
proc packageImage {} {
  upvar outputDir outputDir
  # Stop and exit if no xsa
  if {![file exists $outputDir/$TOP_ENTITY.xsa]} {puts "ERROR: $TOP_ENTITY.xsa not found!";exit}

  set bitFiles [glob -nocomplain *.bit]
  foreach x $bitFiles {
    file rename -force $outputDir/$x $outputDirImage/$buildFolder/$TOP_ENTITY.bit
  }


  ###catch {file rename -force $outputDir/$TOP_ENTITY.ltx $outputDirImage/$buildFolder/$TOP_ENTITY.ltx}
  ###catch {file rename -force $outputDir/$TOP_ENTITY.bit $outputDirImage/$buildFolder/$TOP_ENTITY.bit}
  ###catch {file rename -force $outputDir/$TOP_ENTITY.xsa $outputDirImage/$buildFolder/$TOP_ENTITY.xsa}

}

#--------------------------------------------------------------------------------------------------
# used for custom get time proc
# Function to convert decimal numbers to hexadecimal strings with fixed digit length
#--------------------------------------------------------------------------------------------------
proc dec2hex {digits num} {
  return [format "%0${digits}X" $num]
}

#--------------------------------------------------------------------------------------------------
# get time custom, same format as xilinx USR_ACCESS TIMESTAMP 
#--------------------------------------------------------------------------------------------------
proc getTimeStamp {startTime} {
  # Get the current time
  #set now [clock seconds]
  set now $startTime

  # Extract date and time components and convert to integers
  scan [clock format $now -format %d] %d dayNum
  scan [clock format $now -format %m] %d monthNum
  scan [clock format $now -format %Y] %d yearNum
  scan [clock format $now -format %H] %d hourNum
  scan [clock format $now -format %M] %d minuteNum
  scan [clock format $now -format %S] %d secondNum

  # Adjust the components as per your requirements
  set day    [expr {$dayNum}]            ;# Days from 1 to 31 (5 bits)
  set month  [expr {$monthNum}]          ;# Months from 1 to 12 (4 bits)
  set year   [expr {$yearNum - 2000}]    ;# Years from 0 to 63 (6 bits)
  set hour   $hourNum                    ;# Hours from 0 to 23 (5 bits)
  set minute $minuteNum                  ;# Minutes from 0 to 59 (6 bits)
  set second $secondNum                  ;# Seconds from 0 to 59 (6 bits)

  # Ensure all values are within their expected ranges
  foreach {var maxVal} {
      day    31
      month  12
      year   63
      hour   23
      minute 59
      second 59
  } {
      if {[set $var] > $maxVal || [set $var] < 0} {
          error "$var is out of range (0-$maxVal). getTime proc in support_procs.tcl";exit
      }
  }

  # Calculate the final 32-bit value by shifting and masking components
  set finalValue [expr {
      ((($day & 0x1F)    << 27) |
      (($month  & 0xF)   << 23) |
      (($year   & 0x3F)  << 17) |
      (($hour   & 0x1F)  << 12) |
      (($minute & 0x3F)  << 6)  |
      ($second  & 0x3F))
  }]
  
  return [format "%08X" $finalValue]
}

#--------------------------------------------------------------------------------------------------
# helper for getDFXconfigs
# parse hdl file to get module name
#--------------------------------------------------------------------------------------------------
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

#--------------------------------------------------------------------------------------------------
# helper for getDFXconfigs
# every RM hdl file in a DFX directory (RM*,) must have identical module names. This verifies
#--------------------------------------------------------------------------------------------------
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

#--------------------------------------------------------------------------------------------------
# get RPs, RMs, RP instance(s), etc.
# parse RM* folders, each folder representing individual RPs
#   -get RM name from file parsing each file in RM*
#   -verify all modules same name, error if not
#   -if no RM folders, or empty, no DFX
#   - get RP name as RM name concat with "_inst"
#       search static design for RP name to verify? or just assume...?
#       > get_cells -hierarchical *module_name_inst*
#       easy when in top file. needs to work in lower level instances
# 
# return/set rpCell, RMs, RPs
#   need to loop through RPs (multiple DFX regions)
#--------------------------------------------------------------------------------------------------
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
    set filesVerilog [lsort $filesVerilog]
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
}

#--------------------------------------------------------------------------------------------------
# prep for DFX RM synth runs, before running vivado command 
# this loops through as if running synth, and error/quits if necessary DFX config/arrays are not
# correct. Mostly for debug/check before running actual vivado command - faster for debug
#--------------------------------------------------------------------------------------------------
proc preSynthRMcheck {} {
  upvar RMs RMs
  upvar RPs RPs 
  upvar RPlen RPlen 

  #set RPlen [llength $RMs] 
  if {[expr 2*$RPlen] ne [llength $RPs]} {error "RPs and RMs lengths don't match. EXITING"}
  #set RPlen [expr $RPlen/2]
  #puts $RPlen

  # this loop is just running for the error check. will be repeated in RM synth script with actual build commands
  for {set idx 0} {$idx <$RPlen} {incr idx} {
    set curRPdir  [lindex $RPs [expr 2*$idx]]
    if {$curRPdir ne [lindex $RMs [expr 2*$idx]]} {error "PROBLEM, STOPPING"}
    #set curRPinst [lindex $RPs [expr 2*$idx + 1]]
    #set curRMs    [lindex $RMs [expr 2*$idx + 1]]
    #puts "Running $curRPdir, RP module $curRPinst, with RMs: $curRMs"
  }
}