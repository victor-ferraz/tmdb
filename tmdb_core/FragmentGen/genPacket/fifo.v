//==================================================================================================
//  Filename      : fifo.v
//  Created On    : 2013-12-18 09:43:05
//  Last Modified : 2015-02-19 09:26:15
//  Revision      : 
//  Author        : Linton Esteves
//  Company       : UFBA
//  Email         : linton.thiago@gmail.com
//
//  Description   : 
//
//
//==================================================================================================
module fifo
       #(
        parameter DATA_WIDTH = 8,
        parameter ADDRESS_WIDTH = 4,
        parameter FIFO_DEPTH = 2**ADDRESS_WIDTH                              
       )
       (/*autoport*/
        //input
        input clk,
        input rst,
        input [DATA_WIDTH-1:0] write_data,
        input write_enable,
        input read_enable,
        //outputs
        output [DATA_WIDTH-1:0] read_data
        
       );

reg [ADDRESS_WIDTH-1:0] read_pointer, 
                        write_pointer;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        read_pointer <= {ADDRESS_WIDTH{1'b0}};
    end
    else begin
        if (read_enable) begin
            read_pointer <= read_pointer + 1'b1;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        write_pointer <= {ADDRESS_WIDTH{1'b0}};
    end
    else begin
        if (write_enable) begin
            write_pointer <= write_pointer + 1'b1;
        end
    end
end

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

assign read_data = mem[read_pointer]; 

`else
//inserir memorias para modo fpga
//e para dar erro mesmo hehe


`endif

endmodule