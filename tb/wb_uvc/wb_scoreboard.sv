class wb_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(wb_scoreboard)
  
  function new(string name = "wb_scoreboard", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  //create analysis port handle
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //instantiate analysis port
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    //comparing, checking, scoring and other
  endtask
  
  virtual function void connect_phase(uvm_phase phase);
    //connect scoreboard with monitor
  endfunction
  
  virtual function void check_phase(uvm_phase phase);
    //check for errors
  endfunction
  
endclass
