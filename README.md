# DFX
- This version is automated. Verified on U96 with three RPs and three RMs each.
- RMs must be in folders named RM* in hdl directory.
- Each RM must have same module name.
- RM folders are parsed to get module names.
- RP instance in static region MUST be named "\<RM module name>_inst"
  - Ex. RM0 = "led_cnt_pr", instance in io_top must be "led_cnt_pr_inst".
- Currently, only one full config is built. This will be the 'first' RM for each RP which are sorted ASCII.
  - Empty static is not built, there is an option to enable this in 'imp.tcl'.
  - All partial bitstreams are generated.
- No VHDL. Verilog and systemverilog only.

## script to build : RUN_BUILD.tcl
> tclsh RUN_BUILD.tcl

### Arguments
-clean      : cleans old generated files in scripts folder from previous builds.

-cleanIP    : clean all generated IP products in ip folder.

-noCleanImg : prevents cleaning/moving the output_products folder. Otherwise new builds will rename
              the previous outputs_products folder to 'outputs_products_previous', and start clean 
              with an empty output_products folder. This function is automatic when using 
              -skipRM(only if DFX project), -skipSYN, -skipIMP arguments.

-skipIP     : skip generating IP, if already generated and no changes have been made.

-skipRM     : (DFX projects only) skip synthesizing RMs if they're already done and no changes have
              been made. This will be skipped automatically if there are no RM* folders (non-DFX project).

-skipBD     : skip generating BD if already done and no changes made.

-skipSYN    : skip synthesis of full design (static if DFX proj), generally for debug, or if only need
              to run implementation with previous synth DCP.

-skipIMP    : skip implementation and bitstream gen, generally for debug, or just desire other steps
              output products.

