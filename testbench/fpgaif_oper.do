onerror {resume}
quietly virtual signal -install /tmdb_testbench {/tmdb_testbench/vme_addr  } teste
quietly virtual signal -install /tmdb_testbench { (context /tmdb_testbench )( vme_addr(1) & vme_addr(2) & vme_addr(3) & vme_addr(4) & vme_addr(5) & vme_addr(6) & vme_addr(7) & vme_addr(8) & vme_addr(9) & vme_addr(10) & vme_addr(11) & vme_addr(12) & vme_addr(13) & vme_addr(14) & vme_addr(15) & vme_addr(16) & vme_addr(17) & vme_addr(18) & vme_addr(19) & vme_addr(20) & vme_addr(21) & vme_addr(22) & vme_addr(23) & vme_addr(24) & vme_addr(25) & vme_addr(26) & vme_addr(27) & vme_addr(28) & vme_addr(29) & vme_addr(30) & vme_addr(31) )} teste001
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock / Reset}
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/rst
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/clk
add wave -noupdate -divider {Master IF}
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/fpga_interface/addr
add wave -noupdate -radix hexadecimal -childformat {{/tmdb_testbench/vme_fpga/fpga_interface/data_in(31) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(30) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(29) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(28) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(27) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(26) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(25) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(24) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(23) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(22) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(21) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(20) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(19) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(18) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(17) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(16) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(15) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(14) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(13) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(12) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(11) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(10) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(9) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(8) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(7) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(6) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(5) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(4) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(3) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(2) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(1) -radix hexadecimal} {/tmdb_testbench/vme_fpga/fpga_interface/data_in(0) -radix hexadecimal}} -subitemconfig {/tmdb_testbench/vme_fpga/fpga_interface/data_in(31) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(30) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(29) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(28) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(27) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(26) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(25) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(24) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(23) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(22) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(21) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(20) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(19) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(18) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(17) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(16) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(15) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(14) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(13) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(12) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(11) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(10) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(9) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(8) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(7) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(6) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(5) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(4) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(3) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(2) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(1) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/fpga_interface/data_in(0) {-height 15 -radix hexadecimal}} /tmdb_testbench/vme_fpga/fpga_interface/data_in
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/fpga_interface/data_out
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/write
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/read
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/dtack
add wave -noupdate -divider {Master Transfer FSM}
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/state
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/next_state
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/word_counter_en
add wave -noupdate -divider {Master Internal (Write Operation)}
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/write_ack
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/read_ack
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/fpga_interface/c_data
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/fpga_interface/word_counter
add wave -noupdate -divider {Master Internal (Read Operation)}
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/fi_data_buf_en
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/fpga_interface/r_fi_data
add wave -noupdate -divider FI
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/fpga_interface/fi_addr
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/fpga_interface/fi_data
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/fi_write
add wave -noupdate /tmdb_testbench/vme_fpga/fpga_interface/fi_read
add wave -noupdate -divider {Slave Transfer FSM}
add wave -noupdate /tmdb_testbench/core_fpga/sfpga_interface/state
add wave -noupdate /tmdb_testbench/core_fpga/sfpga_interface/next_state
add wave -noupdate /tmdb_testbench/core_fpga/sfpga_interface/word_counter_en
add wave -noupdate /tmdb_testbench/core_fpga/sfpga_interface/r_word_counter_en
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/sfpga_interface/word_counter
add wave -noupdate -divider {Slave Internal (Master Write Operation)}
add wave -noupdate /tmdb_testbench/core_fpga/sfpga_interface/fi_data_buf_en
add wave -noupdate -radix hexadecimal -childformat {{/tmdb_testbench/core_fpga/sfpga_interface/r_fi_data(3) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/r_fi_data(2) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/r_fi_data(1) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/r_fi_data(0) -radix hexadecimal}} -subitemconfig {/tmdb_testbench/core_fpga/sfpga_interface/r_fi_data(3) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/r_fi_data(2) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/r_fi_data(1) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/r_fi_data(0) {-height 15 -radix hexadecimal}} /tmdb_testbench/core_fpga/sfpga_interface/r_fi_data
add wave -noupdate -divider {Slave Internal (Master Read Operation)}
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/sfpga_interface/r_data_in
add wave -noupdate -radix hexadecimal -childformat {{/tmdb_testbench/core_fpga/sfpga_interface/c_data(7) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/c_data(6) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/c_data(5) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/c_data(4) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/c_data(3) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/c_data(2) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/c_data(1) -radix hexadecimal} {/tmdb_testbench/core_fpga/sfpga_interface/c_data(0) -radix hexadecimal}} -subitemconfig {/tmdb_testbench/core_fpga/sfpga_interface/c_data(7) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/c_data(6) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/c_data(5) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/c_data(4) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/c_data(3) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/c_data(2) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/c_data(1) {-height 15 -radix hexadecimal} /tmdb_testbench/core_fpga/sfpga_interface/c_data(0) {-height 15 -radix hexadecimal}} /tmdb_testbench/core_fpga/sfpga_interface/c_data
add wave -noupdate -divider {Slave IF}
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/sfpga_interface/addr
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/sfpga_interface/data_in
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/sfpga_interface/data_out
add wave -noupdate /tmdb_testbench/core_fpga/sfpga_interface/read
add wave -noupdate /tmdb_testbench/core_fpga/sfpga_interface/write
add wave -noupdate -divider Extra
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/i_vme_data
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr
add wave -noupdate -radix hexadecimal -childformat {{/tmdb_testbench/vme_fpga/user_data_mux(1) -radix hexadecimal} {/tmdb_testbench/vme_fpga/user_data_mux(0) -radix hexadecimal}} -subitemconfig {/tmdb_testbench/vme_fpga/user_data_mux(1) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/user_data_mux(0) {-height 15 -radix hexadecimal}} /tmdb_testbench/vme_fpga/user_data_mux
add wave -noupdate /tmdb_testbench/vme_fpga/encoded_read
add wave -noupdate /tmdb_testbench/core_fpga/sfpga_interface/rst
add wave -noupdate /tmdb_testbench/core_fpga/sfpga_interface/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13253165 ps} 0} {{Cursor 2} {12948705 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 357
configure wave -valuecolwidth 84
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
WaveRestoreZoom {12650176 ps} {13749472 ps}
