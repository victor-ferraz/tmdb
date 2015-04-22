
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name tmdb_core -dir "G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/ISE/planAhead_run_1" -part xc6slx150tfgg676-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/ISE/tmdb_core.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/ISE} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/tmdb_core.ucf" [current_fileset -constrset]
add_files [list {G:/Users/v/varaujof/Projects/ISE/tmdb_core_glink0_tlk_recclk_no_buffer/tmdb_core.ucf}] -fileset [get_property constrset [current_run]]
link_design
