`default_nettype none

// top module 
module top
  (
   input  wire       clk,
   input  wire [1:0] sw,
   input  wire [3:0] btn,
   input  wire [1:0] mipi_phy_if_data_hs_n,
   input  wire [1:0] mipi_phy_if_data_hs_p,
   input  wire       mipi_phy_if_clk_hs_n,
   input  wire       mipi_phy_if_clk_hs_p,
   output wire [5:0] led_out,
   output wire       pulse1,
   output wire       pulse2,
   output wire       CAM_PWUP,
   inout  wire       CAM_SCL,
   inout  wire       CAM_SDA
   );

   localparam integer CLOCK_FREQ = 125 * 10 ** 6; // system clock of 125 MHz
   localparam integer SCL_FREQ = 200 * 10 ** 3; // SCCB clock of 200 kHz
   localparam integer IMG_WIDTH = 640, IMG_HEIGHT = 480, DATA_WIDTH = 8;
   localparam integer PIXELS = IMG_WIDTH * IMG_HEIGHT;
   
   wire               n_rst;
   wire [DATA_WIDTH - 1:0] r_data;
   wire                    w_busy;
   wire                    w_req;
   wire [$clog2(PIXELS) - 1:0] r_addr;
   wire                        camsel;
   wire sccb_req;
   wire sccb_wr;
   wire [31:0] sccb_wdata;
   wire [7:0]  sccb_rdata;
   wire sccb_busy;

   // debug 
   wire                        ila_clk; // 5MHz
   clk_wiz_0 clk_wiz_inst0
      (
       .reset(btn[0]),
       .locked(n_rst),
       .clk_in1(clk),
       .clk_out1(ila_clk)
       );

   //assign n_rst = !btn[0];

   // ps-pl communication
   design_1 design_1_inst
     (
      // inputs (PL -> PS)
      .sw(sw),
      .r_data(r_data),
      .w_busy(w_busy),
      .sccb_rdata(sccb_rdata),
      .sccb_busy(sccb_busy),
      // outputs (PS -> PL)
      .led_out(led_out[3:0]),
      .pulse1(pulse1),
      .pulse2(pulse2),
      .w_req(w_req),
      .r_addr(r_addr),
      .camsel(camsel),
      .sccb_req(sccb_req),
      .sccb_wr(sccb_wr),
      .sccb_wdata(sccb_wdata)
      );

   // CAM_PW
   localparam integer          PW_CNT_MAX = (100 * 10 ** 6) / 200;

   reg [$clog2(PW_CNT_MAX):0]  pw_cnt;                        
   always @(posedge ila_clk) begin
      if (!n_rst) begin
         pw_cnt <= 'd0;
      end else begin
         if (pw_cnt == PW_CNT_MAX - 1)
           pw_cnt <= 'd0;
         else
           pw_cnt <= pw_cnt + 1'b1;
      end
   end

   reg CAM_PWUP_reg;
   always @(posedge ila_clk) begin
      if (!n_rst) begin
         CAM_PWUP_reg <= 1'b0;
      end else if (pw_cnt == PW_CNT_MAX - 1) begin
         CAM_PWUP_reg <= 1'b1;
      end
   end
   assign CAM_PWUP = CAM_PWUP_reg;
   
   // SCCB interface
   sccb_if 
     #(
       .CLOCK_FREQ(CLOCK_FREQ),
       .SCL_FREQ(SCL_FREQ)
       )
   sccb_if_inst
     (
      .sysclk(clk),
      .n_rst(n_rst),
      .req(sccb_req),
      .wr(sccb_wr),
      .wdata(sccb_wdata),
      .rdata(sccb_rdata),
      .busy(sccb_busy),
      .scl(CAM_SCL),
      .sda(CAM_SDA)
      );
   
   // 2 cameras 
   // wire [$clog2(IMG_WIDTH) - 1:0] hcount, hcount0, hcount1;
   // wire [$clog2(IMG_HEIGHT) - 1:0] vcount, vcount0, vcount1;
   // wire [DATA_WIDTH - 1:0]         camout, camout0, camout1;
   
   // cam
   //   #(
   //     .IMG_WIDTH(IMG_WIDTH),
   //     .IMG_HEIGHT(IMG_HEIGHT),
   //     .DATA_WIDTH(DATA_WIDTH),
   //     .OPTION(0)
   //     )
   // cam_inst0
   //   (
   //    .clk(clk),
   //    .n_rst(n_rst),
   //    .hcount(hcount0),
   //    .vcount(vcount0),
   //    .dout(camout0)
   //    );

   // cam
   //   #(
   //     .IMG_WIDTH(IMG_WIDTH),
   //     .IMG_HEIGHT(IMG_HEIGHT),
   //     .DATA_WIDTH(DATA_WIDTH),
   //     .OPTION(1)
   //     )
   // cam_inst1
   //   (
   //    .clk(clk),
   //    .n_rst(n_rst),
   //    .hcount(hcount1),
   //    .vcount(vcount1),
   //    .dout(camout1)
   //    );

   // assign hcount = (camsel == 0)? hcount0: hcount1;
   // assign vcount = (camsel == 0)? vcount0: vcount1;
   // assign camout = (camsel == 0)? camout0: camout1;

   // // image memory
   // img_mem
   //   #(
   //     .IMG_WIDTH(IMG_WIDTH),
   //     .IMG_HEIGHT(IMG_HEIGHT),
   //     .DATA_WIDTH(DATA_WIDTH)
   //     )
   // img_mem_inst
   //   (
   //    .clk(clk),
   //    .n_rst(n_rst),
   //    .w_req(w_req),
   //    .hcount(hcount),
   //    .vcount(vcount),
   //    .r_addr(r_addr),
   //    .din(camout),
   //    .w_busy(w_busy),
   //    .dout(r_data)
   //    );

   assign led_out[5:4] = sw;
   
endmodule

`default_nettype wire
