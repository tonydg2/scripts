# vivado command script
# > vivado -mode batch -source gen_ip.tcl
# > vivado -mode batch -source gen_ip.tcl -tclargs -proj

set partNum "xczu3eg-sbva484-1-i"
set_part $partNum
set ipDir "../ip"
set ipProjName "PROJECT"
#if {![file exists $ipDir]} {file mkdir $ipDir}
if {![file exists $ipDir]} {return} ;# IP will be in the project repo, not scripts repo. if no IP for project, done.

set files [glob -nocomplain -tails -directory $ipDir/tcl *.tcl]
if {$files == ""} {return} ;# no tcl files, done.

if {"-proj" in $argv} {create_project -force $ipProjName $ipDir/$ipProjName -part $partNum -ip}

foreach x $files {source $ipDir/tcl/$x}

#source ./ip/dfx_axi_mgr.tcl
#source ./ip/ila0.tcl
#source ./ip/ila_axi0.tcl
