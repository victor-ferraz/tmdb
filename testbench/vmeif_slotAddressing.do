onerror {resume}
quietly virtual signal -install /tmdb_testbench {/tmdb_testbench/vme_addr  } teste
quietly virtual signal -install /tmdb_testbench { (context /tmdb_testbench )( vme_addr(1) & vme_addr(2) & vme_addr(3) & vme_addr(4) & vme_addr(5) & vme_addr(6) & vme_addr(7) & vme_addr(8) & vme_addr(9) & vme_addr(10) & vme_addr(11) & vme_addr(12) & vme_addr(13) & vme_addr(14) & vme_addr(15) & vme_addr(16) & vme_addr(17) & vme_addr(18) & vme_addr(19) & vme_addr(20) & vme_addr(21) & vme_addr(22) & vme_addr(23) & vme_addr(24) & vme_addr(25) & vme_addr(26) & vme_addr(27) & vme_addr(28) & vme_addr(29) & vme_addr(30) & vme_addr(31) )} teste001
quietly WaveActivateNextPane {} 0
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/vme_gap
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/ga_par
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/vme_ga
add wave -noupdate -radix hexadecimal -childformat {{/tmdb_testbench/vme_fpga/my_vmeif/BAR(4) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/BAR(3) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/BAR(2) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/BAR(1) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/BAR(0) -radix hexadecimal}} -subitemconfig {/tmdb_testbench/vme_fpga/my_vmeif/BAR(4) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/BAR(3) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/BAR(2) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/BAR(1) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/BAR(0) {-height 15 -radix hexadecimal}} /tmdb_testbench/vme_fpga/my_vmeif/BAR
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/ADER
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/ADEM
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1495011 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 369
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {4035584 ps}
