# support procedures

#--------------------------------------------------------------------------------------------------
# Vivado command
#--------------------------------------------------------------------------------------------------
proc vivadoCmd {fileName argv} {
  upvar VivadoPath VivadoPath
  set   VivadoSettingsFile $VivadoPath/settings64.sh
  # move this somewhere else? don't need to repeat every command
  if {![file exist $VivadoPath]} {
    puts "ERROR - Check Vivado install path.\n\"$VivadoPath\" DOES NOT EXIST"
    exit
  }

  if {"-verbose" in $argv} {
    set buildCmd "vivado -mode batch -source $fileName -nojournal -tclargs $argv" ;# is there a better way...?
  } else {
    set buildCmd "vivado -mode batch -source $fileName -nojournal -notrace -tclargs $argv" 
  }

  ## sh points to dash instead of bash by default in Ubuntu
  #if {[catch {exec sh -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} 
  if {[catch {exec /bin/bash -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} {
    puts "COMMAND ERROR:\n$cmdErr";exit;
  }
}

proc vivadoCmd2 {fileName argv args} {
  upvar VivadoPath VivadoPath
  set   VivadoSettingsFile $VivadoPath/settings64.sh
  # move this somewhere else? don't need to repeat every command
  if {![file exist $VivadoPath]} {
    puts "ERROR - Check Vivado install path.\n\"$VivadoPath\" DOES NOT EXIST"
    exit
  }

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
# 
#--------------------------------------------------------------------------------------------------
proc cleanProc {} {
  set cleanFiles "tight_setup_hold_pins.txt cascaded_blocks.txt wdi_info.xml vivado.log clockInfo.txt"
  foreach x $cleanFiles {
    if {[file exists $x]} {
      file rename -force $x $outputDir/
    }
  }
}

#--------------------------------------------------------------------------------------------------
# parse log file for TIMESTAMP
#--------------------------------------------------------------------------------------------------
proc getTimeStamp {} {
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
# 
#--------------------------------------------------------------------------------------------------
proc cleanProc {} {
  puts "\nCLEANING TEMP FILES"
  set dirs2Clean ".tmpCRC .Xil .srcs .gen"
  append files2Clean [glob -nocomplain *.log] " " [glob -nocomplain *.jou] $dirs2Clean
  foreach x $files2Clean {file delete -force $x}
}

#--------------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------------
proc outputDirGen {timeStampVal ghash_msb} {
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

  # Stop and exit if no xsa
  if {![file exists $outputDir/$TOP_ENTITY.xsa]} {puts "ERROR: $TOP_ENTITY.xsa not found!";exit}

  #!! Uncomment these. Don't need for hobby projects only.
  ###catch {file rename -force $outputDir/$TOP_ENTITY.ltx $outputDirImage/$buildFolder/$TOP_ENTITY.ltx}
  ###catch {file rename -force $outputDir/$TOP_ENTITY.bit $outputDirImage/$buildFolder/$TOP_ENTITY.bit}
  ###catch {file rename -force $outputDir/$TOP_ENTITY.xsa $outputDirImage/$buildFolder/$TOP_ENTITY.xsa}
}