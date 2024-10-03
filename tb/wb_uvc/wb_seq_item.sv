class wb_seq_item extends uvm_sequence_item; 
   
  rand logic [`WB_ADDR_WIDTH-1:0] addr[$]; //dynamic queue of parameterized size of array for address
  rand logic [`WB_DATA_WIDTH-1:0] data[$]; //dynamic queue of parameterized size of array for data
  rand logic [`WB_SEL_SIZE-1:0]   sel[$]; //dynamic queue of parameterized size of array for select
  rand transaction_type_t trans_type; //type of data transaction (single_rd, single_wr, block_rd, block_wr, rmw)
  rand int trans_number; //number of transactions during data cycle 
  rand int initial_delay; //initial delay at the beginning of simulation
  rand int final_delay; //final delay after master-slave handshake protocol
  rand int wsm_delay[$]; //dynamic queue of wait states inserted by master
  rand int wss_delay[$]; //dynamic queue of wait states inserted by slave
  
  `uvm_object_utils_begin(wb_seq_item)
    `uvm_field_queue_int(addr, UVM_ALL_ON)
    `uvm_field_queue_int(data, UVM_ALL_ON)
    `uvm_field_queue_int(sel, UVM_ALL_ON)
    `uvm_field_enum(transaction_type_t,trans_type, UVM_ALL_ON)
    `uvm_field_int(trans_number, UVM_ALL_ON)
    `uvm_field_int(initial_delay, UVM_ALL_ON)
    `uvm_field_int(final_delay, UVM_ALL_ON)
    `uvm_field_queue_int(wsm_delay, UVM_ALL_ON)
    `uvm_field_queue_int(wss_delay, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "wb_seq_item");
    super.new(name);
  endfunction
  //constrains the duration of initial delay
  constraint initial_delay_c { initial_delay > 0;
                               initial_delay < 10; 
  }
  //constrains the duration of final delay
  constraint final_delay_c { final_delay > 0;
                             final_delay < 10; 
  }
  //constrains the duration of every wsm
  constraint wsm_delay_c { 
		foreach(wsm_delay[i]){
			soft wsm_delay[i] > 0;
			soft wsm_delay[i] < 10;
		  }
  }
  //constrains the duration of every wss
  constraint wss_delay_c { 
		foreach(wss_delay[i]){
			soft wss_delay[i] > 0;
			soft wss_delay[i] < 10;
		  }
  }
	//constrains number of transactions depending on type of data transaction
  constraint trans_number_c { 
      (trans_type == SINGLE_RD || trans_type == SINGLE_WR) -> trans_number == 1;
      (trans_type == BLOCK_RD  || trans_type == BLOCK_WR)  -> trans_number > 1 && trans_number < 20;
      (trans_type == RMW) -> trans_number == 2;
  }
  //constrains dynamic queues to be the size of number of transactions constrained by type of data transaction
  constraint queue_sizes_c { 
      addr.size() == trans_number;
      data.size() == trans_number;
      sel.size()  == trans_number;  
      wsm_delay.size() == trans_number;
	    wss_delay.size() == trans_number;
  }
  //constrains address values for rmw so that they are equal during both read and write half of the cycle
  constraint rmw_addr_c {
	    (trans_type == RMW) -> addr[1] == addr[0];
  }
  
endclass
