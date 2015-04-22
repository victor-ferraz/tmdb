
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name tmdb_core -dir "G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/ISE/planAhead_run_1" -part xc6slx150tfgg676-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/ISE/tmdb_core.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/ISE} {../ipcore_dir_13_3} {../ipcore_dir} }
add_files [list {../ipcore_dir_13_3/lfifo.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../ipcore_dir_13_3/vfifo.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../ipcore_dir_13_3/wfifo.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../ipcore_dir/chipscope_icon.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../ipcore_dir/chipscope_ila.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../ipcore_dir/chipscope_ila_512.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../ipcore_dir/chipscope_vio.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../ipcore_dir/xfifolsc.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/tmdb_core/tmdb_core.ucf" [current_fileset -constrset]
add_files [list {G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/tmdb_core/tmdb_core.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/ISE/tmdb_core.ncd"
if {[catch {read_twx -name results_1 -file "G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/ISE/tmdb_core.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/ISE/tmdb_core.twx\": $eInfo"
}
