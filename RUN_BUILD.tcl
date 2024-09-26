# See README.md
#
# -skipIP -skipBD  
# -skipRM -skipSYN  -skipIMP 
# -clean  -noCleanImg -cleanIP
#
# Top level build script
# > tclsh RUN_BUILD.tcl

set VivadoPath "/opt/xilinx/Vivado/2023.2"

set VivadoSettingsFile $VivadoPath/settings64.sh
if {![file exist $VivadoPath]} {
  puts "ERROR - Check Vivado install path.\n\"$VivadoPath\" DOES NOT EXIST"
  exit
}
source tcl/support_procs.tcl
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
# DFX vars. These are auto-populated. DO NOT MODIFY.
#--------------------------------------------------------------------------------------------------
set RMs ""    ;# List of all reconfigurable modules, organized per RP
set RPs ""    ;# List of all reconfigurable partitions.
set RPlen ""  ;# Number of RPs in design
set MaxRMs "" ;# Number of RMs in the RP that has the largest number of RMs.
getDFXconfigs ;# Proc to populate DFX vars/lists above.

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
set noIP [getIPs] ;# returns TRUE if there are no IPs

if {("-noCleanImg" in $argv) || ("-skipSYN" in $argv) || ("-skipIMP" in $argv) || ("-skipRM" in $argv)} {
  puts "\n** Skipping clean output_products. **"
} else {set imageFolder [outputDirGen]}

if {"-clean" in $argv} {cleanProc} 
if {"-cleanIP" in $argv} {cleanIP}

#--------------------------------------------------------------------------------------------------
# vivado synth/impl commands
#--------------------------------------------------------------------------------------------------

# Generate non-BD IP
if {!("-skipIP" in $argv) && !($noIP)} {
  vivadoCmd "gen_ip.tcl" $ipDir $partNum "-proj" "-gen"
}

# Synthesize RMs OOC
if {!("-skipRM" in $argv) && !($RMs == "")} {
  preSynthRMcheck ;# mostly just pre verification of RPs/RMs from getDFXconfigs. If this doesn't fail, safe to synth RMs.
  vivadoCmd "syn_rm.tcl" $hdlDir $partNum \"$RMs\" $dcpDir \"$RPs\" $RPlen
}

# Generate BD
if {!("-skipBD" in $argv)} {
  vivadoCmd "bd_gen.tcl" $hdlDir $partNum $bdDir $projName $topBD
}

# Synthesize full design (static if DFX)
if {!("-skipSYN" in $argv)} {
  vivadoCmd "syn.tcl" $hdlDir $partNum $topBD $TOP_ENTITY $dcpDir $xdcDir $projName \"$RPs\" $noIP
}

# P&R + bitsream(s)
if {!("-skipIMP" in $argv)} {
  vivadoCmd "imp.tcl" \"$RMs\" $dcpDir \"$RPs\" $RPlen $outputDir $buildTimeStamp $MaxRMs
}

#--------------------------------------------------------------------------------------------------
# Post-build stuff
#--------------------------------------------------------------------------------------------------

# check output_products folder at end
# packageImage

buildTimeEnd
endCleanProc
cleanProc

#close_project -delete