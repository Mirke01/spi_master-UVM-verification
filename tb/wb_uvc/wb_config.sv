class wb_config extends uvm_object;
  
  rand uvm_active_passive_enum active_master_agent;
  rand uvm_active_passive_enum active_slave_agent;
  
  `uvm_object_utils_begin(wb_config)
    `uvm_field_enum(uvm_active_passive_enum, active_master_agent, UVM_ALL_ON)
    `uvm_field_enum(uvm_active_passive_enum, active_slave_agent, UVM_ALL_ON)
  `uvm_object_utils_end

  
  function new(string name = "wb_config");
    super.new(name);
  endfunction
  //constrains both master and slave agent to be active (containing monitor, driver and sequencer)
  constraint is_active_c{
    soft active_master_agent == UVM_ACTIVE;
    soft active_slave_agent == UVM_ACTIVE;
  }
   
endclass
