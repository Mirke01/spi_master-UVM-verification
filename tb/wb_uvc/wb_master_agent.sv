class wb_master_agent extends uvm_agent;
  
  `uvm_component_utils(wb_master_agent)
  
  wb_master_driver       m_driver;
  wb_master_monitor      m_monitor;
  wb_master_sequencer    m_seqr;
  wb_config              wb_cfg;
    
  function new(string name = "wb_master_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
   if(!uvm_config_db#(wb_config)::get(this, "", "wb_cfg", wb_cfg))
         `uvm_fatal("NOVIF", {"Configuration must be set ", get_full_name(), ".wb_cfg"});
    
   if(wb_cfg.active_master_agent == UVM_ACTIVE) begin
      m_driver = wb_master_driver::type_id::create ("m_driver", this);
      m_seqr = wb_master_sequencer::type_id::create ("m_seqr", this);
  end
    
    m_monitor = wb_master_monitor::type_id::create ("m_monitor", this);
    
  endfunction
    
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //connect sequencer and driver if active
    if(wb_cfg.active_master_agent == UVM_ACTIVE) begin
      m_driver.seq_item_port.connect(m_seqr.seq_item_export);
    end 
  endfunction
  
endclass
