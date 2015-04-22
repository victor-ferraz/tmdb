onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/rst
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/clk
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/enable
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/l1a
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/bCnt
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/bCntStr
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/evCntLStr
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/evCntHStr
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/evCntRes
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/bCntRes
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/delayedL1a
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/bcid
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/evCnt
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/wrStb
add wave -noupdate -radix unsigned /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/dataCount
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/empty
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/full
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/prog_empty
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/prog_full
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/dataOut
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/L1aProc_i/rdStb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {650692 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 158
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
WaveRestoreZoom {0 ps} {8126464 ps}
