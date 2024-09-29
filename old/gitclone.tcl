set branches "crc boot_quad_spi boot_sd_card ethernet_udp fpga_PS_non_project_template fpga_only-non_project_template interrupts serial_data_from_basys2"

foreach x $branches {
  puts $x
  if {[catch {exec /bin/bash -c "git clone https://tony67dg@bitbucket.org/tony67dg/zynq_templates.git -b $x zynq_templates-$x" >@stdout} cmdErr]} {
    puts $cmdErr
  }
}
