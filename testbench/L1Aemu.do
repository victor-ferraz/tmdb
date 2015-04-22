onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tmdb_testbench/L1Aemu_i/clk
add wave -noupdate -radix decimal /tmdb_testbench/L1Aemu_i/data
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/L1Aemu_i/trigger
add wave -noupdate /tmdb_testbench/L1Aemu_i/lcountEn
add wave -noupdate -radix unsigned /tmdb_testbench/L1Aemu_i/lcounter
add wave -noupdate /tmdb_testbench/L1Aemu_i/delayedL1a
add wave -noupdate -radix unsigned /tmdb_testbench/L1Aemu_i/bcid
add wave -noupdate -radix unsigned /tmdb_testbench/L1Aemu_i/evCnt
add wave -noupdate -divider <NULL>
add wave -noupdate /tmdb_testbench/L1Aemu_i/l1a
add wave -noupdate -radix hexadecimal /tmdb_testbench/L1Aemu_i/bCnt
add wave -noupdate /tmdb_testbench/L1Aemu_i/bCntStr
add wave -noupdate /tmdb_testbench/L1Aemu_i/evCntLStr
add wave -noupdate /tmdb_testbench/L1Aemu_i/evCntHStr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {574760 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 253
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
WaveRestoreZoom {383386 ps} {846234 ps}
