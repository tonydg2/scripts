#

set partNum     "xczu3eg-sbva484-1-i"
set hdlDir      "../hdl"
set RMs         "led_cnt_A led_cnt_B"
set rpCell      "led_cnt_pr_inst"
set rmDir       "../output_products_RM"

set RM_syn_args "$hdlDir $partNum \"$RMs\" $rmDir"

source 8_argsTest.tcl $RM_syn_args