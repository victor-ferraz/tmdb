//==================================================================================================
//  Filename      : packet_control_top.v
//  Created On    : 2015-02-09 21:28:30
//  Last Modified : 2015-03-28 09:46:20
//  Revision      : 
//  Author        : Linton Esteves
//  Company       : UFBA
//  Email         : linton.thiago@gmail.com
//
//  Description   : 
//
//
//==================================================================================================
module packet_control_top
    #(
        //data paramiters
        parameter DATA_OUT_WIDTH = 33,
        parameter DATA_ADC_WIDTH = 8,
        parameter DATA_IN_WIDTH = 32,
        parameter BCID_WIDTH = 12,
        parameter DELAY_WIDTH = 4,
        //channels paramter
        parameter NUM_ADC_CHANNEL = 32,
        parameter NUM_CHANNEL = NUM_ADC_CHANNEL + 19,
        //ctrl parameters
        parameter CTRL_FIFO_ADDR_WIDTH = 3,
        parameter CTRL_FIFO_SIZE = 8,
        parameter L2_PROC_TIME = 7,
        //pkt ctrl parameters
        parameter NUM_ADC_SAMPLES = 7,
        parameter L1_ADDRESS_WIDTH = 7,
        parameter L2_ADDRESS_WIDTH = 7,
        parameter L2_FIFO_DEPTH = 2**L2_ADDRESS_WIDTH,
        parameter L2_FIFO_CAP = L2_FIFO_DEPTH/NUM_ADC_SAMPLES,
        parameter L1_FIFO_DEPTH = 2**L1_ADDRESS_WIDTH
    )
    (/*autoport*/

        input clk,
        input rst, // reset active high,
        input enable,
        input [DATA_ADC_WIDTH*NUM_ADC_CHANNEL-1:0] data_1d_adc_in,
        input [DATA_IN_WIDTH*(NUM_CHANNEL-NUM_ADC_CHANNEL)-1:0] data_1d_in,
        input [DELAY_WIDTH*NUM_CHANNEL-1:0] delay_1d_in, //channel delay value
        
        input l1a, // trigger signal
        input [BCID_WIDTH-1:0] BCnt,
        input BCntStr,
        input EvCntLStr,
        input EvCntHStr,
        input bCntRes,        // BCID Reset
        input evCntRes,       // Event Counter Reset
        output busyOut, //to dsp - internal memory full
       
        input [DATA_IN_WIDTH-1:0] sourceIdentifier,
        input [DATA_IN_WIDTH-1:0] runNumber,
        input [DATA_IN_WIDTH-1:0] formatVersion,
       
        // HOLA interface ---------------------------------------------------------
        input holaReset,      
        output [DATA_IN_WIDTH-1:0] UD,
        output URESET_N,
        output UCTRL_N, 
        output UWEN_N, 
        input LFF_N,        
        input LDOWN_N 

    );
//*******************************************************
//Internal
//*******************************************************
genvar i;

localparam GEN_DATA_IN_WIDTH = 32;
//=27
localparam GEN_NUM_CHANNEL = NUM_ADC_CHANNEL/4 + NUM_CHANNEL - NUM_ADC_CHANNEL;
localparam NUM_REMAIN_CH = NUM_CHANNEL - NUM_ADC_CHANNEL;
//Wires
wire intern_enable;
wire hola_write_enable; // request data from HOLA
wire [DATA_OUT_WIDTH-1:0] hola_data; // send data to HOLA
wire hola_fifo_full;
wire [DELAY_WIDTH-1:0] delay_2d [0:NUM_CHANNEL-1];
wire [DATA_ADC_WIDTH-1:0] data_2d_adc [0:NUM_ADC_CHANNEL-1];
wire [DATA_IN_WIDTH-1:0] data_2d [0:NUM_REMAIN_CH-1];

wire [GEN_NUM_CHANNEL*GEN_DATA_IN_WIDTH-1:0] fifo_read_data_1d;
wire [DATA_ADC_WIDTH-1:0] fifo_read_data_adc_2d [0:NUM_ADC_CHANNEL-1];
wire [DATA_IN_WIDTH-1:0] fifo_read_data_2d [0:NUM_REMAIN_CH-1];
wire [GEN_NUM_CHANNEL-1:0] fifo_request_data;
wire [BCID_WIDTH-1:0] current_bcid;
wire store_data;
wire read_done;
wire [L1_ADDRESS_WIDTH-1:0] l1_write_pointer;
wire [L1_ADDRESS_WIDTH-1:0] l1_reference_addr;

wire [2*BCID_WIDTH-1:0] current_l1_id;
//*******************************************************
// convert signals
//*******************************************************
//delay of the channels
generate
    for (i = 0; i < NUM_CHANNEL; i = i + 1) begin:convert_dimension_0
        assign delay_2d[i] = delay_1d_in[DELAY_WIDTH*i+DELAY_WIDTH-1:DELAY_WIDTH*i];
    end
endgenerate

//delay of the adc channels
generate
    for (i = 0; i < NUM_ADC_CHANNEL; i = i + 1) begin:convert_dimension_1
        assign data_2d_adc[i] = data_1d_adc_in[DATA_ADC_WIDTH*i+DATA_ADC_WIDTH-1:DATA_ADC_WIDTH*i];
    end
endgenerate

generate
    for (i = 0; i < NUM_REMAIN_CH ; i = i + 1) begin:convert_dimension_2
        assign data_2d[i] = data_1d_in[DATA_IN_WIDTH*i+DATA_IN_WIDTH-1:DATA_IN_WIDTH*i];
    end
endgenerate

//read adc data
generate
    for (i = 0; i < NUM_ADC_CHANNEL/4; i = i + 1) begin:convert_dimension_3
        assign fifo_read_data_1d[GEN_DATA_IN_WIDTH*i+GEN_DATA_IN_WIDTH-1:GEN_DATA_IN_WIDTH*i] = {fifo_read_data_adc_2d[i*4+3],fifo_read_data_adc_2d[i*4+2],fifo_read_data_adc_2d[i*4+1],fifo_read_data_adc_2d[i*4]};
    end
endgenerate

//read other channels
generate
    for (i = NUM_ADC_CHANNEL/4; i < GEN_NUM_CHANNEL; i = i + 1) begin:convert_dimension_4
        assign fifo_read_data_1d[GEN_DATA_IN_WIDTH*i+GEN_DATA_IN_WIDTH-1:GEN_DATA_IN_WIDTH*i] = fifo_read_data_2d[i-(NUM_ADC_CHANNEL/4)];
    end
endgenerate



//*******************************************************
//Instantiations
//*******************************************************
generate
    for (i = 0; i < NUM_ADC_CHANNEL; i = i + 1) begin:gen_pkt_adc
        packet_control_adc
        #(
           .DATA_WIDTH(DATA_ADC_WIDTH),
           .NUM_SAMPLES(NUM_ADC_SAMPLES),
           .DELAY_WIDTH(DELAY_WIDTH),
           .L1_FIFO_DEPTH(L1_FIFO_DEPTH),
           .L2_FIFO_DEPTH(L2_FIFO_DEPTH),
           .L2_ADDRESS_WIDTH(L2_ADDRESS_WIDTH),
           .L1_ADDRESS_WIDTH(L1_ADDRESS_WIDTH)
        )
        packet_control_adc_u0  
        (/*autoinst*/
             .clk_in(clk),
             .rst_in(rst),
             .trigger_in(store_data),
             .data_in(data_2d_adc[i]),
             .delay_in(delay_2d[i]),
             .read_data_out(fifo_read_data_adc_2d[i]),
             .request_data_in(fifo_request_data[i/4]),
             .l1_write_pointer_in(l1_write_pointer),
             .l1_reference_addr_in(l1_reference_addr)
        );
    end
endgenerate

generate
    for (i = NUM_ADC_CHANNEL; i < NUM_CHANNEL; i = i + 1) begin:gen_pkt_data
        packet_control
        #(
           .DATA_WIDTH(DATA_IN_WIDTH),
           .DELAY_WIDTH(DELAY_WIDTH),
           .L1_FIFO_DEPTH(L1_FIFO_DEPTH),
           .L2_FIFO_DEPTH(L2_FIFO_DEPTH),
           .L2_ADDRESS_WIDTH(L2_ADDRESS_WIDTH),
           .L1_ADDRESS_WIDTH(L1_ADDRESS_WIDTH)
        ) 
        packet_control_u0  
        (/*autoinst*/
             .clk_in(clk),
             .rst_in(rst),
             .trigger_in(store_data),
             .data_in(data_2d[i-NUM_ADC_CHANNEL]),
             .delay_in(delay_2d[i]),
             .read_data_out(fifo_read_data_2d[i-NUM_ADC_CHANNEL]),
             .request_data_in(fifo_request_data[NUM_ADC_CHANNEL/4 + i-NUM_ADC_CHANNEL]),
             .l1_write_pointer_in(l1_write_pointer),
             .l1_reference_addr_in(l1_reference_addr)
        );
    end
endgenerate

gen_packet
    #(
        .DATA_IN_WIDTH(GEN_DATA_IN_WIDTH),
        .NUM_CHANNEL(GEN_NUM_CHANNEL),
        .DATA_OUT_WIDTH(DATA_OUT_WIDTH),
        .BCID_WIDTH(BCID_WIDTH)
    ) 
    gen_packet_u0  
    (/*autoinst*/
        .enable(intern_enable),
        .fifo_request_data_out(fifo_request_data),
        .write_data_out(hola_write_enable),
        .data_out(hola_data),
        .clk_in(clk),
        .bcid_in(current_bcid),
        .lvl_1_id_in({{9{1'b0}},current_l1_id}),
        .rst_in(rst),
        .has_data_to_send_in(has_data),
        .fifo_data_1d_in(fifo_read_data_1d),
        .hola_full_in(hola_fifo_full),
        .read_done_out(read_done),
        .source_identifier_in(sourceIdentifier),
        .format_version_in(formatVersion),
        .run_number_in(runNumber)
    ); 


ctrl 
    #(
        .BCID_WIDTH(BCID_WIDTH),
        .ADDRESS_WIDTH(CTRL_FIFO_ADDR_WIDTH),
        .FIFO_SIZE(CTRL_FIFO_SIZE),
        .L2_PROC_TIME(L2_PROC_TIME),
        .L1_ADDRESS_WIDTH(L1_ADDRESS_WIDTH),
        .L2_FIFO_CAP(L2_FIFO_CAP)
    )
    ctrl_u0
    (/*autoport*/
        .enable(intern_enable),
        .clk_in(clk),
        .rst_in(rst),
        //.bcid_in(bcid_in),
        .trigger_in(l1a),
        .store_data_out(store_data),
        .bcid_out(current_bcid),
        .full_flag_out(busyOut),
        .has_data_out(has_data),
        .read_done_in(read_done),
        .l1_id_out({current_l1_id}),
        .l1_write_pointer_out(l1_write_pointer),
        .l1_reference_addr_out(l1_reference_addr),
        .BCnt(BCnt),
        .BCntStr(BCntStr),
        .EvCntLStr(EvCntLStr),
        .EvCntHStr(EvCntHStr),
        .bCntRes(bCntRes),
        .evCntRes(evCntRes)
    );

holaReset 
    holaReset_u0    
    (
        .rst(rst),
        .clk(clk),
        .enable(enable),
        
        .holaReset(holaReset),  //HOLA Reset Request from VME
        .normalOper(holaNormalOper), //Normal Operation Signal
        
        .LDOWN_N(LDOWN_N),     
        .URESET_N(URESET_N)
    );

assign intern_enable = enable && holaNormalOper;
assign hola_fifo_full = ~LFF_N;
assign UD           = hola_data[31:0];
assign UCTRL_N      = ~hola_data[32];
assign UWEN_N       = ~hola_write_enable;

endmodule