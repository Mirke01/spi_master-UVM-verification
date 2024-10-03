`include "spi_defines.v"
`include "spi_timescale.v"
`include "spi_errors.v"

module spi
(
  // Wishbone signals
  wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i, wb_dat_o, wb_sel_i,
  wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_err_o, wb_int_o,

  // SPI signals
  ss_pad_o, sclk_pad_o, mosi_pad_o, miso_pad_i
);

  parameter Tp = 1;

  // Wishbone signals
  input                            wb_clk_i;         // master clock input
  input                            wb_rst_i;         // synchronous active high reset
  input                      [4:0] wb_adr_i;         // lower address bits
  input                   [32-1:0] wb_dat_i;         // databus input
  output                  [32-1:0] wb_dat_o;         // databus output
  input                      [3:0] wb_sel_i;         // byte select inputs
  input                            wb_we_i;          // write enable input
  input                            wb_stb_i;         // stobe/core select signal
  input                            wb_cyc_i;         // valid bus cycle input
  output                           wb_ack_o;         // bus cycle acknowledge output
  output                           wb_err_o;         // termination w/ error
  output                           wb_int_o;         // interrupt request signal output
                                                     
  // SPI signals                                     
  output          [`SPI_SS_NB-1:0] ss_pad_o;         // slave select
  output                           sclk_pad_o;       // serial clock
  output                           mosi_pad_o;       // master out slave in
  input                            miso_pad_i;       // master in slave out
                                                     
  reg                     [32-1:0] wb_dat_o;
  reg                              wb_ack_o;
  reg                              wb_int_o;
                                               
  // Internal signals
  reg       [`SPI_DIVIDER_LEN-1:0] divider;          // Divider register
  reg       [`SPI_CTRL_BIT_NB-1:0] ctrl;             // Control and status register
  reg             [`SPI_SS_NB-1:0] ss;               // Slave select register
  reg                     [32-1:0] wb_dat;           // wb data out
  wire         [`SPI_MAX_CHAR-1:0] rx;               // Rx register
  wire                             rx_negedge;       // miso is sampled on negative edge
  wire                             tx_negedge;       // mosi is driven on negative edge
  wire    [`SPI_CHAR_LEN_BITS-1:0] char_len;         // char len
  wire                             go;               // go
  wire                             lsb;              // lsb first on line
  wire                             ie;               // interrupt enable
  wire                             ass;              // automatic slave select
  wire                             spi_divider_sel;  // divider register select
  wire                             spi_ctrl_sel;     // ctrl register select
  wire                       [3:0] spi_tx_sel;       // tx_l register select
  wire                             spi_ss_sel;       // ss register select
  wire                             wrong_addr_sel;   // wrong/unallocated WB  address
  wire                             tip;              // transfer in progress
  wire                             pos_edge;         // recognize posedge of sclk
  wire                             neg_edge;         // recognize negedge of sclk
  wire                             last_bit;         // marks last character bit
  

//(T.D.)
  reg 	[4:0]	wb_adr_is;
  reg	[3:0]	wb_sel_is;
  reg		wb_we_is;
  reg		wb_stb_is;
  reg		wb_cyc_is;
  reg		wb_rst_is;
  reg		wb_clk_is;
  reg	[7:0]   wb_ack_pulse;
  reg	[4:0]	sclk_8_bit;
  wire		sclk_pad_os;
  reg		sclk_pad_o;
  wire		mosi_pad_os;
  reg		mosi_pad_o;
  reg 	[1:0]	mosi_pad_o_delayed;

  reg 	[31:0]  rand_reg;
  
  `ifdef WRITE_AFTER_GOBSY_ERR
  `else
  reg           go_d1;
  `endif


  always @(wb_adr_i)
    `ifdef WB_ADDR_ERR
        wb_adr_is = {wb_adr_i[4], ~wb_adr_i[3], wb_adr_i[2:0]};
    `else
        wb_adr_is = wb_adr_i;
    `endif

 always @(wb_sel_i)
    `ifdef WB_SEL_ERR
        wb_sel_is = {wb_sel_i[3], ~wb_sel_i[2], wb_sel_i[1:0]};
    `else
        wb_sel_is = wb_sel_i;
    `endif

 always @(wb_we_i)
 begin
    `ifdef WB_WE_ERR
       rand_reg = $random;
       wb_we_is = rand_reg[0];
    `else
       wb_we_is = wb_we_i;
    `endif
 end

 always @(wb_stb_i)
 begin
    `ifdef WB_STB_ERR
       rand_reg = $random;
       wb_stb_is = rand_reg[1];
    `else
       wb_stb_is = wb_stb_i;
    `endif
 end

 always @(wb_cyc_i)
 begin
    `ifdef WB_CYC_ERR
       rand_reg = $random;
       wb_cyc_is = rand_reg[2];
    `else
       wb_cyc_is = wb_cyc_i;
    `endif
 end

 always @(wb_rst_i or wb_cyc_i)
 begin
    `ifdef WB_RST_DISABLE_ERR
        wb_rst_is = 1'b0;
    `else
       `ifdef WB_RST_RAND_ERR
           rand_reg = $random;
           wb_rst_is = rand_reg[3];
       `else
           wb_rst_is = wb_rst_i;
       `endif
    `endif
 end

 initial
   wb_clk_is = 1'b1;

 always @(wb_clk_i)
 begin
    `ifdef WB_CLK_ERR
       if (wb_clk_i)
          wb_clk_is = ~wb_clk_is;
    `else
       wb_clk_is = wb_clk_i;
    `endif
 end

  // Address decoder
  assign spi_divider_sel = wb_cyc_is & wb_stb_is & (wb_adr_is[`SPI_OFS_BITS] == `SPI_DEVIDE);
  assign spi_ctrl_sel    = wb_cyc_is & wb_stb_is & (wb_adr_is[`SPI_OFS_BITS] == `SPI_CTRL);
  assign spi_tx_sel[0]   = wb_cyc_is & wb_stb_is & (wb_adr_is[`SPI_OFS_BITS] == `SPI_TX_0);
  assign spi_tx_sel[1]   = wb_cyc_is & wb_stb_is & (wb_adr_is[`SPI_OFS_BITS] == `SPI_TX_1);
  assign spi_tx_sel[2]   = wb_cyc_is & wb_stb_is & (wb_adr_is[`SPI_OFS_BITS] == `SPI_TX_2);
  assign spi_tx_sel[3]   = wb_cyc_is & wb_stb_is & (wb_adr_is[`SPI_OFS_BITS] == `SPI_TX_3);
  assign spi_ss_sel      = wb_cyc_is & wb_stb_is & (wb_adr_is[`SPI_OFS_BITS] == `SPI_SS);
  assign wrong_addr_sel  = wb_cyc_is & wb_stb_is & (wb_adr_is[`SPI_OFS_BITS] != `SPI_DEVIDE)&
		                                           (wb_adr_is[`SPI_OFS_BITS] != `SPI_CTRL  )&
		                                           (wb_adr_is[`SPI_OFS_BITS] != `SPI_TX_0  )&
		                                           (wb_adr_is[`SPI_OFS_BITS] != `SPI_TX_1  )&
		                                           (wb_adr_is[`SPI_OFS_BITS] != `SPI_TX_2  )&
		                                           (wb_adr_is[`SPI_OFS_BITS] != `SPI_TX_3  )&
		                                           (wb_adr_is[`SPI_OFS_BITS] != `SPI_SS    );
		  
		  
  // Read from registers
  always @(wb_adr_is or rx or ctrl or divider or ss)
  begin
    case (wb_adr_is[`SPI_OFS_BITS])
`ifdef SPI_MAX_CHAR_128
      `SPI_RX_0:    wb_dat = rx[31:0];
      `SPI_RX_1:    wb_dat = rx[63:32];
      `SPI_RX_2:    wb_dat = rx[95:64];
      `SPI_RX_3:    wb_dat = rx[`SPI_MAX_CHAR-1:96];
`else
`ifdef SPI_MAX_CHAR_64
      `SPI_RX_0:    wb_dat = rx[31:0];
      `SPI_RX_1:    wb_dat = rx[`SPI_MAX_CHAR-1:32];
      `SPI_RX_2:    wb_dat = 32'b0;
      `SPI_RX_3:    wb_dat = 32'b0;
`else
      `SPI_RX_0:    wb_dat = {{32-`SPI_MAX_CHAR{1'b0}}, rx[`SPI_MAX_CHAR-1:0]};
      `SPI_RX_1:    wb_dat = 32'b0;
      `SPI_RX_2:    wb_dat = 32'b0;
      `SPI_RX_3:    wb_dat = 32'b0;
`endif
`endif
      `SPI_CTRL:    wb_dat = {{32-`SPI_CTRL_BIT_NB{1'b0}}, ctrl};
      `SPI_DEVIDE:  wb_dat = {{32-`SPI_DIVIDER_LEN{1'b0}}, divider};
      `SPI_SS:      wb_dat = {{32-`SPI_SS_NB{1'b0}}, ss};
      default:      wb_dat = 32'bx;
    endcase
  end
  
  // Wb data out
  always @(posedge wb_clk_is or posedge wb_rst_is)
  begin
    if (wb_rst_is)
      wb_dat_o <= #Tp 32'b0;
    else
      wb_dat_o <= #Tp wb_dat;
  end
  
  // Wb acknowledge & errror
  always @(posedge wb_clk_is or posedge wb_rst_is)
  begin
    if (wb_rst_is)
    begin
      wb_ack_o <= #Tp 1'b0;
      `ifdef WB_ACK_PULSED_ERR
          wb_ack_pulse <= #Tp 8'b0;
      `endif
    end
    else
    //wb_ack_o <= #Tp wb_cyc_is & wb_stb_is & ~wb_ack_o;
    begin
`ifdef WB_NO_ACK_ERR
          wb_ack_o <= 1'b0;
`else
    `ifdef WB_ACK_PULSED_ERR
          if (wb_cyc_is & wb_stb_is & ~wb_ack_o)
          begin
            if (~(|wb_ack_pulse))
              wb_ack_pulse <= #Tp 8'b11_10_00_11;
          end
     	  wb_ack_o <= #Tp wb_ack_pulse[7];
	      wb_ack_pulse <= #Tp {wb_ack_pulse[6:0], 1'b0}; 
    `else
          wb_ack_o <= #Tp wb_cyc_is & wb_stb_is & ~wb_ack_o;
      
    `endif
`endif
    end
  end
  
  // Wb error
  assign wb_err_o = wrong_addr_sel & wb_ack_o;
   
  
  //find 8 bits transmitted on MISO or received on MOSI
  always @(posedge wb_clk_is or posedge wb_rst_is)
  begin
    if (wb_rst_is)
       sclk_8_bit = 5'd0;
    else if (tip & pos_edge)
    begin
      sclk_8_bit = sclk_8_bit + 5'd1;
      if (sclk_8_bit == 9) 
         sclk_8_bit = 5'd0;
    end	
  end
  
  // Interrupt
  always @(posedge wb_clk_is or posedge wb_rst_is)
  begin
    if (wb_rst_is)
      wb_int_o <= #Tp 1'b0;
    else
//       if (ie && tip && last_bit && pos_edge)
//          wb_int_o <= #Tp 1'b1;
      `ifdef WB_INT_ERR
        if (ie & (sclk_8_bit == 8))
          wb_int_o <= #Tp 1'b1;
      `else
        if (ie && tip && last_bit && pos_edge)
          wb_int_o <= #Tp 1'b1;
      `endif
    else if (wb_ack_o)
      wb_int_o <= #Tp 1'b0;
  end
  
  `ifdef WRITE_AFTER_GOBSY_ERR
  `else
  always @(posedge wb_clk_is or posedge wb_rst_is)
  begin
    if (wb_rst_is)
      go_d1 <= #Tp 1'b0;
    else
      go_d1 <= #Tp go;
  end
  `endif
  
  // Divider register
  always @(posedge wb_clk_is or posedge wb_rst_is)
  begin
    if (wb_rst_is)
        //
        //(T.D.) The divider has the reset value 0x0000FFFF
        //divider <= #Tp {`SPI_DIVIDER_LEN{1'b0}};
        `ifdef SPI_DIVIDER_LEN_8
	   divider <= 32'h00_00_00_FF;
        `endif
        `ifdef SPI_DIVIDER_LEN_16
	   divider <= 32'h00_00_FF_FF;
        `endif
        `ifdef SPI_DIVIDER_LEN_24
	   divider <= 32'h00_FF_FF_FF;
        `endif
        `ifdef SPI_DIVIDER_LEN_32
	   divider <= 32'hFF_FF_FF_FF;
        `endif
    `ifdef WRITE_AFTER_GOBSY_ERR
    else if (spi_divider_sel && wb_we_is && !tip)
    `else
    else if (spi_divider_sel && wb_we_is && !(go|go_d1))
    `endif
      begin
      `ifdef DIVIDER_NO_UPDATE_ERR
      `else
         `ifdef DIVIDER_SHIFT_1_ERR
           `ifdef SPI_DIVIDER_LEN_8
              if (wb_sel_is[0])
                divider <= #Tp wb_dat_i[`SPI_DIVIDER_LEN:1];
           `endif
           `ifdef SPI_DIVIDER_LEN_16
              if (wb_sel_is[0])
                divider[7:0] <= #Tp wb_dat_i[8:1];
              if (wb_sel_is[1])
                divider[`SPI_DIVIDER_LEN-1:8] <= #Tp wb_dat_i[`SPI_DIVIDER_LEN:9];
           `endif
           `ifdef SPI_DIVIDER_LEN_24
              if (wb_sel_is[0])
                divider[7:0] <= #Tp wb_dat_i[8:1];
              if (wb_sel_is[1])
                divider[15:8] <= #Tp wb_dat_i[16:9];
              if (wb_sel_is[2])
                divider[`SPI_DIVIDER_LEN-1:16] <= #Tp wb_dat_i[`SPI_DIVIDER_LEN:17];
           `endif
           `ifdef SPI_DIVIDER_LEN_32
              if (wb_sel_is[0])
                divider[7:0] <= #Tp wb_dat_i[8:1];
              if (wb_sel_is[1])
                divider[15:8] <= #Tp wb_dat_i[16:9];
              if (wb_sel_is[2])
                divider[23:16] <= #Tp wb_dat_i[24:17];
              if (wb_sel_is[3])
                divider[`SPI_DIVIDER_LEN-1:24] <= #Tp {1'b1, wb_dat_i[`SPI_DIVIDER_LEN:25]};
           `endif
         `else // No Error
           `ifdef SPI_DIVIDER_LEN_8
              if (wb_sel_is[0])
                divider <= #Tp wb_dat_i[`SPI_DIVIDER_LEN-1:0];
           `endif
           `ifdef SPI_DIVIDER_LEN_16
              if (wb_sel_is[0])
                divider[7:0] <= #Tp wb_dat_i[7:0];
              if (wb_sel_is[1])
                divider[`SPI_DIVIDER_LEN-1:8] <= #Tp wb_dat_i[`SPI_DIVIDER_LEN-1:8];
           `endif
           `ifdef SPI_DIVIDER_LEN_24
              if (wb_sel_is[0])
                divider[7:0] <= #Tp wb_dat_i[7:0];
              if (wb_sel_is[1])
                divider[15:8] <= #Tp wb_dat_i[15:8];
              if (wb_sel_is[2])
                divider[`SPI_DIVIDER_LEN-1:16] <= #Tp wb_dat_i[`SPI_DIVIDER_LEN-1:16];
           `endif
           `ifdef SPI_DIVIDER_LEN_32
              if (wb_sel_is[0])
                divider[7:0] <= #Tp wb_dat_i[7:0];
              if (wb_sel_is[1])
                divider[15:8] <= #Tp wb_dat_i[15:8];
              if (wb_sel_is[2])
                divider[23:16] <= #Tp wb_dat_i[23:16];
              if (wb_sel_is[3])
                divider[`SPI_DIVIDER_LEN-1:24] <= #Tp wb_dat_i[`SPI_DIVIDER_LEN-1:24];
           `endif
         `endif
      `endif
      end
  end
  
  //(T.D.)  The CTRL register must be fully resetable, including bits 31:14, 7
  // Bit 0 (CHAR_LEN[0] is loaded incorreclty
  // Ctrl register
//  always @(posedge wb_clk_i or posedge wb_rst_i)
//  begin
//    if (wb_rst_i)
//      ctrl <= #Tp {`SPI_CTRL_BIT_NB{1'b0}};
//    else if(spi_ctrl_sel && wb_we_i && !tip)
//      begin
//        if (wb_sel_i[0])
//          ctrl[7:0] <= #Tp wb_dat_i[7:0] | {7'b0, ctrl[0]};
//        if (wb_sel_i[1])
//          ctrl[`SPI_CTRL_BIT_NB-1:8] <= #Tp wb_dat_i[`SPI_CTRL_BIT_NB-1:8];
//      end
//    else if(tip && last_bit && pos_edge)
//      ctrl[`SPI_CTRL_GO] <= #Tp 1'b0;
//  end

  always @(posedge wb_clk_is or posedge wb_rst_is)
  begin
    if (wb_rst_is)
      ctrl <= #Tp 32'b0;
    `ifdef WRITE_AFTER_GOBSY_ERR
    else if(spi_ctrl_sel && wb_we_is && !tip)
    `else
    else if(spi_ctrl_sel && wb_we_is && !(go|go_d1))
    `endif
      begin
      `ifdef CTRL_NO_UPDATE_ERR
      `else
        if (wb_sel_is[0])
        begin
          `ifdef CHAR_LEN_PLUS_4_ERR
             ctrl[6:0] <= #Tp wb_dat_i[6:0] + 4;
          `else
             ctrl[6:0] <= #Tp wb_dat_i[6:0];
          `endif
        end
        if (wb_sel_is[1])
          //ctrl[`SPI_CTRL_BIT_NB-1:8] <= #Tp wb_dat_i[`SPI_CTRL_BIT_NB-1:8];
         begin
           `ifdef ASS_LOAD_TX_NEG_ERR
              ctrl[`SPI_CTRL_ASS] <= #Tp ctrl[`SPI_CTRL_TX_NEGEDGE];
           `else
              ctrl[`SPI_CTRL_ASS] <= #Tp wb_dat_i[`SPI_CTRL_ASS];
           `endif

           `ifdef IE_LOAD_GO_BSY_ERR
              ctrl[`SPI_CTRL_IE] <= #Tp ctrl[`SPI_CTRL_GO];
           `else
              ctrl[`SPI_CTRL_IE] <= #Tp wb_dat_i[`SPI_CTRL_IE];
           `endif

           `ifdef LSB_SWITCH_ERR
              ctrl[`SPI_CTRL_LSB] <= #Tp ~wb_dat_i[`SPI_CTRL_LSB];
           `else
              ctrl[`SPI_CTRL_LSB] <= #Tp wb_dat_i[`SPI_CTRL_LSB];
           `endif

           `ifdef TX_NEG_XOR_ERR
              ctrl[`SPI_CTRL_TX_NEGEDGE] <= #Tp (wb_dat_i[`SPI_CTRL_TX_NEGEDGE] ^ ctrl[`SPI_CTRL_TX_NEGEDGE]) ;
           `else
              ctrl[`SPI_CTRL_TX_NEGEDGE] <= #Tp wb_dat_i[`SPI_CTRL_TX_NEGEDGE];
           `endif

           `ifdef RX_NEG_RAND_ERR
              rand_reg = $random;
              ctrl[`SPI_CTRL_RX_NEGEDGE] <= #Tp rand_reg[6];
           `else
              ctrl[`SPI_CTRL_RX_NEGEDGE] <= #Tp wb_dat_i[`SPI_CTRL_RX_NEGEDGE];
           `endif

           `ifdef GO_BSY_STUCK_1_ERR
              ctrl[`SPI_CTRL_GO] <= #Tp 1;
           `else
              ctrl[`SPI_CTRL_GO] <= #Tp wb_dat_i[`SPI_CTRL_GO];
           `endif
         end
      `endif
      end
    else if(tip && last_bit && pos_edge)
    begin
       `ifdef CTRL_NO_UPDATE_ERR
       `else
          `ifdef GO_BSY_STUCK_1_ERR
              ctrl[`SPI_CTRL_GO] <= #Tp 1'b1;
          `else
              ctrl[`SPI_CTRL_GO] <= #Tp 1'b0;
          `endif
       `endif
    end
  end
  
  assign rx_negedge = ctrl[`SPI_CTRL_RX_NEGEDGE];
  assign tx_negedge = ctrl[`SPI_CTRL_TX_NEGEDGE];
  assign go         = ctrl[`SPI_CTRL_GO];
  assign char_len   = ctrl[`SPI_CTRL_CHAR_LEN];
  assign lsb        = ctrl[`SPI_CTRL_LSB];
  assign ie         = ctrl[`SPI_CTRL_IE];
  assign ass        = ctrl[`SPI_CTRL_ASS];
  
  // Slave select register
  always @(posedge wb_clk_is or posedge wb_rst_is)
  begin
    if (wb_rst_is)
      ss <= #Tp {`SPI_SS_NB{1'b0}};
    `ifdef WRITE_AFTER_GOBSY_ERR
    else if(spi_ss_sel && wb_we_is && !tip)
    `else
    else if(spi_ss_sel && wb_we_is && !(go|go_d1))
    `endif
      begin
      `ifdef SS_NO_UPDATE_ERR
      `else
         `ifdef SS_RAND_ERR
            rand_reg = $random;
            `ifdef SPI_SS_NB_8
                if (wb_sel_is[0])
                  ss <= #Tp (8'b0000_0001 << rand_reg[2:0]);
            `endif
            `ifdef SPI_SS_NB_16
               if (wb_sel_is[0])
                     ss[7:0] <= #Tp (8'b0000_0001 << rand_reg[3:0]);
               if (wb_sel_is[1])
                  if (rand_reg[3:0] > 7 )
                     ss[`SPI_SS_NB-1:8] <= #Tp (8'b0000_0001 << (rand_reg[3:0] - 8));
            `endif
              `ifdef SPI_SS_NB_24
                 if (wb_sel_is[0])
                   ss[7:0] <= #Tp (8'b0000_0001 << rand_reg[4:0]);
                 if (wb_sel_is[1])
                   if (rand_reg[4:0] > 7)
                     ss[15:8] <= #Tp (8'b0000_0001 << (rand_reg[4:0] - 8));
                 if (wb_sel_is[2])
                   if (rand_reg[4:0] > 15 )
                     ss[`SPI_SS_NB-1:16] <= #Tp (8'b0000_0001 << (rand_reg[4:0] - 16));
              `endif
              `ifdef SPI_SS_NB_32
                 if (wb_sel_is[0])
                   ss[7:0] <= #Tp (8'b0000_0001 << rand_reg[4:0]);
                 if (wb_sel_is[1])
                   if (rand_reg[4:0] > 7)
                     ss[15:8] <= #Tp (8'b0000_0001 << (rand_reg[4:0] - 8));
                 if (wb_sel_is[2])
                   if (rand_reg[4:0] > 15)
                     ss[23:16] <= #Tp (8'b0000_0001 << (rand_reg[4:0] - 16));
                 if (wb_sel_is[3])
                   if (rand_reg[4:0] > 23)
                     ss[`SPI_SS_NB-1:24] <= #Tp (8'b0000_0001 << (rand_reg[4:0] - 24));
              `endif
         `else
           `ifdef SS_SHIFT_ERR
              `ifdef SPI_SS_NB_8
                 if (wb_sel_is[0])
                   ss <= #Tp {wb_dat_i[`SPI_SS_NB-2:0],wb_dat_i[`SPI_SS_NB-1]} ;
              `endif
              `ifdef SPI_SS_NB_16
                 if (wb_sel_is[0])
                   ss[7:0] <= #Tp {wb_dat_i[6:0], wb_dat_i[`SPI_SS_NB-1]};
                 if (wb_sel_is[1])
                   ss[`SPI_SS_NB-1:8] <= #Tp wb_dat_i[`SPI_SS_NB-2:7];
              `endif
              `ifdef SPI_SS_NB_24
                 if (wb_sel_is[0])
                   ss[7:0] <= #Tp {wb_dat_i[6:0], wb_dat_i[`SPI_SS_NB-1]};
                 if (wb_sel_is[1])
                   ss[15:8] <= #Tp wb_dat_i[14:7];
                 if (wb_sel_is[2])
                   ss[`SPI_SS_NB-1:16] <= #Tp wb_dat_i[`SPI_SS_NB-2:15];
              `endif
              `ifdef SPI_SS_NB_32
                 if (wb_sel_is[0])
                   ss[7:0] <= #Tp {wb_dat_i[6:0], wb_dat_i[`SPI_SS_NB-1]};
                 if (wb_sel_is[1])
                   ss[15:8] <= #Tp wb_dat_i[14:7];
                 if (wb_sel_is[2])
                   ss[23:16] <= #Tp wb_dat_i[22:15];
                 if (wb_sel_is[3])
                   ss[`SPI_SS_NB-1:24] <= #Tp wb_dat_i[`SPI_SS_NB-2:23];
              `endif 
           `else // No Err
              `ifdef SPI_SS_NB_8
                 if (wb_sel_is[0])
                   ss <= #Tp wb_dat_i[`SPI_SS_NB-1:0];
              `endif
              `ifdef SPI_SS_NB_16
                 if (wb_sel_is[0])
                   ss[7:0] <= #Tp wb_dat_i[7:0];
                 if (wb_sel_is[1])
                   ss[`SPI_SS_NB-1:8] <= #Tp wb_dat_i[`SPI_SS_NB-1:8];
              `endif
              `ifdef SPI_SS_NB_24
                 if (wb_sel_is[0])
                   ss[7:0] <= #Tp wb_dat_i[7:0];
                 if (wb_sel_is[1])
                   ss[15:8] <= #Tp wb_dat_i[15:8];
                 if (wb_sel_is[2])
                   ss[`SPI_SS_NB-1:16] <= #Tp wb_dat_i[`SPI_SS_NB-1:16];
              `endif
              `ifdef SPI_SS_NB_32
                 if (wb_sel_is[0])
                   ss[7:0] <= #Tp wb_dat_i[7:0];
                 if (wb_sel_is[1])
                   ss[15:8] <= #Tp wb_dat_i[15:8];
                 if (wb_sel_is[2])
                   ss[23:16] <= #Tp wb_dat_i[23:16];
                 if (wb_sel_is[3])
                   ss[`SPI_SS_NB-1:24] <= #Tp wb_dat_i[`SPI_SS_NB-1:24];
              `endif
           `endif
        `endif
      `endif
      end
  end

 //(T.D.) simplified the logic
 //assign ss_pad_o = ~((ss & {`SPI_SS_NB{tip & ass}}) |(ss & {`SPI_SS_NB{!ass}}));
 assign ss_pad_o = ~(ss & {`SPI_SS_NB{tip | (!ass)}});

 always @(sclk_pad_os)
 begin
   `ifdef SPI_NO_SCLK_ERR
      sclk_pad_o = 1'b0;
   `else
      sclk_pad_o = sclk_pad_os;
   `endif
 end		     

 always @(posedge sclk_pad_os)
    mosi_pad_o_delayed = {mosi_pad_o_delayed[0], mosi_pad_os};

 always @(mosi_pad_os or mosi_pad_o_delayed)
 begin
   `ifdef SPI_NO_MOSI_ERR
       mosi_pad_o = 1'b0;
   `else
      `ifdef SPI_MOSI_DELAYED_ERR
         mosi_pad_o = mosi_pad_o_delayed[1];
      `else
         mosi_pad_o = mosi_pad_os;
      `endif
   `endif 
 end
  
  //(T.D.)
  reg	go_s;
  always @(posedge wb_clk_is or posedge wb_rst_is)
  begin
    if (wb_rst_is)
         go_s <= #Tp 1'b0;
    else if(tip && last_bit && pos_edge)
         go_s <= #Tp 1'b0;
    else
         go_s <= #Tp go;       
  end
  spi_clgen clgen (.clk_in(wb_clk_is), .rst(wb_rst_is), .go(go_s), .enable(tip), .last_clk(last_bit),
                   .divider(divider), .clk_out(sclk_pad_os), .pos_edge(pos_edge), 
                   .neg_edge(neg_edge));
  
  spi_shift shift (.clk(wb_clk_is), .rst(wb_rst_is), .len(char_len[`SPI_CHAR_LEN_BITS-1:0]),
                   .latch(spi_tx_sel[3:0] & {4{wb_we_i}}), .byte_sel(wb_sel_is), .lsb(lsb), 
                   .go(go_s), .pos_edge(pos_edge), .neg_edge(neg_edge), 
                   .rx_negedge(rx_negedge), .tx_negedge(tx_negedge),
                   .tip(tip), .last(last_bit), 
                   .p_in(wb_dat_i), .p_out(rx), 
                   .s_clk(sclk_pad_os), .s_in(miso_pad_i), .s_out(mosi_pad_os));
endmodule
  
