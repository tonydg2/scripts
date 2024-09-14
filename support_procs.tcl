# support procedures

#--------------------------------------------------------------------------------------------------
# Vivado command
#--------------------------------------------------------------------------------------------------
#proc vivadoCmd {fileName argv} {
#  upvar VivadoPath VivadoPath
#  set   VivadoSettingsFile $VivadoPath/settings64.sh
#  # move this somewhere else? don't need to repeat every command
#  if {![file exist $VivadoPath]} {
#    puts "ERROR - Check Vivado install path.\n\"$VivadoPath\" DOES NOT EXIST"
#    exit
#  }
#
#  if {"-verbose" in $argv} {
#    set buildCmd "vivado -mode batch -source $fileName -nojournal -tclargs $argv" ;# is there a better way...?
#  } else {
#    set buildCmd "vivado -mode batch -source $fileName -nojournal -notrace -tclargs $argv" 
#  }
#
#  ## sh points to dash instead of bash by default in Ubuntu
#  #if {[catch {exec sh -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} 
#  if {[catch {exec /bin/bash -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} {
#    puts "COMMAND ERROR:\n$cmdErr";exit;
#  }
#}

proc vivadoCmd {fileName argv args} {
  upvar VivadoSettingsFile VivadoSettingsFile

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
proc checkPartialBuild {argv} {
  if {("-skipPR" in $argv) |
      ("-skipBD" in $argv) |
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
  set endTime     [clock seconds]
  set buildTime   [expr $endTime - $startTime]
  set buildMin    [expr $buildTime / 60]
  set buildSecRem [expr $buildTime % 60]
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
  return $ghash_msb
}

#--------------------------------------------------------------------------------------------------
# Using 'argv' directly as input was necessary, other custom name didn't work.
#--------------------------------------------------------------------------------------------------
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
proc endCleanProc {outputDir} {
  set cleanFiles "tight_setup_hold_pins.txt cascaded_blocks.txt wdi_info.xml clockInfo.txt hd_visual"
  append cleanFiles " " [glob -nocomplain *.log] " " [glob -nocomplain *.jou] $cleanFiles
  file mkdir $outputDir/gen
  foreach x $cleanFiles {
    if {[file exists $x]} {
      file rename -force $x $outputDir/gen/$x
    }
  }
}
#--------------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------------
proc outputDirGen {timeStampVal ghash_msb TOP_ENTITY} {
  set outputDir ../output_products
  if {[file exists $outputDir]} {
    append newOutputDir $outputDir "_previous"
    file delete -force $newOutputDir
    file rename -force $outputDir $newOutputDir
  }
  file mkdir $outputDir

  set outputDirImage $outputDir
  set buildFolder $timeStampVal\_$ghash_msb 
  file mkdir $outputDirImage/$buildFolder 

# TODO: below code needs to go in another proc that is called at end of full build
  # Stop and exit if no xsa
  #if {![file exists $outputDir/$TOP_ENTITY.xsa]} {puts "ERROR: $TOP_ENTITY.xsa not found!";exit}

  #!! Uncomment these. Don't need for hobby projects only.
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
  set day    [expr {$dayNum}]            ;# Days from 0 to 30 (5 bits)
  set month  [expr {$monthNum}]          ;# Months from 0 to 11 (4 bits)
  set year   [expr {$yearNum - 2000}]    ;# Years from 0 to 63 (6 bits)
  set hour   $hourNum                    ;# Hours from 0 to 23 (5 bits)
  set minute $minuteNum                  ;# Minutes from 0 to 59 (6 bits)
  set second $secondNum                  ;# Seconds from 0 to 59 (6 bits)

  # Ensure all values are within their expected ranges
  foreach {var maxVal} {
      day    30
      month  11
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
