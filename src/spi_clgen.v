`include "spi_defines.v"
`include "spi_timescale.v"
`include "spi_errors.v"


module spi_clgen (clk_in, rst, go, enable, last_clk, divider, clk_out, pos_edge, neg_edge); 

  parameter Tp = 1;
  
  input                            clk_in;   // input clock (system clock)
  input                            rst;      // reset
  input                            enable;   // clock enable
  input                            go;       // start transfer
  input                            last_clk; // last clock
  input     [`SPI_DIVIDER_LEN-1:0] divider;  // clock divider (output clock is divided by this value)
  output                           clk_out;  // output clock
  output                           pos_edge; // pulse marking positive edge of clk_out
  output                           neg_edge; // pulse marking negative edge of clk_out
                            
  reg                              clk_out;
//(T.D.)
//  reg                              pos_edge;
//  reg                              neg_edge;

  reg                              pos_edge_r;
  reg                              neg_edge_r;

  wire				   pos_edge;
  wire				   neg_edge;

                            
  reg       [`SPI_DIVIDER_LEN-1:0] cnt;      // clock counter 
  wire                             cnt_zero; // conter is equal to zero
  wire                             cnt_one;  // conter is equal to one
  
  //(T.D.)
  reg [31:0]  rand_reg;

  assign cnt_zero = cnt == {`SPI_DIVIDER_LEN{1'b0}};
  assign cnt_one  = cnt == {{`SPI_DIVIDER_LEN-1{1'b0}}, 1'b1};
  
  // Counter counts half period
  always @(posedge clk_in or posedge rst)
  begin
    if(rst)
      cnt <= #Tp {`SPI_DIVIDER_LEN{1'b1}};
    else
      begin
        if(!enable || cnt_zero)
        begin
          //cnt <= #Tp divider;
          `ifdef SPI_NO_SCLK_ERR
              cnt <= #Tp 0;
          `else
	     `ifdef SPI_RAND_SCLK_ERR
                 rand_reg = $random;
                 cnt = #Tp divider + rand_reg[1:0];
             `else
                 cnt <= #Tp divider;
             `endif
          `endif
        end
        else
          cnt <= #Tp cnt - {{`SPI_DIVIDER_LEN-1{1'b0}}, 1'b1};
      end
  end
  
  // clk_out is asserted every other half period
  always @(posedge clk_in or posedge rst)
  begin
    if(rst)
      clk_out <= #Tp 1'b0;
    else
      clk_out <= #Tp (enable && cnt_zero && (!last_clk || clk_out)) ? ~clk_out : clk_out;
  end
   
  // Pos and neg edge signals
  always @(posedge clk_in or posedge rst)
  begin
    if(rst)
      begin
        pos_edge_r  <= #Tp 1'b0;
        neg_edge_r  <= #Tp 1'b0;
      end
    else
      begin
        pos_edge_r  <= #Tp (enable && !clk_out && cnt_one) || (!(|divider) && clk_out) || (!(|divider) && go && !enable);
        neg_edge_r  <= #Tp (enable && clk_out && cnt_one) || (!(|divider) && !clk_out && enable);
      end
  end
//(T.D.)
  assign pos_edge = pos_edge_r & enable;
  assign neg_edge = neg_edge_r & enable;

endmodule
 
