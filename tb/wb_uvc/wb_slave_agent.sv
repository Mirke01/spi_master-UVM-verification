class wb_slave_agent extends uvm_agent;
  
  `uvm_component_utils(wb_slave_agent)
  
  wb_slave_driver       s_driver;
  wb_slave_monitor      s_monitor;
  wb_slave_sequencer    s_seqr;
  wb_config             wb_cfg;
    
  function new(string name = "wb_slave_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction
    
   virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    if(!uvm_config_db#(wb_config)::get(this, "", "wb_cfg", wb_cfg))
         `uvm_fatal("NOVIF", {"Configuration must be set ", get_full_name(), ".wb_cfg"});
    
    if(wb_cfg.active_slave_agent == UVM_ACTIVE) begin
      s_driver = wb_slave_driver::type_id::create ("s_driver", this);
      s_seqr = wb_slave_sequencer::type_id::create ("s_seqr", this);
    end
    
    s_monitor = wb_slave_monitor::type_id::create ("s_monitor", this);
    
  endfunction
    
  virtual function void connect_phase(uvm_phase phase); 
    super.connect_phase(phase);
    //connect sequencer and driver if active
    if(wb_cfg.active_slave_agent == UVM_ACTIVE) begin
     s_driver.seq_item_port.connect(s_seqr.seq_item_export);
    end  
  endfunction
  
endclass
