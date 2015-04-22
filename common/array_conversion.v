genvar pack_i;
//2D to 1D
//Packed Dimension, Unpacked Dimension, Source, Destination		
`define PACK_ARRAY(PK_DIM, UNPK_DIM, SRC, DEST, id) generate for (pack_i=0; pack_i<(UNPK_DIM); pack_i=pack_i+1) begin : id; assign DEST[(PK_DIM*pack_i+PK_DIM-1):(PK_DIM*pack_i)] = SRC[pack_i]; end endgenerate
//1D to 2D
//Packed Dimension, Unpacked Dimension, Source, Destination
`define UNPACK_ARRAY(PK_DIM, UNPK_DIM, SRC, DEST, id) generate for (pack_i=0; pack_i<(UNPK_DIM); pack_i=pack_i+1) begin : id; assign DEST[pack_i] = SRC[(PK_DIM*pack_i+PK_DIM-1):(PK_DIM*pack_i)]; end endgenerate
//`define UNPACK_ARRAY2(PK_DIM, UNPK_DIM, SRC, DEST) genvar unpack2_i; generate for (unpack2_i=0; unpack2_i<(UNPK_DIM); unpack2_i=unpack2_i+1) begin : arrayunpack2; assign DEST[unpack2_i] = SRC[(PK_DIM*unpack2_i+PK_DIM-1):(PK_DIM*unpack2_i)]; end; endgenerate



