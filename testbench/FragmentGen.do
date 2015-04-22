onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/rst
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/clk
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/enable
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/testEn
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/testSel
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/adcConstantSel
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/l1a
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/bCnt
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/bCntStr
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/evCntLStr
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/evCntHStr
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/test_l1a
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/test_bCnt
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/test_bCntStr
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/test_evCntLStr
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/test_evCntHStr
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/l1aM
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/bCntM
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/bCntStrM
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/evCntLStrM
add wave -noupdate /tmdb_testbench/core_fpga/fragGen/FragmentGen_i/evCntHStrM
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {568569 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {512 ns}
