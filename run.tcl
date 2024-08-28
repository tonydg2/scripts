# tclsh run.tcl
# -proj, -clean, -verbose
# -name, -no_bd

set VivadoPath "/mnt/TDG_512/xilinx/Vivado/2023.2"
set VivadoSettingsFile $VivadoPath/settings64.sh
set startTime [clock seconds]
set TOP_ENTITY "top_io" ;# top entity name or image/bit file generated name...
append argv " TOP_ENTITY $TOP_ENTITY";# for use in build.tcl

puts "TCL Version : $tcl_version"
if {("-h" in $argv) ||("-help" in $argv)} {
  puts "\t-proj : Generate project only."
  puts "\t-name <PROJECT_NAME> : Name of project (used with -proj). Default name used if not specified."
  puts "\t-clean : Clean build generated files and logs from scripts directory."
  puts "\t-verbose : Prints all tcl commands during build time."
  puts "\t-no_bd : For debug, create project with everything except adding block design or block design containers, to be added manually."
  puts "\t-h, -help : Help."
  exit
}

# tcllib required for zipfile::decode. Can still continue without.
set tcllib_found true
if { [catch {package require zipfile::decode} err] } {
    puts "WARNING - tcllib may not be installed: $err"
    set tcllib_found false
    append argv " tcllib_false";# for use in build.tcl
}

if {![file exist $VivadoPath]} {
  puts "ERROR - Check Vivado install path.\n\"$VivadoPath\" DOES NOT EXIST"
  exit
}

set genProj FALSE
if {"-proj" in $argv} {
  set genProj TRUE
}

if {!$genProj} {
  set outputDir ../output_products
  if {[file exists $outputDir]} {
    append newOutputDir $outputDir "_previous"
    file delete -force $newOutputDir
    file rename -force $outputDir $newOutputDir
  }
  file mkdir $outputDir
}

if {"-clean" in $argv} {
  puts "\nCLEANING TEMP FILES"
  set dirs2Clean ".tmpCRC .Xil .srcs .gen"
  append files2Clean [glob -nocomplain *.log] " " [glob -nocomplain *.jou] $dirs2Clean
  foreach x $files2Clean {file delete -force $x}
  #file delete -force $outputDir $newOutputDir
}

if {$genProj} {
  puts "\n\n*** PROJECT GENERATION ONLY ***\n\n"
}

if {"-verbose" in $argv} {
  set buildCmd "vivado -mode batch -source ./build.tcl -nojournal -tclargs $argv" ;# is there a better way...?
} else {
  set buildCmd "vivado -mode batch -source ./build.tcl -nojournal -notrace -tclargs $argv" 
}

## sh points to dash instead of bash by default in Ubuntu
#if {[catch {exec sh -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} {
if {[catch {exec /bin/bash -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} {
  if {$genProj} {
    puts "\n\nERROR: FAILURE - Project\n\n$cmdErr\n"
    exit
  } else {
    puts "\n\nERROR: BUILD FAILURE\n\n $cmdErr\n"
    exit
  }
}

if {!$genProj} {
  # parse log file for TIMESTAMP
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

  # Get git hash
  if {[catch {exec git rev-parse HEAD}]} {
    set ghash_msb "GIT_ERROR"
  } else {
    set git_hash  [exec git rev-parse HEAD]
    set ghash_msb [string range $git_hash 0 7]
  }

  #set outputDirImage $outputDir/image 
  set outputDirImage $outputDir
  set buildFolder $timeStampVal\_$ghash_msb 
  file mkdir $outputDirImage/$buildFolder 

  # Stop and exit if no xsa
  if {![file exists $outputDir/$TOP_ENTITY.xsa]} {puts "ERROR: $TOP_ENTITY.xsa not found!";exit}
  
  # get bitstream from XSA
  if {$tcllib_found} {
    ::zipfile::decode::unzipfile $outputDir/$TOP_ENTITY.xsa $outputDir/xsa_temp
    # Stop and exit if no bit within xsa
    if {![file exists $outputDir/xsa_temp/$TOP_ENTITY.bit]} {puts "ERROR: $TOP_ENTITY.bit not found in XSA!";exit}
    file copy -force $outputDir/xsa_temp/$TOP_ENTITY.bit $outputDir/$TOP_ENTITY.bit
    file delete -force $outputDir/xsa_temp/
    puts "\n*** XSA embedded bitstream file successfully copied. ***"
  }
  

  #!! Uncomment these. Don't need for hobby projects only.
  ###catch {file rename -force $outputDir/$TOP_ENTITY.ltx $outputDirImage/$buildFolder/$TOP_ENTITY.ltx}
  ###catch {file rename -force $outputDir/$TOP_ENTITY.bit $outputDirImage/$buildFolder/$TOP_ENTITY.bit}
  ###catch {file rename -force $outputDir/$TOP_ENTITY.xsa $outputDirImage/$buildFolder/$TOP_ENTITY.xsa}
}

puts "\n------------------------------------------"
if {$genProj == TRUE && ($cmdErr == 0 || $cmdErr == "")} {
  puts "** PROJECT GENERATION COMPLETE **"
} else {
  puts "** BUILD COMPLETE **"
  puts "Timestamp: $timeStampVal"
  puts "Git Hash: $ghash_msb"
}

set endTime     [clock seconds]
set buildTime   [expr $endTime - $startTime]
set buildMin    [expr $buildTime / 60]
set buildSecRem [expr $buildTime % 60]
puts "\nBuild Time: $buildMin min:$buildSecRem sec"
puts "------------------------------------------"

if {!$genProj} {
  set cleanFiles "tight_setup_hold_pins.txt cascaded_blocks.txt wdi_info.xml vivado.log clockInfo.txt"
  foreach x $cleanFiles {
    if {[file exists $x]} {
      file rename -force $x $outputDir/
      #file copy -force $x $outputDir/
      #file delete -force $x
    }
  }
}

