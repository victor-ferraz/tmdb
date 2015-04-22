#DO NOT USE WITH MODELSIM-ALTERA VERSION OR MODELSIM-ALTERA Web Edition
#This file contains the commands to create libraries and compile the library file into those libraries.

set path_to_quartus h:/altera/13.1/quartus
set type_of_sim compile_all

# The type_of_sim should be one of the following values
# compile_all: Compiles all Altera libraries 
# functional: Compiles all libraries that are required for a functional simulation
# ip_functional: Compiles all libraries that are required functional simulation of Altera IP cores
# stratix_gx: Compiles all libraries that are required for a functional simulation of a StratixGX design
# apex20ke: Compiles all libraries that are required for an APEX20KE timing simulation
# apex20k: Compiles all libraries that are required for an APEX20K timing simulation
# apexii: Compiles all libraries that are required for an APEXII timing simulation
# cyclone: Compiles all libraries that are required for an CYCLONE timing simulation
# cycloneii: Compiles all libraries that are required for an CYCLONEII timing simulation
# cycloneiii: Compiles all libraries that are required for an CYCLONEIII timing simulation
# flex10ke: Compiles all libraries that are required for an FLEX10KE timing simulation
# flex6000: Compiles all libraries that are required for an FLEX6000 timing simulation
# hardcopy: Compiles all libraries that are required for an HARDCOPY timing simulation
# hardcopyii: Compiles all libraries that are required for an HARDCOPYII timing simulation
# max: Compiles all libraries that are required for an MAX timing simulation
# maxii: Compiles all libraries that are required for an MAXII timing simulation
# mercury: Compiles all libraries that are required for an MERCURY timing simulation
# stratix: Compiles all libraries that are required for an STRATIX timing simulation
# stratixii: Compiles all libraries that are required for an STRATIXII timing simulation
# stratixiii: Compiles all libraries that are required for an STRATIXIII timing simulation
# stratixgx_timing: Compiles all libraries that are required for an STRATIXGX timing simulation
# stratixiigx_timing: Compiles all libraries that are required for an STRATIXIIGX timing simulation
# arriagx_timing: Compiles all libraries that are required for an ARRIAGX timing simulation


if {[string equal $type_of_sim "compile_all"]} {
	vlib lpm
	vmap lpm lpm
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
	vlib altera_mf
	vmap altera_mf altera_mf
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf.vhd
	vlib altera
	vmap altera altera
	vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives_components.vhd
	vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives.vhd
	vlib sgate
	vmap sgate sgate
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd
	vlib altgxb
	vmap altgxb altgxb
	vcom -work altgxb -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_mf.vhd
	vcom -work altgxb -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_mf_components.vhd
	vlib apex20ke
	vmap apex20ke apex20ke
	vcom -work apex20ke -2002 -explicit $path_to_quartus/eda/sim_lib/apex20ke_atoms.vhd
	vcom -work apex20ke -2002 -explicit $path_to_quartus/eda/sim_lib/apex20ke_components.vhd
	vlib apex20k
	vmap apex20k apex20k
	vcom -work apex20k -2002 -explicit $path_to_quartus/eda/sim_lib/apex20k_atoms.vhd
	vcom -work apex20k -2002 -explicit $path_to_quartus/eda/sim_lib/apex20k_components.vhd
	vlib apexii
	vmap apexii apexii
	vcom -work apexii -2002 -explicit $path_to_quartus/eda/sim_lib/apexii_atoms.vhd
	vcom -work apexii -2002 -explicit $path_to_quartus/eda/sim_lib/apexii_components.vhd
	vlib cyclone
	vmap cyclone cyclone
	vcom -work cyclone -2002 -explicit $path_to_quartus/eda/sim_lib/cyclone_atoms.vhd
	vcom -work cyclone -2002 -explicit $path_to_quartus/eda/sim_lib/cyclone_components.vhd
	vlib cycloneii
	vmap cycloneii cycloneii
	vcom -work cycloneii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneii_atoms.vhd
	vcom -work cycloneii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneii_components.vhd
	vlib cycloneiii
	vmap cycloneiii cycloneiii
	vcom -work cycloneiii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiii_atoms.vhd
	vcom -work cycloneiii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiii_components.vhd
	vlib flex10ke
	vmap flex10ke flex10ke
	vcom -work flex10ke -2002 -explicit $path_to_quartus/eda/sim_lib/flex10ke_atoms.vhd
	vcom -work flex10ke -2002 -explicit $path_to_quartus/eda/sim_lib/flex10ke_components.vhd
	vlib flex6000
	vmap flex6000 flex6000
	vcom -work flex6000 -2002 -explicit $path_to_quartus/eda/sim_lib/flex6000_atoms.vhd
	vcom -work flex6000 -2002 -explicit $path_to_quartus/eda/sim_lib/flex6000_components.vhd
	vlib hcstratix
	vmap hcstratix hcstratix
	vcom -work hcstratix -2002 -explicit $path_to_quartus/eda/sim_lib/hcstratix_atoms.vhd
	vcom -work hcstratix -2002 -explicit $path_to_quartus/eda/sim_lib/hcstratix_components.vhd
	vlib hardcopyii
	vmap hardcopyii hardcopyii
	vcom -work hardcopyii -2002 -explicit $path_to_quartus/eda/sim_lib/hardcopyii_atoms.vhd
	vcom -work hardcopyii -2002 -explicit $path_to_quartus/eda/sim_lib/hardcopyii_components.vhd
	vlib max
	vmap max max
	vcom -work max -2002 -explicit $path_to_quartus/eda/sim_lib/max_atoms.vhd
	vcom -work max -2002 -explicit $path_to_quartus/eda/sim_lib/max_components.vhd
	vlib maxii
	vmap maxii maxii
	vcom -work maxii -2002 -explicit $path_to_quartus/eda/sim_lib/maxii_atoms.vhd
	vcom -work maxii -2002 -explicit $path_to_quartus/eda/sim_lib/maxii_components.vhd
	vlib mercury
	vmap mercury mercury
	vcom -work mercury -2002 -explicit $path_to_quartus/eda/sim_lib/mercury_atoms.vhd
	vcom -work mercury -2002 -explicit $path_to_quartus/eda/sim_lib/mercury_components.vhd
	vlib stratix
	vmap stratix stratix
	vcom -work stratix -2002 -explicit $path_to_quartus/eda/sim_lib/stratix_atoms.vhd
	vcom -work stratix -2002 -explicit $path_to_quartus/eda/sim_lib/stratix_components.vhd
	vlib stratixii
	vmap stratixii stratixii
	vcom -work stratixii -2002 -explicit $path_to_quartus/eda/sim_lib/stratixii_atoms.vhd
	vcom -work stratixii -2002 -explicit $path_to_quartus/eda/sim_lib/stratixii_components.vhd
	vlib stratixiii
	vmap stratixiii stratixiii
	vcom -work stratixiii -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiii_atoms.vhd
	vcom -work stratixiii -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiii_components.vhd
	vlib stratixgx
	vmap stratixgx stratixgx
	vcom -work stratixgx -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_atoms.vhd
	vcom -work stratixgx -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_components.vhd
	vlib stratixgx_gxb
	vmap stratixgx_gxb stratixgx_gxb
	vcom -work stratixgx_gxb -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_hssi_atoms.vhd
	vcom -work stratixgx_gxb -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_hssi_components.vhd
	vlib stratixiigx
	vmap stratixiigx stratixiigx
	vcom -work stratixiigx -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiigx_atoms.vhd
	vcom -work stratixiigx -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiigx_components.vhd
	vlib stratixiigx_hssi
	vmap stratixiigx_hssi stratixiigx_hssi
	vcom -work stratixiigx_hssi -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiigx_hssi_components.vhd
	vcom -work stratixiigx_hssi -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiigx_hssi_atoms.vhd
	vlib arriagx
	vmap arriagx arriagx
	vcom -work arriagx -2002 -explicit $path_to_quartus/eda/sim_lib/arriagx_atoms.vhd
	vcom -work arriagx -2002 -explicit $path_to_quartus/eda/sim_lib/arriagx_components.vhd
	vlib arriagx_gxb
	vmap arriagx_gxb arriagx_gxb
	vcom -work arriagx_gxb -2002 -explicit $path_to_quartus/eda/sim_lib/arriagx_hssi_components.vhd
	vcom -work arriagx_gxb -2002 -explicit $path_to_quartus/eda/sim_lib/arriagx_hssi_atoms.vhd
} elseif {[string equal $type_of_sim "functional"]} {
# required for functional simulation of designs that call LPM & altera_mf functions
	vlib lpm
	vmap lpm lpm
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
	vlib altera_mf
	vmap altera_mf altera_mf
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf.vhd
} elseif {[string equal $type_of_sim "ip_functional"]} {
# required for IP functional simualtion of designs
	vlib lpm
	vmap lpm lpm
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
	vlib altera_mf
	vmap altera_mf altera_mf
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf.vhd
	vlib sgate
	vmap sgate sgate
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd
} elseif {[string equal $type_of_sim "stratix_gx"]} {
# required for functional simulation of STRATIXGX designs
	vlib sgate
	vmap sgate sgate
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd
	vlib lpm
	vmap lpm lpm
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
	vlib altgxb
	vmap altgxb altgxb
	vcom -work altgxb -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_mf.vhd
	vcom -work altgxb -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_mf_components.vhd
} elseif {[string equal $type_of_sim "apex20ke"]} {
	# required for gate-level simulation of APEX20KE designs
	vlib apex20ke
	vmap apex20ke apex20ke
	vcom -work apex20ke -2002 -explicit $path_to_quartus/eda/sim_lib/apex20ke_atoms.vhd
	vcom -work apex20ke -2002 -explicit $path_to_quartus/eda/sim_lib/apex20ke_components.vhd
} elseif {[string equal $type_of_sim "apex20k"]} {
	# required for gate-level simulation of APEX20K designs
	vlib apex20k
	vmap apex20k apex20k
	vcom -work apex20k -2002 -explicit $path_to_quartus/eda/sim_lib/apex20k_atoms.vhd
	vcom -work apex20k -2002 -explicit $path_to_quartus/eda/sim_lib/apex20k_components.vhd
} elseif {[string equal $type_of_sim "apexii"]} {
	# required for gate-level simulation of APEXII designs
	vlib apexii
	vmap apexii apexii
	vcom -work apexii -2002 -explicit $path_to_quartus/eda/sim_lib/apexii_atoms.vhd
	vcom -work apexii -2002 -explicit $path_to_quartus/eda/sim_lib/apexii_components.vhd
} elseif {[string equal $type_of_sim "cyclone"]} {
	# required for gate-level simulation of CYCLONE designs
	vlib cyclone
	vmap cyclone cyclone
	vcom -work cyclone -2002 -explicit $path_to_quartus/eda/sim_lib/cyclone_atoms.vhd
	vcom -work cyclone -2002 -explicit $path_to_quartus/eda/sim_lib/cyclone_components.vhd
} elseif {[string equal $type_of_sim "cycloneii"]} {
	# required for gate-level simulation of CYCLONEII designs
	vlib cycloneii
	vmap cycloneii cycloneii
	vcom -work cycloneii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneii_atoms.vhd
	vcom -work cycloneii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneii_components.vhd
} elseif {[string equal $type_of_sim "cycloneiii"]} {
	# required for gate-level simulation of CYCLONEII designs
	vlib cycloneiii
	vmap cycloneiii cycloneiii
	vcom -work cycloneiii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiii_atoms.vhd
	vcom -work cycloneiii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiii_components.vhd
} elseif {[string equal $type_of_sim "flex10ke"]} {
	# required for gate-level simulation of FLEX10KE designs
	vlib flex10ke
	vmap flex10ke flex10ke
	vcom -work flex10ke -2002 -explicit $path_to_quartus/eda/sim_lib/flex10ke_atoms.vhd
	vcom -work flex10ke -2002 -explicit $path_to_quartus/eda/sim_lib/flex10ke_components.vhd
} elseif {[string equal $type_of_sim "flex6000"]} {
	# required for gate-level simulation of FLEX6000 designs
	vlib flex6000
	vmap flex6000 flex6000
	vcom -work flex6000 -2002 -explicit $path_to_quartus/eda/sim_lib/flex6000_atoms.vhd
	vcom -work flex6000 -2002 -explicit $path_to_quartus/eda/sim_lib/flex6000_components.vhd
} elseif {[string equal $type_of_sim "hardcopy"]} {
	# required for gate-level simulation of HARDCOPY STRATIX designs
	vlib hcstratix
	vmap hcstratix hcstratix
	vcom -work hcstratix -2002 -explicit $path_to_quartus/eda/sim_lib/hcstratix_atoms.vhd
	vcom -work hcstratix -2002 -explicit $path_to_quartus/eda/sim_lib/hcstratix_components.vhd
} elseif {[string equal $type_of_sim "hardcopyii"]} {
	# required for gate-level simulation of HARDCOPYII designs
	vlib hardcopyii
	vmap hardcopyii hardcopyii
	vcom -work hardcopyii -2002 -explicit $path_to_quartus/eda/sim_lib/hardcopyii_atoms.vhd
	vcom -work hardcopyii -2002 -explicit $path_to_quartus/eda/sim_lib/hardcopyii_components.vhd
} elseif {[string equal $type_of_sim "max"]} {
	# required for gate-level simulation of MAX designs
	vlib max
	vmap max max
	vcom -work max -2002 -explicit $path_to_quartus/eda/sim_lib/max_atoms.vhd
	vcom -work max -2002 -explicit $path_to_quartus/eda/sim_lib/max_components.vhd
} elseif {[string equal $type_of_sim "maxii"]} {
	# required for gate-level simulation of MAXII designs
	vlib maxii
	vmap maxii maxii
	vcom -work maxii -2002 -explicit $path_to_quartus/eda/sim_lib/maxii_atoms.vhd
	vcom -work maxii -2002 -explicit $path_to_quartus/eda/sim_lib/maxii_components.vhd
} elseif {[string equal $type_of_sim "mercury"]} {
	# required for gate-level simulation of MERCURY designs
	vlib mercury
	vmap mercury mercury
	vcom -work mercury -2002 -explicit $path_to_quartus/eda/sim_lib/mercury_atoms.vhd
	vcom -work mercury -2002 -explicit $path_to_quartus/eda/sim_lib/mercury_components.vhd
} elseif {[string equal $type_of_sim "stratix"]} {
	# required for gate-level simulation of STRATIX designs
	vlib stratix
	vmap stratix stratix
	vcom -work stratix -2002 -explicit $path_to_quartus/eda/sim_lib/stratix_atoms.vhd
	vcom -work stratix -2002 -explicit $path_to_quartus/eda/sim_lib/stratix_components.vhd
} elseif {[string equal $type_of_sim "stratixii"]} {
	# required for gate-level simulation of STRATIXII designs
	vlib stratixii
	vmap stratixii stratixii
	vcom -work stratixii -2002 -explicit $path_to_quartus/eda/sim_lib/stratixii_atoms.vhd
	vcom -work stratixii -2002 -explicit $path_to_quartus/eda/sim_lib/stratixii_components.vhd
} elseif {[string equal $type_of_sim "stratixiii"]} {
	# required for gate-level simulation of STRATIXIII designs
	vlib altera
	vmap altera altera
	vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives_components.vhd
	vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives.vhd
	vlib stratixiii
	vmap stratixiii stratixiii
	vcom -work stratixiii -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiii_atoms.vhd
	vcom -work stratixiii -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiii_components.vhd
} elseif {[string equal $type_of_sim "stratixiigx_timing"]} {
	# required for gate-level simulation of STRATIXIIGX designs
	vlib sgate
	vmap sgate sgate
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd
	vlib lpm
	vmap lpm lpm
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
	vlib stratixiigx
	vmap stratixiigx stratixiigx
	vcom -work stratixiigx -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiigx_atoms.vhd
	vcom -work stratixiigx -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiigx_components.vhd
	vlib stratixiigx_hssi
	vmap stratixiigx_hssi stratixiigx_hssi
	vcom -work stratixiigx_hssi -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiigx_hssi_atoms.vhd
	vcom -work stratixiigx_hssi -2002 -explicit $path_to_quartus/eda/sim_lib/stratixiigx_hssi_components.vhd
} elseif {[string equal $type_of_sim "stratixgx_timing"]} {
	# required for gate-level simulation of STRATIXGX designs
	vlib sgate
	vmap sgate sgate
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd
	vlib lpm
	vmap lpm lpm
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
	vlib stratixgx
	vmap stratixgx stratixgx
	vcom -work stratixgx -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_atoms.vhd
	vcom -work stratixgx -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_components.vhd
	vlib stratixgx_gxb
	vmap stratixgx_gxb stratixgx_gxb
	vcom -work stratixgx_gxb -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_hssi_atoms.vhd
	vcom -work stratixgx_gxb -2002 -explicit $path_to_quartus/eda/sim_lib/stratixgx_hssi_components.vhd
} elseif {[string equal $type_of_sim "arriagx_timing"]} {
	# required for gate-level simulation of ARRIAGX designs
	vlib sgate
	vmap sgate sgate
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd
	vlib lpm
	vmap lpm lpm
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
	vlib arriagx
	vmap arriagx arriagx
	vcom -work arriagx -2002 -explicit $path_to_quartus/eda/sim_lib/arriagx_atoms.vhd
	vcom -work arriagx -2002 -explicit $path_to_quartus/eda/sim_lib/arriagx_components.vhd
	vlib arriagx_gxb
	vmap arriagx_gxb arriagx_gxb
	vcom -work arriagx_gxb -2002 -explicit $path_to_quartus/eda/sim_lib/arriagx_hssi_atoms.vhd
	vcom -work arriagx_gxb -2002 -explicit $path_to_quartus/eda/sim_lib/arriagx_hssi_components.vhd
} else {
	puts "invalid code"
}


