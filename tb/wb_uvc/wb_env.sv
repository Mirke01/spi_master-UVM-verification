class wb_env extends uvm_env;

  `uvm_component_utils(wb_env)
  
  wb_master_agent        wb_m_agent;
  wb_slave_agent         wb_s_agent;
  //wb_scoreboard          scbd;
  wb_config              wb_cfg;

  function new(string name = "wb_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(wb_config)::get(this, "", "wb_cfg", wb_cfg))
         `uvm_fatal("NOVIF", {"Configuration must be set ", get_full_name(), ".wb_cfg"});
    
    if(wb_cfg.active_master_agent == UVM_ACTIVE) begin
      wb_m_agent = wb_master_agent::type_id::create ("wb_m_agent", this);
    end
    if(wb_cfg.active_slave_agent == UVM_ACTIVE) begin
      wb_s_agent = wb_slave_agent::type_id::create ("wb_s_agent", this);
    end
    //scbd = wb_scoreboard::type_id::create ("scbd", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //connect agent/s and scoreboard
  endfunction

endclass
