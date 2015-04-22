//==================================================================================================
//  Filename      : ctrl.v
//  Created On    : 2015-02-09 21:28:30
//  Last Modified : 2015-03-28 09:45:40
//  Revision      : 
//  Author        : Linton Esteves
//  Company       : UFBA
//  Email         : linton.thiago@gmail.com
//
//  Description   : 
//
//
//==================================================================================================
module ctrl
		#(
			parameter BCID_WIDTH = 12,
			parameter ADDRESS_WIDTH = 3,
			parameter FIFO_SIZE = 2**ADDRESS_WIDTH,
			parameter L1_ADDRESS_WIDTH = 7, //pkt control l1 address width
			parameter L2_FIFO_CAP = 3, //pkt control l2 fifo size
            parameter L2_PROC_TIME = 7 //time to store l1 data into l2 fifo
                
		)
		(/*autoport*/
			input clk_in,
			input rst_in,
            input [BCID_WIDTH-1:0] BCnt,
            input BCntStr,
            input EvCntLStr,
            input EvCntHStr,
			input enable,
			input trigger_in,
			input read_done_in,
			output reg store_data_out, // store l1 fifo data into l2 fifo
            output full_flag_out,
            output has_data_out,
            output [BCID_WIDTH-1:0] bcid_out,
            output [2*BCID_WIDTH-1:0] l1_id_out,
            output reg [L1_ADDRESS_WIDTH-1:0] l1_write_pointer_out,
            output reg [L1_ADDRESS_WIDTH-1:0] l1_reference_addr_out,
            input bCntRes,        // BCID Reset
            input evCntRes       // Event Counter Reset
        );
//*******************************************************
//Internal
//*******************************************************
//Local Parameters
localparam COUNT_WIDTH = 8;
//Wires
wire [3*BCID_WIDTH-1:0] bcid_fifo_read_data, 
                        bcid_fifo_write_data;
wire [L1_ADDRESS_WIDTH-1:0] wp_fifo_read_data;

wire bcif_fifo_empty, 
     wp_fifo_empty;

wire wp_fifo_full, 
     bcid_fifo_full;

//Registers
reg fifo_write_enable;
reg [COUNT_WIDTH-1:0] count;
reg [COUNT_WIDTH-1:0] l2_count;

reg [BCID_WIDTH-1:0] bcid;
reg [BCID_WIDTH-1:0] l1_id_low;
reg [BCID_WIDTH-1:0] l1_id_high;
reg trigger_received, 
    bcid_fifo_wr_en;

//*******************************************************
//General Purpose Signals
//*******************************************************
assign bcid_out = bcid_fifo_read_data[3*BCID_WIDTH-1:2*BCID_WIDTH];
assign l1_id_out = bcid_fifo_read_data[2*BCID_WIDTH-1:0];
assign bcid_fifo_write_data = {bcid, l1_id_high, l1_id_low};

always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        trigger_received <= 0;
    end
    else if(enable) begin
        if (trigger_in) begin
            trigger_received <= 1;
        end
        else if (EvCntHStr) begin
            trigger_received <= 0;
        end
    end
end

always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        bcid_fifo_wr_en <= 0;
    end
    else if(enable) begin
        if (EvCntHStr) begin
            bcid_fifo_wr_en <= 1;
        end
        else begin
            bcid_fifo_wr_en <= 0;
        end
    end
end

//detect bcid
always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        bcid <= {BCID_WIDTH{1'b0}};
        l1_id_low <= {BCID_WIDTH{1'b0}};
        l1_id_high <= {BCID_WIDTH{1'b0}};
    end
    else begin
        if (trigger_received || trigger_in) begin
            if(BCntStr)
                bcid <= BCnt;
            if (EvCntLStr)
                l1_id_low <= BCnt;
            if (EvCntHStr)
                l1_id_high<= BCnt;
        end
    end
end

//avoid bcid fifo overflow
always @(*) begin
	if (bcid_fifo_wr_en && !bcid_fifo_full)
		fifo_write_enable = 1;
	else begin
		fifo_write_enable = 0;
	end
end

//wait the l2 fifo load l1 data
always @(posedge clk_in or posedge rst_in) begin
	if (rst_in) begin
        count <= L2_PROC_TIME;
    end
    else begin
        if (store_data_out)
            count <= {COUNT_WIDTH{1'b0}};
        else if (count < L2_PROC_TIME)
            count <= count +1'b1;
	end
end

//prevent l2 fifo overflow
always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        l2_count <= {ADDRESS_WIDTH{1'b0}};
    end
    else if(enable) begin
        if (store_data_out && !read_done_in) begin
            l2_count <= l2_count + 1;
        end
        else if (read_done_in && !store_data_out) begin
        	l2_count <= l2_count + -1;
        end

    end
end

assign enable_store_data = !wp_fifo_empty && (l2_count < L2_FIFO_CAP-1) && (count == L2_PROC_TIME) && enable;

//*******************************************************
//Outputs
//*******************************************************
always @(posedge clk_in or posedge rst_in) begin
	if (rst_in) begin
		store_data_out <= 0;
		l1_reference_addr_out <= 0;
	end
	else if(enable) begin
		if (enable_store_data) begin
			l1_reference_addr_out <= wp_fifo_read_data;
			store_data_out <= 1'b1;
		end
		else begin
			store_data_out <= 1'b0;
		end
	end
end

assign full_flag_out = bcid_fifo_full || wp_fifo_full;
assign has_data_out = l2_count > 0;

//l1 circular fifo write address
always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        l1_write_pointer_out <= {ADDRESS_WIDTH{1'b0}};
    end
    else begin
        if (enable) begin
            l1_write_pointer_out <= l1_write_pointer_out + 1'b1;
        end
    end
end
//*******************************************************
//Instantiations
//*******************************************************
//store the current write pointer
fifo_flags
#(
    .DATA_WIDTH(L1_ADDRESS_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .FIFO_DEPTH(FIFO_SIZE)
  )
   write_pointer_buffer_u0  
   (/*autoinst*/
     .clk(clk_in),
     .rst(rst_in),
     .empty_flag(wp_fifo_empty),
     .write_data(l1_write_pointer_out),
     .write_enable(fifo_write_enable),
     .read_data(wp_fifo_read_data),
     .read_enable(store_data_out),
     .full_flag(wp_fifo_full)
   );

//store the bcid value until the next read operation
fifo_flags
#(
    .DATA_WIDTH(3*BCID_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .FIFO_DEPTH(FIFO_SIZE)
  )
   bcid_buffer_u0  
   (/*autoinst*/
     .clk(clk_in),
     .rst(rst_in),
     .empty_flag(bcif_fifo_empty),
     .write_data(bcid_fifo_write_data),
     .write_enable(fifo_write_enable),
     .read_data(bcid_fifo_read_data),
     .read_enable(read_done_in),
     .full_flag(bcid_fifo_full)
   );

endmodule