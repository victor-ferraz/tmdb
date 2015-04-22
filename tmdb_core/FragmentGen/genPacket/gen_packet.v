//==================================================================================================
//  Filename      : gen_packet.v
//  Created On    : 2015-03-16 21:35:47
//  Last Modified : 2015-03-22 22:27:02
//  Revision      : 
//  Author        : Linton Esteves
//  Company       : UFBA
//  Email         : linton.thiago@gmail.com
//
//  Description   : 
//
//
//==================================================================================================
module gen_packet
    #(
        parameter DATA_IN_WIDTH = 32,
        parameter NUM_CHANNEL = 32,
        parameter DATA_OUT_WIDTH = 33,
        parameter BCID_WIDTH = 12,
        //sub-fragment parameters
        parameter NUM_SUB_FRAGMENTS = 3,    
        parameter SUB_FRAGMENT_TYPE_VERSION = {33'd8,33'd9,33'd9}, // 
        parameter SUB_FRAGMENT_OFFSET = {33'd24,33'd8,33'd0}, //accumulator of the previous channels 
        parameter SUB_FRAGMENT_SIZE = {33'd5,33'd25,33'd56}, //total samples of a sub-fragment
        parameter SUB_FRAGMENT_SAMPLES_CH = {33'd1,33'd1,33'd7}, // number of samples in a sub-fragment channel
        parameter SUB_FRAGMENT_NUM_CH = {33'd3,33'd16,33'd8}, //number of channels in a sub-fragment
        parameter NUM_DATA_ELEMTS = 80 //number of data elements in a fragment
    )
    (/*autoport*/
        input clk_in,
        input rst_in,
        input enable,
        //dsp interface
        input [BCID_WIDTH-1:0] bcid_in,
        input [DATA_OUT_WIDTH-2:0] format_version_in,
        input [DATA_OUT_WIDTH-2:0] run_number_in,
        input [DATA_OUT_WIDTH-2:0] source_identifier_in,
        input [DATA_OUT_WIDTH-1:0] lvl_1_id_in,
        //data fifo interface
        input [DATA_IN_WIDTH*NUM_CHANNEL-1:0] fifo_data_1d_in, 
        output [NUM_CHANNEL-1:0] fifo_request_data_out,
        input has_data_to_send_in, 
        //hola interface
        input hola_full_in,
        output reg write_data_out, // request data from HOLA
        output reg [DATA_OUT_WIDTH-1:0] data_out, // send data to HOLA,
        output reg read_done_out
    );
//*******************************************************
//Internal
//*******************************************************
// integer w;
genvar w;
//fsm local parameters
localparam  IDLE = 0,
            SEND_HEADER = 1,
            SEND_DATA_HEADER = 2,
            SEND_DATA = 3,
            SEND_TRAILER = 4;

localparam STATE_WIDTH = 3;
//fragment size configuration
localparam HEADER_SIZE = 10,
           END_SIZE = 4,
           DATA_HEADER_SIZE = 3;

//counters paramters
localparam COUNT_WIDTH = 9;
localparam SFRAG_COUNT_WIDTH = 4;
localparam S_COUNT = 5;

//wires
wire [DATA_OUT_WIDTH-1:0] sub_fragment_size_2d [0:NUM_SUB_FRAGMENTS-1];
wire [DATA_OUT_WIDTH-1:0] sub_fragment_offset_2d [0:NUM_SUB_FRAGMENTS-1];
wire [DATA_OUT_WIDTH-1:0] sub_fragment_type_version_2d [0:NUM_SUB_FRAGMENTS-1];
wire [DATA_OUT_WIDTH-1:0] sub_fragment_samples_2d [0:NUM_SUB_FRAGMENTS-1];
wire [DATA_OUT_WIDTH-1:0] sub_fragment_num_ch_2d [0:NUM_SUB_FRAGMENTS-1];
wire [DATA_OUT_WIDTH-1:0] header [HEADER_SIZE-1:0];
wire [DATA_OUT_WIDTH-1:0] data_header [DATA_HEADER_SIZE-1:0];
wire [DATA_OUT_WIDTH-1:0] trailer [END_SIZE-1:0];
wire [8:0] select_data; // select the actual channel
wire [DATA_IN_WIDTH-1:0] fifo_data_2d [0:NUM_CHANNEL-1];
//Registers
reg [STATE_WIDTH-1:0]   state, 
                        next_state;

reg [COUNT_WIDTH-1:0] data_count;

reg [SFRAG_COUNT_WIDTH-1:0] sub_fragment_count; // identify the current sub-fragment
reg [S_COUNT-1:0] sample_count; // count the number of samples in a channel

//*******************************************************
//create header and trailer
//*******************************************************
assign header[0] = 33'h1B0F00000;   //Beginning Of Fragment - Control Word
assign header[1] = 33'h0EE1234EE;   //Header Marker
assign header[2] = 33'd000000009;   //Header Size
assign header[3] = {1'b0, format_version_in};  //Format Version
assign header[4] = {1'b0, source_identifier_in};   //Source Identifier (from VME Register)
assign header[5] = {1'b0, run_number_in};      //Run Number (from VME Register)
assign header[6] = lvl_1_id_in;        //L1 ID (from TTC or Internal Counter)
assign header[7] = {{DATA_OUT_WIDTH-BCID_WIDTH{1'b0}}, bcid_in}; //BCID (from TTC or Internal Counter)
assign header[8] = 33'd000000000;   //L1 Trigger Type (from TTC, 0)
assign header[9] = 33'd000000000;   //Detector Event Type (no use)

//INIT OF DATA FRAGMENT
assign data_header[0] = 33'h0ff1234ff; //Start of Tilcal sub-fragment marker
assign data_header[1] = sub_fragment_size_2d[sub_fragment_count];  //33'd0; //sub-fragment size 3 + 8xN
assign data_header[2] = sub_fragment_type_version_2d[sub_fragment_count]; //sub-fragment type and version

assign trailer[0] = 33'h000000000;      //Number of Status Elements (0)
assign trailer[1] = NUM_DATA_ELEMTS;    //Number of DATA Elements
assign trailer[2] = 33'h000000000;      //Status Block Position
assign trailer[3] = 33'h1E0F00000;      //End Of Fragment - Control Word

//*******************************************************
//convert 1d input data into 2d
//*******************************************************
genvar i;
generate
    for (i = 0; i < NUM_CHANNEL; i = i + 1) begin:convert_dimension
        assign fifo_data_2d[i] = fifo_data_1d_in[DATA_IN_WIDTH*i+DATA_IN_WIDTH-1:DATA_IN_WIDTH*i];
    end
endgenerate

generate
    for (i = 0; i < NUM_SUB_FRAGMENTS; i = i + 1) begin:convert_dimension2
        assign sub_fragment_size_2d[i] = SUB_FRAGMENT_SIZE[DATA_OUT_WIDTH*i+DATA_OUT_WIDTH-1:DATA_OUT_WIDTH*i];
        assign sub_fragment_offset_2d[i] = SUB_FRAGMENT_OFFSET[DATA_OUT_WIDTH*i+DATA_OUT_WIDTH-1:DATA_OUT_WIDTH*i];
        assign sub_fragment_type_version_2d[i] = SUB_FRAGMENT_TYPE_VERSION[DATA_OUT_WIDTH*i+DATA_OUT_WIDTH-1:DATA_OUT_WIDTH*i];
        assign sub_fragment_samples_2d[i] = SUB_FRAGMENT_SAMPLES_CH[DATA_OUT_WIDTH*i+DATA_OUT_WIDTH-1:DATA_OUT_WIDTH*i];
        assign sub_fragment_num_ch_2d[i] = SUB_FRAGMENT_NUM_CH[DATA_OUT_WIDTH*i+DATA_OUT_WIDTH-1:DATA_OUT_WIDTH*i];
    end
endgenerate

//*******************************************************
//FSM logic
//*******************************************************
always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        state <= IDLE;
    end
    else if (enable) begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    if (!hola_full_in) begin //only works when hola is not full
        case (state)
            IDLE: begin
                if (has_data_to_send_in)
                    next_state = SEND_HEADER;
            end
            SEND_HEADER: begin
                if (data_count == HEADER_SIZE-1)
                    next_state = SEND_DATA_HEADER;
            end
            SEND_DATA_HEADER: begin
                if (data_count == DATA_HEADER_SIZE-1)
                    next_state = SEND_DATA;
            end
            SEND_DATA: begin
                if ((data_count == sub_fragment_num_ch_2d[sub_fragment_count]-1) 
                  && (sample_count == sub_fragment_samples_2d[sub_fragment_count]-1))
                    if (sub_fragment_count == NUM_SUB_FRAGMENTS-1)
                        next_state = SEND_TRAILER;
                    else
                        next_state = SEND_DATA_HEADER;
            end
            SEND_TRAILER: begin
                if (data_count == END_SIZE-1)
                    next_state = IDLE;
            end  
        endcase
    end
end

//*******************************************************
//count data to be send
//*******************************************************
always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        data_count <= {COUNT_WIDTH{1'b0}};
    end
    else if (enable) begin
        case (state)
            IDLE: begin
                data_count <= {COUNT_WIDTH{1'b0}};       
            end
            SEND_HEADER: begin
                if (next_state == SEND_DATA_HEADER)
                    data_count <= {COUNT_WIDTH{1'b0}};
                else
                    data_count <= data_count + 1'b1;
            end
            SEND_DATA_HEADER: begin
                if (next_state == SEND_DATA)
                    data_count <= {COUNT_WIDTH{1'b0}};
                else
                    data_count <= data_count + 1'b1;
            end
            SEND_DATA: begin
                if (next_state == SEND_TRAILER || next_state == SEND_DATA_HEADER 
                  || (data_count == sub_fragment_num_ch_2d[sub_fragment_count]-1))
                    data_count <= {COUNT_WIDTH{1'b0}};
                else
                    data_count <= data_count + 1'b1;
            end
            SEND_TRAILER: begin
                if (next_state == IDLE)
                    data_count <= {COUNT_WIDTH{1'b0}};
                else
                    data_count <= data_count + 1'b1;    
            end  
        endcase
    end
end

//count the sub-fragments
always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        sub_fragment_count <= {COUNT_WIDTH{1'b0}};
    end
    else if (enable) begin
        case (state)
            IDLE: begin
                sub_fragment_count <= {COUNT_WIDTH{1'b0}};       
            end
            SEND_DATA: begin
                if (next_state == SEND_DATA_HEADER)
                    sub_fragment_count <= sub_fragment_count + 1'b1;
            end 
        endcase
    end
end

//*******************************************************
//Outputs
//*******************************************************
//request new data from fifos -- need to be combinational due to timming issues
// generate
//     always @(*) begin // refazer
//         if (state == SEND_DATA) begin
//             for (w = 0; w < (NUM_CHANNEL); w = w + 1) begin
//                fifo_request_data_out[w] = (select_data == w);
//             end
//         end
//         else begin
//             fifo_request_data_out = {NUM_CHANNEL{1'b0}};
//         end
//     end
// endgenerate


generate
    for (w = 0; w < (NUM_CHANNEL); w = w + 1) begin:identifier
        assign fifo_request_data_out[w] = (state == SEND_DATA) ? (select_data == w): 1'b0;
    end
endgenerate

//send data to hola
always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        data_out <= {DATA_OUT_WIDTH{1'b0}};
        write_data_out <= 1'b0;
    end
    else if (enable) begin
        if (!hola_full_in) begin //only works when hola is not full
            case (state)
                IDLE: begin
                    write_data_out <= 1'b0;
                end
                SEND_HEADER: begin
                    write_data_out <= 1'b1;
                    data_out <= header[data_count];
                end
                SEND_DATA_HEADER: begin
                    write_data_out <= 1'b1;
                    data_out <= data_header[data_count];
                end
                SEND_DATA: begin
                    write_data_out <= 1'b1;
                    data_out <= {1'b0, fifo_data_2d[select_data]};
                end
                SEND_TRAILER: begin
                    write_data_out <= 1'b1;
                    data_out <= trailer[data_count];
                end  
            endcase
        end
        else begin
            write_data_out <= 1'b0;        
        end      
    end
end

//identify current sample
always @(posedge clk_in or posedge rst_in) begin
   if (rst_in) begin
      sample_count <= {S_COUNT{1'b0}};
   end
   else if (enable) begin
        if (state == SEND_DATA) begin
            if (data_count == sub_fragment_num_ch_2d[sub_fragment_count]-1)
                sample_count <= sample_count + 1;
        end
        else begin
            sample_count <= {S_COUNT{1'b0}};
        end
    end    
end

assign select_data = data_count+sub_fragment_offset_2d[sub_fragment_count];

//end of a fragment transmition - used by ctrl block
always @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        read_done_out <= 1'b0;
    end
    else if (enable) begin
        if (state == SEND_TRAILER && (data_count == END_SIZE-2))
            read_done_out <= 1'b1;
        else begin
            read_done_out <= 1'b0;
        end
    end
end

endmodule