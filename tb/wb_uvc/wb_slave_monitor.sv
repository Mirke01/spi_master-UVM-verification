class wb_slave_monitor extends uvm_monitor;
  
  `uvm_component_utils(wb_slave_monitor)
  
  virtual wb_if vif;
  //create analysis port handle
  
  function new(string name = "wb_slave_monitor", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //create analysis port
    if(!uvm_config_db#(virtual wb_if)::get(this, "", "vif", vif))
         `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"}); 
  endfunction

  virtual task collect_transactions(uvm_phase phase);
    forever begin
      wb_seq_item item = wb_seq_item::type_id::create("item",this);
      collect(item);  
    end

  endtask

  virtual task collect(wb_seq_item item);
  endtask
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    //collect_transactions(phase);
  endtask
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass
