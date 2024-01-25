# tclsh run.tclh 
# -run, -clean, -verbose

set startTime [clock seconds]

set VivadoPath "/media/tony/TDG_512/Xilinx/Vivado/2023.1"

set TOP "TOP_BD_wrapper" ;# top entity name or image/bit file generated name...

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

set VivadoSettingsFile $VivadoPath/settings64.sh

if {$genProj} {
  puts "\n\n*** PROJECT GENERATION ONLY ***\n\n"
}

if {"-verbose" in $argv} {
  set buildCmd "vivado -mode batch -source ./build.tcl -nojournal -tclargs $argv" ;# is there a better way...?
} else {
  set buildCmd "vivado -mode batch -source ./build.tcl -nojournal -notrace -tclargs $argv" 
}

if {[catch {exec sh -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} {
  if {$genProj} {
    puts "\n\nERROR: FAILURE - Project\n\n$cmdErr\n"
  } else {
    puts "\n\nERROR: BUILD FAILURE\n\n $cmdErr\n"
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

  set outputDirImage $outputDir/image 
  set buildFolder $timeStampVal\_$ghash_msb 
  file mkdir $outputDirImage/$buildFolder 
  catch {file copy -force $outputDir/TOP_BD_wrapper.ltx $outputDirImage/$buildFolder/TOP_BD_wrapper.ltx} 
  catch {file copy -force $outputDir/TOP_BD_wrapper.bit $outputDirImage/$buildFolder/TOP_BD_wrapper.bit}
  catch {file copy -force $outputDir/TOP_BD_wrapper.xsa $outputDirImage/$buildFolder/TOP_BD_wrapper.xsa} 
}

set endTime     [clock seconds]
set buildTime   [expr $endTime - $startTime]
set buildMin    [expr $buildTime / 60]
set buildSecRem [expr $buildTime % 60]
puts "\n------------------------------------------"
puts "Build Time: $buildMin min:$buildSecRem sec"
puts "\n------------------------------------------"

if {$genProj == TRUE && ($cmdErr == 0 || $cmdErr == "")} {
  puts "*** PROJECT GENERATION COMPLETE"
}

if {!$genProj} {
  set cleanFiles "tight_setup_hold_pins.txt cascaded_blocks.txt wdi_info.xml vivado.log"
  foreach x $cleanFiles {
    if {[file exists $x]} {
      file copy -force $x $outputDir/
      file delete -force $x
    }
  }
}

