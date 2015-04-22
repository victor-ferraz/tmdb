onerror {resume}
quietly virtual signal -install /tmdb_testbench {/tmdb_testbench/vme_addr  } teste
quietly virtual signal -install /tmdb_testbench { (context /tmdb_testbench )( vme_addr(1) & vme_addr(2) & vme_addr(3) & vme_addr(4) & vme_addr(5) & vme_addr(6) & vme_addr(7) & vme_addr(8) & vme_addr(9) & vme_addr(10) & vme_addr(11) & vme_addr(12) & vme_addr(13) & vme_addr(14) & vme_addr(15) & vme_addr(16) & vme_addr(17) & vme_addr(18) & vme_addr(19) & vme_addr(20) & vme_addr(21) & vme_addr(22) & vme_addr(23) & vme_addr(24) & vme_addr(25) & vme_addr(26) & vme_addr(27) & vme_addr(28) & vme_addr(29) & vme_addr(30) & vme_addr(31) )} teste001
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Clocks
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/clock_40mhz
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/vme_sysclock
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/i_clock
add wave -noupdate -divider Resets
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/vme_sysreset
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/powerup_reset
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/i_reset
add wave -noupdate -divider Errors
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/i_error
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/i_usr_error
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/vme_berr
add wave -noupdate -divider Control
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/i_vme_as
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/i_vme_ds
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/i_vme_read
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/i_vme_write
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/vme_ds0
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/vme_ds1
add wave -noupdate -divider {Internal VME Bus}
add wave -noupdate -radix hexadecimal -childformat {{/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(31) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(30) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(29) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(28) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(27) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(26) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(25) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(24) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(23) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(22) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(21) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(20) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(19) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(18) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(17) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(16) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(15) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(14) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(13) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(12) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(11) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(10) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(9) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(8) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(7) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(6) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(5) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(4) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(3) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(2) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(1) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(0) -radix hexadecimal}} -subitemconfig {/tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(31) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(30) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(29) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(28) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(27) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(26) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(25) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(24) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(23) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(22) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(21) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(20) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(19) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(18) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(17) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(16) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(15) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(14) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(13) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(12) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(11) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(10) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(9) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(8) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(7) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(6) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(5) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(4) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(3) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(2) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(1) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr(0) {-height 15 -radix hexadecimal}} /tmdb_testbench/vme_fpga/my_vmeif/i_vme_addr
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/i_vme_am
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/i_vme_data
add wave -noupdate -radix hexadecimal -childformat {{/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(24) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(23) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(22) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(21) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(20) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(19) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(18) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(17) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(16) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(15) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(14) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(13) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(12) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(11) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(10) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(9) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(8) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(7) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(6) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(5) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(4) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(3) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(2) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(1) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(0) -radix hexadecimal}} -subitemconfig {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(24) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(23) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(22) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(21) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(20) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(19) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(18) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(17) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(16) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(15) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(14) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(13) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(12) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(11) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(10) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(9) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(8) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(7) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(6) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(5) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(4) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(3) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(2) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(1) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr(0) {-height 15 -radix hexadecimal}} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_addr
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/o_vme_am
add wave -noupdate -radix hexadecimal -childformat {{/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(31) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(30) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(29) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(28) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(27) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(26) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(25) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(24) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(23) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(22) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(21) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(20) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(19) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(18) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(17) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(16) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(15) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(14) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(13) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(12) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(11) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(10) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(9) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(8) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(7) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(6) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(5) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(4) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(3) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(2) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(1) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(0) -radix hexadecimal}} -subitemconfig {/tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(31) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(30) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(29) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(28) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(27) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(26) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(25) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(24) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(23) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(22) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(21) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(20) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(19) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(18) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(17) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(16) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(15) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(14) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(13) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(12) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(11) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(10) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(9) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(8) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(7) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(6) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(5) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(4) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(3) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(2) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(1) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data(0) {-height 15 -radix hexadecimal}} /tmdb_testbench/vme_fpga/my_vmeif/o_vme_data
add wave -noupdate -divider {Internal User Bus}
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/usr_addr_match
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/i_user_data
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/o_user_data
add wave -noupdate -divider {User Bus}
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/user_addr
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/user_addr_out
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/user_am
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/user_am_out
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/user_data
add wave -noupdate -radix hexadecimal /tmdb_testbench/vme_fpga/my_vmeif/user_data_in
add wave -noupdate -radix hexadecimal -childformat {{/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(31) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(30) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(29) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(28) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(27) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(26) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(25) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(24) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(23) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(22) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(21) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(20) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(19) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(18) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(17) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(16) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(15) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(14) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(13) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(12) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(11) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(10) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(9) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(8) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(7) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(6) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(5) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(4) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(3) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(2) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(1) -radix hexadecimal} {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(0) -radix hexadecimal}} -subitemconfig {/tmdb_testbench/vme_fpga/my_vmeif/user_data_out(31) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(30) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(29) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(28) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(27) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(26) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(25) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(24) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(23) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(22) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(21) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(20) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(19) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(18) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(17) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(16) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(15) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(14) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(13) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(12) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(11) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(10) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(9) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(8) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(7) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(6) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(5) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(4) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(3) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(2) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(1) {-height 15 -radix hexadecimal} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out(0) {-height 15 -radix hexadecimal}} /tmdb_testbench/vme_fpga/my_vmeif/user_data_out
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/user_write
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/user_read
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/user_valid
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/user_dtack
add wave -noupdate /tmdb_testbench/vme_fpga/my_vmeif/user_error
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1288529 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 424
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
WaveRestoreZoom {1305483 ps} {3468171 ps}