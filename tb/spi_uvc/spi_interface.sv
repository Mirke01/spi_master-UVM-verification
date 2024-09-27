//=================================================================================
//COPYRIGHT 2024 Infineon. All rights reserved.
//
//This software is unpublished and remains trade secrets of NoBug Infineon.
//
//=================================================================================
//
//File: spi_interface.sv
//Version:1.0
//Author: Veljko Miric
//=================================================================================


interface spi_interface(input clk, rst);
    
    // including the file for data type of spi modes
    `include "/home/nbtrain.ivcs/GIT/miricv/wa/miricv_sv_uvm/git/default/units/spi_master/source/sv/uvc_lib/spi_uvc/spi_types.sv"



    // SPI Interface signals
    logic [7:0] ss_pad_o;
    logic sclk_pad_o;
    logic mosi_pad_o;
    logic miso_pad_i;
     
     
     
     // Properties for reset check
     property signals_reseted ();
         @(posedge clk) rst |=> ss_pad_o == 'hFF && mosi_pad_o === 1'bx && miso_pad_i === 1'bx;
     endproperty : signals_reseted
     
     property signals_activated ();
         @(posedge clk) ($fell(rst)) |-> ##[0 : $] ss_pad_o != 'hFF && mosi_pad_o !== 1'bx && miso_pad_i !== 1'bx;    
     endproperty : signals_activated
     
     
     
     
     // Property for slaves
     property ss_deactivated ();
         @(posedge sclk_pad_o) !rst |-> ##[1 : `MAX_DATA_WIDTH] ss_pad_o == 'hFF;
     endproperty : ss_deactivated
     
     property only_one_slave_low();
         int count = 8; 
	 int i = 0;
	 @(posedge clk) $rose(sclk_pad_o) |-> $countones(ss_pad_o) == 7; 
	 
     endproperty : only_one_slave_low
     
     /*   //more brute force option for previous property
     sequence s1();
         (ss_pad_o == 8'b1111_1110 ||
	 ss_pad_o == 8'b1111_1101 ||
         ss_pad_o == 8'b1111_1011 ||
         ss_pad_o == 8'b1111_0111 ||
         ss_pad_o == 8'b1110_1111 ||
         ss_pad_o == 8'b1101_1111 ||
         ss_pad_o == 8'b1011_1111 ||
         ss_pad_o == 8'b0111_1111);
     endsequence : s1
	 
     property only_one_slave_low();
         @(posedge sclk_pad_o) s1;
     endproperty : only_one_slave_low    
     
     */
     
     // Property for sclk
     property sclk_length();
         @(posedge clk) !rst |-> ##[1 : 33] sclk_pad_o == 1'b1 |-> ##[1 : 33] sclk_pad_o == 1'b0;
     endproperty : sclk_length
     
     property sclk_zero_on_time();
         @(posedge clk) disable iff(rst) ss_pad_o == 'hFF |-> sclk_pad_o == 1'b0;
     endproperty : sclk_zero_on_time
     
     
     // Assert properties
     ap_signals_reseted : assert property (signals_reseted) else 
         $error("reset_signals assertion failed!");
	     
     ap_signals_activated : assert property (signals_activated) else
         $error("signals_activated assertion failed!");
	  
     ap_ss_deactivated : assert property (ss_deactivated)  else
         $error("ss_deactivated assertion failed!");
	 
     ap_sclk_length : assert property (sclk_length) else
         $error("sclk_length assertion failed!");
	 
     ap_sclk_zero_on_time : assert property (sclk_zero_on_time) else
         $error("sclk_zero_on_time assertion failed!");
	 
     ap_only_one_slave_low : assert property (only_one_slave_low) else
         $error("only_one_slave_low assertion failed!");
  	
endinterface
 
