##############################################################################
##    ____  ____
##   /   /\/   /
##  /___/  \  /    Vendor: Xilinx
##  \   \   \/     Version : 1.11
##   \   \         Application : Spartan-6 FPGA GTP Transceiver Wizard
##   /   /         Filename : gtp_dual_1_xmdf.tcl
##  /___/   /\      
##  \   \  /  \ 
##   \___\/\___\
## 

# ::gen_comp_name_xmdf::xmdfApplyParams
# The package naming convention is <core_name>_xmdf
package provide gtp_dual_1_xmdf 1.0

# This includes some utilities that support common XMDF operations
package require utilities_xmdf

# Define a namespace for this package. The name of the name space
# is <core_name>_xmdf
namespace eval ::gtp_dual_1_xmdf {
# Use this to define any statics
}

# Function called by client to rebuild the params and port arrays
# Optional when the use context does not require the param or ports
# arrays to be available.
proc ::gtp_dual_1_xmdf::xmdfInit { instance } {
# Variable containg name of library into which module is compiled
# Recommendation: <module_name>
# Required
utilities_xmdf::xmdfSetData $instance Module Attributes Name gtp_dual_1
}
# ::gtp_dual_1_xmdf::xmdfInit

# Function called by client to fill in all the xmdf* data variables
# based on the current settings of the parameters
proc ::gtp_dual_1_xmdf::xmdfApplyParams { instance } {

set fcount 0
# Array containing libraries that are assumed to exist
# Examples include unisim and xilinxcorelib
# Optional
# In this example, we assume that the unisim library will
# be magically
# available to the simulation and synthesis tool
utilities_xmdf::xmdfSetData $instance FileSet $fcount type logical_library
utilities_xmdf::xmdfSetData $instance FileSet $fcount logical_library unisim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/doc/s6_gtpwizard_ds713.pdf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount
utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/doc/s6_gtpwizard_gsg546.pdf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/example_design/mgt_usrclk_source.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog 
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/example_design/gtp_dual_1_tx_sync.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog 
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/example_design/frame_gen.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog 
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/example_design/frame_check.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog 
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/example_design/gtp_dual_1_top.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog 
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1_tile.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog 
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog 
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1.veo
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog_template
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/example_design/gtp_attributes.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ucf
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/example_design/gtp_dual_1_top.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ucf
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/chipscope_project.cpj
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/data_vio.ngc
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ngc
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/icon.ngc
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ngc
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/ila.ngc
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ngc
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/implement.bat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/implement.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/implement_synplify.bat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/implement_synplify.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/null_vio.ngc
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ngc
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/shared_vio.ngc
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ngc
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/synplify.prj
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/xst.prj
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/implement/xst.scr
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/s6_gtpwizard_v1_11_readme.txt
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/gtp_dual_1.pf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/demo_tb.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/simulate_isim.bat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/simulate_isim.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/simulate_mti.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/simulate_ncsim.bat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/simulate_ncsim.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/simulate_vcs.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/ucli_commands.key
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/vcs_session.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/wave_isim.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/wave_mti.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1/simulation/functional/wave_ncsim.sv
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount


utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1.xco
utilities_xmdf::xmdfSetData $instance FileSet $fcount type coregen_ip
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path gtp_dual_1_xmdf.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type AnyView
incr fcount

#utilities_xmdf::xmdfSetData $instance FileSet $fcount associated_module gtp_dual_1
#incr fcount

}

# ::gen_comp_name_xmdf::xmdfApplyParams



