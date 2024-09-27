//=================================================================================
//COPYRIGHT 2024 Infineon. All rights reserved.
//
//This software is unpublished and remains trade secrets of NoBug Infineon.
//
//=================================================================================
//
//File: spi_uvc_tb.sv
//Version:1.0
//Author: Veljko Miric
//=================================================================================


module spi_uvc_tb;
  
  // Include spi package
  import uvm_pkg::*;
  import spi_pkg::*;
  import spi_test_pkg::*;
  


  // Standard signals
  reg clk;
  reg rst;
  
  
  // Interface
  spi_interface vif(clk, rst);
  
  
  // UVM Initial block: Interface wrapping & run_test()
  initial begin
      uvm_config_db#(virtual spi_interface)::set(null, "*", "vif", vif);
    
      run_test();
  end
  
  
  // UVM initial block: clock and reset initialization
  initial begin
      clk = 0;
      rst = 1;
      
      #100ns;
      
      rst = 0;  
  end
  
  
  // UVM always block: clk generator
  always 
      #10ns clk = ~clk;    


endmodule : spi_uvc_tb
