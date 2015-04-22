//==================================================================================================
//  Filename      : circular_fifo.v
//  Created On    : 2013-12-18 09:43:05
//  Last Modified : 2015-02-21 09:54:20
//  Revision      : 
//  Author        : Linton Esteves
//  Company       : UFBA
//  Email         : linton.thiago@gmail.com
//
//  Description   : 
//
//
//==================================================================================================
module circular_fifo
       #(
        parameter DATA_WIDTH = 8,
        parameter ADDRESS_WIDTH = 8,
        parameter FIFO_DEPTH = 2**ADDRESS_WIDTH                              
       )
       (/*autoport*/
        //input
        input clk,
        input rst,
        input [DATA_WIDTH-1:0] write_data,
        input write_enable,
        input [ADDRESS_WIDTH-1:0] read_address,
        input [ADDRESS_WIDTH-1:0] write_pointer,
        //outputs
        output [DATA_WIDTH-1:0] read_data
        
       );

// always @(posedge clk or posedge rst) begin
//     if (rst) begin
//         write_pointer <= {ADDRESS_WIDTH{1'b0}};
//     end
//     else begin
//         if (write_enable) begin
//             write_pointer <= write_pointer + 1'b1;
//         end
//     end
// end

`ifdef SIMULATE

reg [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < FIFO_DEPTH; i = i + 1)begin
            mem[i] <= {DATA_WIDTH{1'b0}};
        end
    end
    else begin
        if (write_enable) begin
            mem[write_pointer] <= write_data;
        end
    end
end

assign read_data = mem[read_address]; 

`else
//trocar por memoria para o fpga

fifo_mem sram
(
   .clock(clk), 
   .wren(write_enable), 
   .data(write_data), 
   .w_addr(write_pointer),
   .rd_addr(read_address),
   .q(read_data)
);

`endif

endmodule