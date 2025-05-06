
module crc16(
   input wire i_Clk,
   input wire i_Rst_n,
   input wire start_crc_cal_trig,
   input wire [8:0] bram_data_Len,
   output reg crc_output_ready,
   output reg [15:0] CRC_OUTPUT,
   output reg [8:0] bram_addr,
   output wire bram_we,
   output wire bram_en,
   output wire bram_rst,
   input wire [7:0] BRAM_DOUT
   );

  assign bram_we  = 0;
  assign bram_en  = 1;
  assign bram_rst = 0;
  
  reg [15:0] r_CRC;
  wire [15:0] next_CRC;
  
  reg [7:0] crcInputByte;
  
  localparam CRC_INIT_VAL = 16'hFFFF;
  
  // CRC Control logic
   assign next_CRC[0] = crcInputByte[4] ^ crcInputByte[0] ^ r_CRC[8] ^ r_CRC[12];
   assign next_CRC[1] = crcInputByte[5] ^ crcInputByte[1] ^ r_CRC[9] ^ r_CRC[13];
   assign next_CRC[2] = crcInputByte[6] ^ crcInputByte[2] ^ r_CRC[10] ^ r_CRC[14];
   assign next_CRC[3] = crcInputByte[7] ^ crcInputByte[3] ^ r_CRC[11] ^ r_CRC[15];
   assign next_CRC[4] = crcInputByte[4] ^ r_CRC[12];
   assign next_CRC[5] = crcInputByte[5] ^ crcInputByte[4] ^ crcInputByte[0] ^ r_CRC[8] ^ r_CRC[12] ^ r_CRC[13];
   assign next_CRC[6] = crcInputByte[6] ^ crcInputByte[5] ^ crcInputByte[1] ^ r_CRC[9] ^ r_CRC[13] ^ r_CRC[14];
   assign next_CRC[7] = crcInputByte[7] ^ crcInputByte[6] ^ crcInputByte[2] ^ r_CRC[10] ^ r_CRC[14] ^ r_CRC[15];
   assign next_CRC[8] = crcInputByte[7] ^ crcInputByte[3] ^ r_CRC[0] ^ r_CRC[11] ^ r_CRC[15];
   assign next_CRC[9] = crcInputByte[4] ^ r_CRC[1] ^ r_CRC[12];
   assign next_CRC[10] = crcInputByte[5] ^ r_CRC[2] ^ r_CRC[13];
   assign next_CRC[11] = crcInputByte[6] ^ r_CRC[3] ^ r_CRC[14];
   assign next_CRC[12] = crcInputByte[7] ^ crcInputByte[4] ^ crcInputByte[0] ^ r_CRC[4] ^ r_CRC[8] ^ r_CRC[12] ^ r_CRC[15];
   assign next_CRC[13] = crcInputByte[5] ^ crcInputByte[1] ^ r_CRC[5] ^ r_CRC[9] ^ r_CRC[13];
   assign next_CRC[14] = crcInputByte[6] ^ crcInputByte[2] ^ r_CRC[6] ^ r_CRC[10] ^ r_CRC[14];
   assign next_CRC[15] = crcInputByte[7] ^ crcInputByte[3] ^ r_CRC[7] ^ r_CRC[11] ^ r_CRC[15];

  
  
  
  localparam CRC_CALC_IDLE              =   0;
  localparam CRC_CALC_INIT              =   1;
  localparam CRC_CALC_BRAM_LATENCY      =   2;
  localparam CRC_CALC_PROC              =   3;
  localparam CRC_CALC_DONE              =   4;
  
  reg [3:0] CRC_CALC_stage  =   CRC_CALC_IDLE;
  
  reg [3:0] stage_changer;
  reg [9:0] gen_timer;
  
  always @ (posedge i_Clk or negedge i_Rst_n) begin
      if (~i_Rst_n) begin
          r_CRC <= CRC_INIT_VAL;
          crcInputByte <= 0;
          crc_output_ready <= 0;
          stage_changer <= 0;
          gen_timer <= 0;
          CRC_CALC_stage <= CRC_CALC_IDLE;
      end else begin
          case(CRC_CALC_stage)
              CRC_CALC_IDLE: begin
                  if(start_crc_cal_trig) begin
                      CRC_CALC_stage <= CRC_CALC_INIT;
                      crc_output_ready <= 0;
                  end
              end
              CRC_CALC_INIT: begin
                  r_CRC <= CRC_INIT_VAL;
                  crcInputByte <= 0;
                  CRC_CALC_stage <= CRC_CALC_BRAM_LATENCY;
              end
              CRC_CALC_BRAM_LATENCY: begin
                  if(stage_changer==0) begin
                      stage_changer <= 1;
                      bram_addr <= 0;
                  end else if(stage_changer==1) begin
                      stage_changer <= 2;
                      bram_addr <= 1;
                  end else if(stage_changer==2) begin
                      stage_changer <= 0;
                      bram_addr <= 2;
                      CRC_CALC_stage <= CRC_CALC_PROC;
                  end
              end
              CRC_CALC_PROC: begin
                  if(gen_timer==bram_data_Len-1) begin
                      CRC_CALC_stage <= CRC_CALC_DONE;
                      gen_timer <= 0;
                  end
                  if(gen_timer!=0) begin
                      r_CRC <= next_CRC;
                  end
//                  crcInputByte <= gen_timer;
                   crcInputByte <= BRAM_DOUT;
                  bram_addr <= bram_addr + 1;
                  gen_timer <= gen_timer + 1;
              end
              CRC_CALC_DONE: begin
                  CRC_CALC_stage <= CRC_CALC_IDLE;
                  CRC_OUTPUT <= next_CRC;
                  crc_output_ready <= 1;
              end
              default: begin
                  CRC_CALC_stage <= CRC_CALC_IDLE;
                  stage_changer <= 0;
                  CRC_OUTPUT <= 0;
                  crc_output_ready <= 0;
              end
          endcase
      
      end
  end
  
//  blk_mem_gen_0 myBram(
//        .addra (bram_addr),
//        .clka  (i_Clk),
//        .douta (BRAM_DOUT),
//        .ena   (1),
//        .wea   (0),
//        .rsta  (0)
//        );
  
  
  
endmodule
