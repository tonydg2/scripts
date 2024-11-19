TODO: -skipIMP and -skipSYN args will not create the output_products folder, need to check if exists first, create only if NOT exist

### Do NOT name the cloned scripts repo anything other than 'scripts'. Or modify BUILD.tcl.
### Scripts repo/folder must be cloned at the top, otherwise git hash parsing will fail.
### No spaces allowed in any filenames or folders. Scripts will fail.

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

## script to build : BUILD.tcl
> tclsh BUILD.tcl

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

-noIP       : run as if there are no IP in the IP/tcl folder (even if there are).

-noRM       : run as if there are no RMs in the RM* folders (even if there are).

-proj       : generate BD project only. must be run with -name option.

-name       : name of BD project, "-name \<project-name>". 

## Examples / Quick copies
#### Build full design generating new BD project with name PRJ2, and generate IP in the ip folder. This would also build DFX partials if there were any present.
> tclsh BUILD.tcl -clean -name PRJ2

#### Build full design generating new BD project with name PRJ0, there are IP tcl files in IP folder not in use for this design (-noIP).
> tclsh BUILD.tcl -clean -name PRJ0 -noIP

#### Build with BD project PRJ0 already generated, there are IP tcl files in IP folder not in use for this design (-noIP).
> tclsh BUILD.tcl -clean -name PRJ0 -skipBD -noIP

#### Generate BD project only
> tclsh BUILD.tcl -clean -proj -name PRJ1

#### Build with BD project PRJ2 already generated, only up to synth for review of synth dcp.
> tclsh BUILD.tcl -clean -name PRJ2 -skipBD -noIP -skipIMP

#### Build with BD project PRJ2 already generated, skip synth and use previous synth dcp (output_products) to continue with imp.
> tclsh BUILD.tcl -clean -name PRJ2 -skipBD -noIP -skipSYN

#### Generate IP and IP project only
> tclsh BUILD.tcl -clean -skipBD -skipRM -skipSYN -skipIMP

#### Build with BD project PRJ0 already generated, clean and regenerate all IP in ip folder
> tclsh BUILD.tcl -name PRJ0 -skipBD -clean -cleanIP