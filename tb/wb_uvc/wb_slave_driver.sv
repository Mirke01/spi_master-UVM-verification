class wb_slave_driver extends uvm_driver #(.REQ(wb_seq_item), .RSP(wb_seq_item));
  
  `uvm_component_utils(wb_slave_driver)
  
  virtual wb_if vif;
    
  function new(string name = "wb_slave_driver", uvm_component parent=null);
    super.new(name,parent);
  endfunction
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual wb_if)::get(this, "", "vif", vif))
         `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"}); 
  endfunction
        
  task get_and_drive(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive(phase, req, rsp);   
      seq_item_port.item_done(rsp);
    end
  endtask

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    get_and_drive(phase);
  endtask
    
  virtual task drive(uvm_phase phase, REQ req, output RSP rsp);
     @(posedge vif.clk iff vif.rst == 0); //driving signals only if rst is negated
     for(int i = 0 ; i < req.trans_number; i++) begin
        @(posedge vif.clk  iff (vif.cyc == 1'b1 && vif.stb == 1'b1));//if both cyc and stb are asserted, insert:
        repeat(req.wss_delay[i]) @(posedge vif.clk); //rand number of wss delays
        if (vif.we == 0) vif.data_rd <= req.data[i]; //collect data from seq_item and drive it to data_rd on vif only if we is negated
        vif.ack <= 1'b1; // assert ack regardless of read or write
        @(posedge vif.clk); //on next positive clk edge
        vif.ack <= 1'b0; //negate the ack
     end
  endtask 
  
endclass
