//==================================================================================================
//  Filename      : packet_control.v
//  Created On    : 2015-03-16 21:36:05
//  Last Modified : 2015-03-28 09:29:02
//  Revision      : 
//  Author        : Linton Esteves
//  Company       : UFBA
//  Email         : linton.thiago@gmail.com
//  Description   : 
//
//
//==================================================================================================
module packet_control
      #(
         parameter DATA_WIDTH = 8,
         parameter DELAY_WIDTH = 4,
         parameter NUM_SAMPLES = 7,
         parameter L1_ADDRESS_WIDTH = 7,
         parameter L2_ADDRESS_WIDTH = 8,
         parameter L2_FIFO_DEPTH = 2**L2_ADDRESS_WIDTH,
         parameter L1_FIFO_DEPTH = 2**L1_ADDRESS_WIDTH
           
      )
      (/*autoport*/
         input clk_in,
         input rst_in,
         input [DATA_WIDTH-1:0] data_in,
         input [L1_ADDRESS_WIDTH-1:0] l1_write_pointer_in,
         input [L1_ADDRESS_WIDTH-1:0] l1_reference_addr_in,

         input trigger_in,
         input [DELAY_WIDTH-1:0] delay_in,

         input request_data_in,
         output [DATA_WIDTH-1:0] read_data_out         
      );

//*******************************************************
//Internal
//*******************************************************
//Local Parameters

//Wires
wire [L1_ADDRESS_WIDTH-1:0] read_address_l1;
wire [DATA_WIDTH-1:0] read_data_l1;
//Registers
reg write_enable_l2;


//*******************************************************
//General Purpose Signals
//*******************************************************

//read l1 buffer operation
assign read_address_l1 = l1_reference_addr_in - delay_in;

always @(posedge clk_in or posedge rst_in) begin
   if (rst_in) begin
      write_enable_l2 <= 1'b0;
   end
   else begin
      if (trigger_in)
         write_enable_l2 <= 1'b1;
      else
         write_enable_l2 <= 1'b0;
   end
end

//*******************************************************
//Instantiations
//*******************************************************
fifo
#(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(L2_ADDRESS_WIDTH),
    .FIFO_DEPTH(L2_FIFO_DEPTH)
  )
   l2_buffer_u0  
   (/*autoinst*/
     .clk(clk_in),
     .rst(rst_in),
     .write_data(read_data_l1),
     .write_enable(trigger_in),
     .read_data(read_data_out),
     .read_enable(request_data_in)
   );

circular_fifo
   #(        
      .DATA_WIDTH(DATA_WIDTH),
      .ADDRESS_WIDTH(L1_ADDRESS_WIDTH),
      .FIFO_DEPTH(L1_FIFO_DEPTH)
   ) 
   l1_buffer_u0  
   (/*autoinst*/
      .clk(clk_in),
      .rst(rst_in),
      .write_data(data_in),
      .write_enable(1'b1),
      .read_data(read_data_l1),
      .read_address(read_address_l1),
      .write_pointer(l1_write_pointer_in)
   );
   
endmodule