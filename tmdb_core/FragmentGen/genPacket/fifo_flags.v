//==================================================================================================
//  Filename      : fifo_flags.v
//  Created On    : 2013-12-18 09:43:05
//  Last Modified : 2015-02-21 11:44:41
//  Revision      : 
//  Author        : Linton Esteves
//  Company       : UFBA
//  Email         : linton.thiago@gmail.com
//
//  Description   : 
//
//
//==================================================================================================
module fifo_flags
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
        output full_flag,
        output empty_flag,
        output [DATA_WIDTH-1:0] read_data
        
       );

reg [ADDRESS_WIDTH-1:0] read_pointer, 
                        write_pointer;

reg [ADDRESS_WIDTH:0] fifo_cnt;

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


always @ (posedge clk or posedge rst)
begin
  if(rst)
    fifo_cnt <= {ADDRESS_WIDTH{1'b0}};
  else begin
    if (read_enable && write_enable)
      fifo_cnt <= fifo_cnt;
    else if(read_enable)
      fifo_cnt <= fifo_cnt - 1'b1;
    else if(write_enable)
      fifo_cnt <= fifo_cnt + 1'b1;
  end
end

//Necessario caso ocorram duas escritas seguidas
assign full_flag = (fifo_cnt == FIFO_DEPTH);
assign empty_flag = fifo_cnt == 0;
endmodule