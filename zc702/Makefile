build: scripts/run.tcl scripts/build.tcl scripts/load_git_hash.tcl
	cd scripts; \
		tclsh run.tcl -clean

all: scripts/run.tcl scripts/build.tcl scripts/load_git_hash.tcl
	rm -rf prj0
	cd scripts; \
		tclsh run.tcl -clean -proj; \
		tclsh run.tcl -clean

project: scripts/run.tcl scripts/build.tcl scripts/load_git_hash.tcl
	rm -rf prj0
	cd scripts; \
		tclsh run.tcl -clean -proj

clean:
	rm -rf prj0 output_products output_products_previous
