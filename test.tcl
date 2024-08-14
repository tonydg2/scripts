set VivadoPath "/media/tony/TDG_512/Xilinx/Vivado/2023.2"

set VivadoSettingsFile $VivadoPath/settings64.sh

#if {[catch {exec sh -c "source $VivadoSettingsFile; $buildCmd" >@stdout} cmdErr]} {
#if {[catch {exec sh -c "source $VivadoSettingsFile" >@stdout} cmdErr]} {
if {[catch {exec /bin/bash -c "source $VivadoSettingsFile;which vivado" >@stdout} cmdErr]} {
  puts "\n\nERROR: FAILURE - Project\n\n$cmdErr\n"
}




