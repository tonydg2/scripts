set dir "../hdl"

file copy $dir/RM0/led_cnt_A.sv $dir/led_cnt_A.sv
file copy $dir/RM1/led_cnt2_A.sv $dir/led_cnt2_A.sv
file copy $dir/RM2/led_cnt3_A.sv $dir/led_cnt3_A.sv


set RMdirs [glob -directory $dir -type d RM*]
foreach x $RMdirs {
  file rename $x $dir/zOFF_[file tail $x]
}
