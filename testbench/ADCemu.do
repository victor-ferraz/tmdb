onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tmdb_testbench/ADCemu_i/clk
add wave -noupdate -radix decimal /tmdb_testbench/ADCemu_i/rom
add wave -noupdate -radix decimal /tmdb_testbench/ADCemu_i/counter
add wave -noupdate -radix decimal /tmdb_testbench/ADCemu_i/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 289
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
WaveRestoreZoom {0 ps} {445363 ps}
