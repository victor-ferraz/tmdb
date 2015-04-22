onerror {resume}
quietly virtual signal -install /tmdb_testbench {/tmdb_testbench/vme_addr  } teste
quietly virtual signal -install /tmdb_testbench { (context /tmdb_testbench )( vme_addr(1) & vme_addr(2) & vme_addr(3) & vme_addr(4) & vme_addr(5) & vme_addr(6) & vme_addr(7) & vme_addr(8) & vme_addr(9) & vme_addr(10) & vme_addr(11) & vme_addr(12) & vme_addr(13) & vme_addr(14) & vme_addr(15) & vme_addr(16) & vme_addr(17) & vme_addr(18) & vme_addr(19) & vme_addr(20) & vme_addr(21) & vme_addr(22) & vme_addr(23) & vme_addr(24) & vme_addr(25) & vme_addr(26) & vme_addr(27) & vme_addr(28) & vme_addr(29) & vme_addr(30) & vme_addr(31) )} teste001
quietly WaveActivateNextPane {} 0
add wave -noupdate /tmdb_testbench/core_fpga/registers/clk
add wave -noupdate /tmdb_testbench/core_fpga/registers/rst
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/registers/addr
add wave -noupdate /tmdb_testbench/core_fpga/registers/read
add wave -noupdate /tmdb_testbench/core_fpga/registers/write
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/registers/iData
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/registers/oData
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/registers/iReg
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/registers/oReg
add wave -noupdate /tmdb_testbench/core_fpga/registers/pWrite
add wave -noupdate /tmdb_testbench/core_fpga/registers/pRead
add wave -noupdate /tmdb_testbench/core_fpga/registers/c_addrStb
add wave -noupdate /tmdb_testbench/core_fpga/registers/c_decWr
add wave -noupdate /tmdb_testbench/core_fpga/registers/c_decRd
add wave -noupdate /tmdb_testbench/core_fpga/registers/r_decWr
add wave -noupdate /tmdb_testbench/core_fpga/registers/r_decRd
add wave -noupdate -radix hexadecimal /tmdb_testbench/core_fpga/registers/regs
add wave -noupdate /tmdb_testbench/core_fpga/registers/locked
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12947121 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 311
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
WaveRestoreZoom {12715906 ps} {13151106 ps}
