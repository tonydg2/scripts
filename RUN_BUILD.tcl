# Top level build script
# > tclsh RUN_BUILD.tcl

# -clean                  ; removes generated files/folders in the scripts directory
# -proj                   ; generate project only, if -name is not provided, default name is DEFAULT_PROJECT
# -name <project_name>    ; name of project when -proj is used, projects with names beginning with PRJ will be ignored in git
# -bd <bd tcl script name>; provide name of bd tcl script, if not used default is "top_bd". Debug only. BD internally must remain 'top_bd'.
# -verbose, -no_bd        ; for debug

set VivadoPath "/mnt/TDG_512/xilinx/Vivado/2023.2"
set VivadoSettingsFile $VivadoPath/settings64.sh
if {![file exist $VivadoPath]} {
  puts "ERROR - Check Vivado install path.\n\"$VivadoPath\" DOES NOT EXIST"
  exit
}
source support_procs.tcl
#--------------------------------------------------------------------------------------------------
# set some vars for use in other sourced scripts
#--------------------------------------------------------------------------------------------------
set TOP_ENTITY  "top_io" ;# top entity name or image/bit file generated name...
set partNum     "xczu3eg-sbva484-1-i"
set hdlDir      "../hdl"
set outputDir   "../output_products"
set bdDir       "../bd"
set topBD       "top_bd"

#--------------------------------------------------------------------------------------------------
# DFX vars for now, need better way to do this...
#--------------------------------------------------------------------------------------------------
set rpCell      "led_cnt_pr_inst"
set rmDir       "../output_products_RM"
set topRP       "led_cnt_pr"
set RMs         "led_cnt_A \
                 led_cnt_B"

#--------------------------------------------------------------------------------------------------
# Pre-build stuff
#--------------------------------------------------------------------------------------------------
# custom timestamp function instead of xilinx built-in. This ensures timestamp matches exactly
# across bitstream configs
set startTime [clock seconds]
set buildTimeStamp [getTimeStamp $startTime]
puts "\n*** BUILD TIMESTAMP: $buildTimeStamp ***\n"
puts "TCL Version : $tcl_version"
helpMsg $argv ;# support_procs.tcl

set genProj FALSE
if {"-proj" in $argv} {
  set genProj TRUE
  puts "\n\n*** PROJECT GENERATION ONLY ***\n\n"
}

if {"-clean" in $argv} {cleanProc}

#--------------------------------------------------------------------------------------------------
# vivado synth/impl commands
#--------------------------------------------------------------------------------------------------
#set RM_syn_args "$hdlDir $partNum \"$RMs\" $rmDir"
#vivadoCmd2 "RM_syn.tcl" $argv $RM_syn_args;#support_procs.tcl
if {!("-skipPR" in $argv)} {
  vivadoCmd "RM_syn.tcl" $argv $hdlDir $partNum \"$RMs\" $rmDir $topRP;#support_procs.tcl THIS WORKS AS DESIRED
}

if {!("-skipBD" in $argv)} {
  vivadoCmd "bd_gen.tcl" $argv $hdlDir $partNum $bdDir $projName $topBD
}

if {!("-skipSYN" in $argv)} {
  vivadoCmd "syn.tcl" $argv $hdlDir $partNum $topBD $TOP_ENTITY $outputDir $xdcDir $projName
}

if {!("-skipIMP" in $argv)} {
  vivadoCmd "imp.tcl" $argv \"$RMs\" $rmDir $outputDir $rpCell
}

if {!("-skipBIT" in $argv)} {
  vivadoCmd "bit.tcl" $argv $TOP_ENTITY $outputDir $rpCell \"$RMs\" $buildTimeStamp
}
puts "\nDONE DONE\n";exit
#--------------------------------------------------------------------------------------------------
# End of build stuff
#--------------------------------------------------------------------------------------------------
if {!$genProj} {
#  set timeStampVal  [getTimeStampXlnx]  ;# support_procs.tcl
  set timeStampVal  $buildTimeStamp
  set ghash_msb     [getGitHash]    ;# support_procs.tcl
  outputDirGen $timeStampVal $ghash_msb ;# support_procs.tcl
}

puts "\n------------------------------------------"
#if {$genProj == TRUE && ($cmdErr == 0 || $cmdErr == "")} 
if {$genProj == TRUE}
  puts "** PROJECT GENERATION COMPLETE **"
} else {
  puts "** BUILD COMPLETE **"
  puts "Timestamp: $timeStampVal"
  puts "Git Hash: $ghash_msb"
}

buildTimeEnd  ;# support_procs.tcl

if {!$genProj} {cleanProc}

