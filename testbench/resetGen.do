onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tmdb_testbench/core_fpga/resetGen_i/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/resetGen_i/resetRequestWord
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/resetGen_i/locked
add wave -noupdate /tmdb_testbench/core_fpga/resetGen_i/userResetRequest
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/resetGen_i/powerOnReset
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/resetGen_i/resetRequest
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /tmdb_testbench/core_fpga/resetGen_i/resetPeriodCntr
add wave -noupdate /tmdb_testbench/core_fpga/resetGen_i/resetPeriodEn
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/resetGen_i/state
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/resetGen_i/next
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/core_fpga/resetGen_i/resetOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2588710 ps} 0}
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
WaveRestoreZoom {0 ps} {8192 ns}
