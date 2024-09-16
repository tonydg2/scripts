# -clean -name  -skipRM  -skipBD  -skipSYN  -skipIMP  -skipBIT -noCleanImg
#
# TODO: - move RM synth DCPs in output_products_RM into output_products in their own folder
#       - separate bits and dcps in output_products in their own folders
#       - maybe want to have synth RMs DCPs separate so as to be able to skip it
#       -  * same with static...?

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
set xdcDir      "../xdc"
set outputDir   "../output_products"
set dcpDir      "$outputDir/dcp"
set bdDir       "../bd"
set topBD       "top_bd"
set projName    [getProjName]
#--------------------------------------------------------------------------------------------------
# DFX vars for now, need better way to do this...
#--------------------------------------------------------------------------------------------------
set rpCell      "led_cnt_pr_inst" ;# reconfigurable partition instance name in static region
set rmDir       $dcpDir;#"$outputDir/RM_synth" ;# ../output_products_RM;# output directory for reconfigurable modules DCPs
set topRP       "led_cnt_pr"  ;# module name
set RMs         [getRMs] ;#"led_cnt_A led_cnt_B";# led_cnt_C" ;# file name of each reconfigurable module
#--------------------------------------------------------------------------------------------------
# Pre-build stuff
#--------------------------------------------------------------------------------------------------
# custom timestamp function instead of xilinx built-in. This ensures timestamp matches exactly
# across bitstream configs when using PR
set startTime [clock seconds]
set buildTimeStamp [getTimeStamp $startTime]
puts "\n*** BUILD TIMESTAMP: $buildTimeStamp ***\n"
puts "TCL Version : $tcl_version"
helpMsg ;# support_procs.tcl

set ghash_msb     [getGitHash]    ;# support_procs.tcl
if {"-noCleanImg" in $argv} {
  set cleanImageFolder false} else {set cleanImageFolder true}

if {$cleanImageFolder} {
  set imageFolder [outputDirGen] ;# support_procs.tcl
}

set genProj FALSE
if {"-proj" in $argv} {
  set genProj TRUE
  puts "\n\n*** PROJECT GENERATION ONLY ***\n\n"
}

if {"-clean" in $argv} {cleanProc} ;# support_procs.tcl

#--------------------------------------------------------------------------------------------------
# vivado synth/impl commands
#--------------------------------------------------------------------------------------------------
#set RM_syn_args "$hdlDir $partNum \"$RMs\" $rmDir"
#vivadoCmd2 "RM_syn.tcl" $argv $RM_syn_args;#support_procs.tcl
if {!("-skipRM" in $argv)} {
  vivadoCmd "RM_syn.tcl" $hdlDir $partNum \"$RMs\" $rmDir $topRP;#support_procs.tcl THIS WORKS AS DESIRED
}

if {!("-skipBD" in $argv)} {
  vivadoCmd "bd_gen.tcl" $hdlDir $partNum $bdDir $projName $topBD
}

if {!("-skipSYN" in $argv)} {
  vivadoCmd "syn.tcl" $hdlDir $partNum $topBD $TOP_ENTITY $dcpDir $xdcDir $projName
}

if {!("-skipIMP" in $argv)} {
  vivadoCmd "imp.tcl" \"$RMs\" $rmDir $dcpDir $rpCell
}

if {!("-skipBIT" in $argv)} {
  vivadoCmd "bit.tcl" $TOP_ENTITY $outputDir $rpCell \"$RMs\" $buildTimeStamp $dcpDir
}
#puts "\nDONE DONE\n";exit
#--------------------------------------------------------------------------------------------------
# End of build stuff
#--------------------------------------------------------------------------------------------------

# check output_products folder at end
# packageImage ;# support_procs.tcl


buildTimeEnd  ;# support_procs.tcl
endCleanProc
cleanProc

#if {!$genProj} {endCleanProc} ;# support_procs.tcl
