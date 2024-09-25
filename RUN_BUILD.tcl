# -clean -name  -skipIP -skipRM  -skipBD  -skipSYN  -skipIMP  -skipBIT -noCleanImg
#
# TODO: 
#       - maybe want to have synth RMs DCPs separate so as to be able to skip it
#       -  * same with static...?

# Top level build script
# > tclsh RUN_BUILD.tcl


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
set ipDir       "../ip"
set xdcDir      "../xdc"
set outputDir   "../output_products"
set dcpDir      "$outputDir/dcp"
set bdDir       "../bd"
set topBD       "top_bd"
set projName    [getProjName]
#--------------------------------------------------------------------------------------------------
# DFX vars for now, need better way to do this...
#--------------------------------------------------------------------------------------------------
set RMs ""
set RPs ""
set RPlen ""
set MaxRMs ""
getDFXconfigs 

#--------------------------------------------------------------------------------------------------
# Pre-build stuff
#--------------------------------------------------------------------------------------------------
# custom timestamp function instead of xilinx built-in. This ensures timestamp matches exactly
# across bitstream configs when using PR
set startTime [clock seconds]
set buildTimeStamp [getTimeStamp $startTime]
puts "\n*** BUILD TIMESTAMP: $buildTimeStamp ***\n"
puts "TCL Version : $tcl_version"
helpMsg 
set ghash_msb [getGitHash] 

if {"-noCleanImg" in $argv} {set cleanImageFolder false} else {set cleanImageFolder true}
if {$cleanImageFolder} {set imageFolder [outputDirGen]} 
if {"-clean" in $argv} {cleanProc} 
#--------------------------------------------------------------------------------------------------
# vivado synth/impl commands
#--------------------------------------------------------------------------------------------------
if {!("-skipIP" in $argv)} {
  vivadoCmd "gen_ip.tcl" "-proj" "-gen"
}

if {!("-skipRM" in $argv) & !($RMs == "")} {
  preSynthRMcheck ;# mostly just pre verification of RPs/RMs from getDFXconfigs. If this doesn't fail, safe to synth RMs.
  vivadoCmd "syn_rm.tcl" $hdlDir $partNum \"$RMs\" $dcpDir \"$RPs\" $RPlen
}

if {!("-skipBD" in $argv)} {
  vivadoCmd "bd_gen.tcl" $hdlDir $partNum $bdDir $projName $topBD
}
if {!("-skipSYN" in $argv)} {
  vivadoCmd "syn.tcl" $hdlDir $partNum $topBD $TOP_ENTITY $dcpDir $xdcDir $projName \"$RPs\"
}

if {!("-skipIMP" in $argv)} {
  vivadoCmd "imp.tcl" \"$RMs\" $dcpDir \"$RPs\" $RPlen $outputDir $buildTimeStamp $MaxRMs
}

#--------------------------------------------------------------------------------------------------
# End of build stuff
#--------------------------------------------------------------------------------------------------

# check output_products folder at end
# packageImage

buildTimeEnd
endCleanProc
cleanProc

