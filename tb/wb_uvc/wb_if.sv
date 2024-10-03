interface wb_if (input logic clk, input logic rst);
  
  logic [`WB_ADDR_WIDTH-1:0]  addr; //address
  logic [`WB_DATA_WIDTH-1:0]  data_rd; //data read
  logic [`WB_DATA_WIDTH-1:0]  data_wr; //data write
  logic [`WB_SEL_SIZE-1:0]    sel; //select signal(indicates where valid data is expected, size determined by port granularity)
  logic         we; //write enable signal(determines read or write)   
  logic         stb; //strobe signal(indicates data transfer)
  logic         ack; //acknowledge signal(terminates data transfer)
  logic         cyc; //cycle signal(indicates start/end of cycle)

  logic  checks_enabled; 
  default disable iff (!checks_enabled);  
  default clocking @(posedge clk); endclocking
    
  property asserted_stb_with_stable_sel; //select has to be stable when strobe is active
      disable iff (rst) stb == 1 |=> $stable(sel);
  endproperty
   
  chk_asserted_stb_with_stable_sel : assert property (asserted_stb_with_stable_sel) 
     else $error("Failed to pass the checker: chk_asserted_stb_with_stable_sel");
   
  property rising_ack_with_asserted_stb; //strobe has to be active on rising edge of acknowledge
     disable iff (rst) $rose(ack) |-> stb == 1;
  endproperty
   
  chk_rising_ack_with_asserted_stb : assert property(rising_ack_with_asserted_stb)
     else $error("Failed to pass the checker: chk_rising_ack_with_asserted_stb");
   
  property falling_ack_with_falling_stb; //strobe and acknowledge have to fall on same clk edge
     disable iff (rst) $fell(ack) |-> $fell(stb);
  endproperty
   
  chk_falling_ack_with_falling_stb : assert property(falling_ack_with_falling_stb)
     else $error("Failed to pass the checker: chk_falling_ack_with_falling_stb");
   
  property falling_stb_after_one_ack_cycle; //ack has to last for one clk cycle and fall at the same clk edge as strobe
     disable iff (rst) (ack ##1 !ack) |-> $fell(stb);
  endproperty
   
  chk_falling_stb_after_one_ack_cycle : assert property(falling_stb_after_one_ack_cycle)
    else $error("Failed to pass the checker: chk_falling_stb_after_one_ack_cycle");
  
  property rising_of_stb_with_valid_addr; //address has to be active during rising edge of strobe
    disable iff (rst) $rose(stb) |-> addr !== 'x;
  endproperty
   
  chk_rising_of_stb_with_valid_addr : assert property(rising_of_stb_with_valid_addr)
    else $error("Failed to pass the checker: chk_rising_of_stb_with_valid_addr");
  
  property assertion_of_stb_with_valid_addr; //address has to be active when strobe is already high
    disable iff (rst) stb == 1 |-> addr !== 'x;
  endproperty
   
  chk_assertion_of_stb_with_valid_addr : assert property(assertion_of_stb_with_valid_addr)
    else $error("Failed to pass the checker: chk_assertion_of_stb_with_valid_addr");
  
  property write_cycle_qualification; //write enable is high when cyc is active, strobe is falling and data_rd is undefined (write operation)
    disable iff (rst) (cyc && $fell(stb) && $isunknown(data_rd)) |-> we;
  endproperty
   
  chk_write_cycle_qualification : assert property(write_cycle_qualification)
    else $error("Failed to pass the checker: chk_write_cycle_qualification");
  
  property read_cycle_qualification; //write enable is low when cyc is active, strobe is falling and data_wr is undefined (read operation)
    disable iff (rst) (cyc && $fell(stb) && $isunknown(data_wr)) |-> !we;
  endproperty
   
  chk_read_cycle_qualification : assert property(read_cycle_qualification)
    else $error("Failed to pass the checker: chk_read_cycle_qualification");

  property negation_of_cyc_resets_addr; //address is undefined when cyc is low
    disable iff (rst) !cyc |=> $isunknown(addr);
  endproperty
   
  chk_negation_of_cyc_resets_addr : assert property(negation_of_cyc_resets_addr)
    else $error("Failed to pass the checker: chk_negation_of_cyc_resets_addr");
  
  property assertion_of_cyc_and_stb; //strobe has to rise at least one clk cycle (or more) after cyc rises
    disable iff (rst) $rose(cyc) |-> ##[1:$] stb;
  endproperty
   
  chk_assertion_of_cyc_and_stb : assert property(assertion_of_cyc_and_stb)
    else $error("Failed to pass the checker: chk_assertion_of_cyc_and_stb");
  
  property negation_of_cyc_and_stb; //strobe has to fall at least one clk cycle before cyc falls
    disable iff (rst) (cyc ##1 !cyc) |-> $past(!stb,1);
  endproperty
   
  chk_negation_of_cyc_and_stb : assert property(negation_of_cyc_and_stb)
    else $error("Failed to pass the checker: chk_negation_of_cyc_and_stb");
  
endinterface
