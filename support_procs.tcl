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
      file rename -force $x $outputDir/gen/$x
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

  if {[file exists $outputDir]} {
    append newOutputDir $outputDir "_previous"
    file delete -force $newOutputDir
    file rename -force $outputDir $newOutputDir
  }
  file mkdir $outputDir
  set buildFolder $timeStampVal\_$ghash_msb
  file mkdir $outputDir/$buildFolder

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
