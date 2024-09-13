# Top level build script
# > tclsh RUN_BUILD.tcl

# -clean                  ; removes generated files/folders in the scripts directory
# -proj                   ; generate project only, if -name is not provided, default name is DEFAULT_PROJECT
# -name <project_name>    ; name of project when -proj is used, projects with names beginning with PRJ will be ignored in git
# -bd <bd tcl script name>; provide name of bd tcl script, if not used default is "top_bd". Debug only. BD internally must remain 'top_bd'.
# -verbose, -no_bd        ; for debug

set VivadoPath "/mnt/TDG_512/xilinx/Vivado/2023.2"
#--------------------------------------------------------------------------------------------------
# set some vars for use in other sourced scripts
#--------------------------------------------------------------------------------------------------
set TOP_ENTITY  "top_io" ;# top entity name or image/bit file generated name...
set partNum     "xczu3eg-sbva484-1-i"
set hdlDir      "../hdl"

#--------------------------------------------------------------------------------------------------
# DFX vars for now, need better way to do this...
#--------------------------------------------------------------------------------------------------
set RMs         "led_cnt_A led_cnt_B"
set rpCell      "led_cnt_pr_inst"
set rmDir       "../output_products_RM"
set topRP       "led_cnt_pr"

#--------------------------------------------------------------------------------------------------
# Pre-build stuff
#--------------------------------------------------------------------------------------------------
set startTime [clock seconds]
source support_procs.tcl
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
  vivadoCmd2 "RM_syn.tcl" $argv $hdlDir $partNum \"$RMs\" $rmDir $topRP;#support_procs.tcl THIS WORKS AS DESIRED
}

if {!("-skipBD" in $argv)} {
  vivadoCmd "bd_gen.tcl" $argv ;#support_procs.tcl
}

if {!("-skipSYN" in $argv)} {
  vivadoCmd "syn.tcl" $argv ;#support_procs.tcl
}

if {!("-skipIMP" in $argv)} {
  vivadoCmd "imp.tcl" $argv ;#support_procs.tcl
}

if {!("-skipBIT" in $argv)} {
  vivadoCmd "bit.tcl" $argv ;#support_procs.tcl
}

#vivadoCmd "build.tcl" $argv ;#support_procs.tcl

puts "\n\nDONE DONE";exit
#--------------------------------------------------------------------------------------------------
# End of build stuff
#--------------------------------------------------------------------------------------------------
if {!$genProj} {
  set timeStampVal  [getTimeStamp]  ;# support_procs.tcl
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

