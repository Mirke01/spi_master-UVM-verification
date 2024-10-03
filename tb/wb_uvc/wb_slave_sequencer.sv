class wb_slave_sequencer extends uvm_sequencer#(.REQ(wb_seq_item), .RSP(wb_seq_item));
  
  `uvm_component_utils(wb_slave_sequencer)
  
  function new(string name = "wb_slave_sequencer", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
endclass
