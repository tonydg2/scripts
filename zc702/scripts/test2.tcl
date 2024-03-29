
set hdlDir ../hdl

#set vfiles [glob -nocomplain /*.v]
set vFiles    [glob -nocomplain $hdlDir/*.v]
set svFiles   [glob -nocomplain $hdlDir/*.sv]
set vhdFiles  [glob -nocomplain $hdlDir/*.vhd]
if {$vFiles=="" && $svFiles=="" && $vhdFiles==""} {
  puts "No files in directory \"$hdlDir\""
}
puts $vFiles
puts $svFiles
puts $vhdFiles


if {$vFiles !=""} {puts $vFiles}
if {$svFiles !=""} {puts $svFiles}
if {$vhdFiles !=""} {puts $vhdFiles}
