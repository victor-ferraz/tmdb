onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/rst
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/clk
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/enable
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/holaReset
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/holaResetR
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/normalOper
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/LDOWN_N
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/URESET_N
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/upCntr
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/lupEn
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/state
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/holaReset_i/next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {516096 ps}
