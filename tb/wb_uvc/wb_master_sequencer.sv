class wb_master_sequencer extends uvm_sequencer#(.REQ(wb_seq_item), .RSP(wb_seq_item));
  
  `uvm_component_utils(wb_master_sequencer)
  
  function new(string name = "wb_master_sequencer", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
endclass
