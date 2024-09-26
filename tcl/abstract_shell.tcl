# notes only


# open initial full routed config
# write_abstract_shell for each RP
# 
# write_abstract_shell -cell curRPinst
# 
# led_cnt_pr_inst
# led_cnt2_pr_inst
# led_cnt3_pr_inst
# axil_reg32_2_inst


#------------------------------------------------------------------------------

open_checkpoint CONFIG-RM0_led_cnt_A-RM1_led_cnt2_A-RM2_led_cnt3_A-RM4_axil_reg32_A.dcp

write_abstract_shell -cell led_cnt_pr_inst led_cnt_pr_AbSh
write_abstract_shell -cell led_cnt2_pr_inst led_cnt2_pr_AbSh
write_abstract_shell -cell led_cnt3_pr_inst led_cnt3_pr_AbSh
write_abstract_shell -cell axil_reg32_2_inst axil_reg32_2_AbSh


open_checkpoint led_cnt_pr_AbSh.dcp
read_checkpoint -cell led_cnt_pr_inst RM0/RM0_post_synth_led_cnt_B.dcp
  opt_design
  place_design
  phys_opt_design
  route_design

#write_checkpoint 
# compare the routed version currently in memory (routed with RM version B) to the original AbShel that contained routed RM version A
pr_verify -in_memory -additional led_cnt_pr_AbSh.dcp

write_bitstream -cell led_cnt_pr_inst RM0_B_partial.bit


