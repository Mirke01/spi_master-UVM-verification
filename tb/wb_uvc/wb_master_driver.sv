class wb_master_driver extends uvm_driver #(.REQ(wb_seq_item), .RSP(wb_seq_item));
  
  `uvm_component_utils(wb_master_driver)
  
  virtual wb_if vif;
  
  function new(string name = "wb_master_driver", uvm_component parent=null);
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
    reset_signals(phase);
    get_and_drive(phase);
  endtask
    
   virtual task drive(uvm_phase phase, REQ req, output RSP rsp); 
     //TODO:REVIEW Comments
      repeat(req.initial_delay) @(posedge vif.clk);//start the simulation with rand initial delays
      vif.cyc <= 1;//assert cyc to start the entire transaction
      for (int i = 0; i < req.trans_number; i++) begin
         repeat(req.wsm_delay[i]) @(posedge vif.clk);//master inserts a rand number of delays at every rising clk edge
         vif.addr <= req.addr[i];//address and select driven to vif regardless of transaction type
         vif.sel <= req.sel[i];
         if (req.trans_type == SINGLE_WR || req.trans_type == BLOCK_WR) begin//driving logic for write cycles
          vif.we <= 1; //assertion of we to indicate a write cycle
          vif.data_wr <= req.data[i]; //master collects data from seq_item to drive to vif
          vif.data_rd <= 'x; //assertion of undefined value to data_rd during write cycle
         end 
         else if (req.trans_type == SINGLE_RD || req.trans_type == BLOCK_RD) begin//driving logic for read cycles
          vif.we <= 0; //negation of we to indicate a read cycle
          vif.data_wr <= 'x; //assertion of undefined value to data_wr during read cycle
         end
         else if (req.trans_type == RMW) begin//driving logic for rmw cycle
          if(req.trans_number[i] == 0) begin//first transfer is single read; rmw has trans number constrained to 2
            vif.we <= 0;//negation of we to indicate a read cycle
            vif.data_wr <= 'x; //assertion of undefined value to data_wr during read cycle
          end 
          if (req.trans_number[i]== 1) begin//second transfer is single write
            vif.we <= 1; //assertion of we to indicate a write cycle
            vif.data_wr <= req.data[1];//second in queue of data is driven to vif during write cycle
            vif.data_rd <= 'x;//assertion of undefined value to data_rd during write cycle
          end
         end
         vif.stb = 1;//assertion of strobe regardless of transaction type, for every transaction
         @(posedge vif.clk iff vif.ack);//at every posedge clk during for loop if ack occurred:
         vif.stb <= 0;// negation of strobe
      end
      repeat(req.final_delay) @(posedge vif.clk);//ending the simulation with rand final delays
      vif.cyc <= 0;//negation of cyc to end the entire transaction  
      reset_signals(phase); //resetting all signals between every trans_type  
  endtask 
  
  virtual task reset_signals(uvm_phase phase);
      vif.addr    = 'hx;
      vif.data_rd = 'hx; 
      vif.data_wr = 'hx; 
      vif.sel     = 'hx;
      vif.cyc     = 1'b0;
      vif.stb     = 1'b0;
      vif.we      = 'x;
      vif.ack     = 1'b0;
  endtask
  
endclass
