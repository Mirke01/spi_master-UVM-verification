// Base sequence class
class spi_base_seq extends uvm_sequence #(spi_data_item);

    // Constructor
    function new(string name = "spi_base_seq");
        super.new(name);
    endfunction


    // UVM automation macros for sequences
    `uvm_object_utils(spi_base_seq)


    // Decla base sequencer
    `uvm_declare_p_sequencer(spi_sequencer)


     // Pre body task
     task pre_body();
    if(starting_phase != null)
        starting_phase.raise_objection(this);
    endtask : pre_body
    

    // Post body task
    task post_body();
    if(starting_phase != null)
        starting_phase.drop_objection(this);
    endtask : post_body


endclass: spi_base_seq



// Master sequence class
class spi_master_seq extends spi_base_seq;

    // Constructor
    function new(string name = "spi_master_seq");
        super.new(name);
    endfunction


    // UVM automation macros for sequences
    `uvm_object_utils(spi_master_seq)


    // The body() task is the actual logic of the sequence
    virtual task body();
        `uvm_do(req)
    endtask: body
    
    
endclass:spi_master_seq



// Write sequence class
class spi_write_seq extends spi_base_seq;

    rand logic [`MAX_DATA_WIDTH : 0] mosi_data;

    // Constructor
    function new(string name = "spi_write_seq");
        super.new(name);
    endfunction

    
    // UVM automation macros for sequences  
    `uvm_object_utils(spi_write_seq)

    
    // The body() task is the actual logic of the sequence.
    virtual task body();
        `uvm_do_with(req, {req.mosi_data == mosi_data;}) 
    endtask: body


endclass:spi_write_seq



// Slave sequence class
class spi_slave_seq extends spi_base_seq;

    // Constructor
    function new(string name = "spi_slave_seq");
        super.new(name);
    endfunction


    // UVM automation macros for sequences
    `uvm_object_utils(spi_slave_seq)


    // The body() task is the actual logic of the sequence
    virtual task body();
        `uvm_do(req)
    endtask: body

endclass : spi_slave_seq


/*
 
// Reset on the fly sequence class
class spi_reset_seq extends spi_base_seq;

    // Status - used to signal reset status
    uvm_tlm_response_status_e status;

    // Constructor
    function new(string name = "spi_reset_seq");
        super.new(name);
    endfunction


    // UVM automation macros for sequences
    `uvm_object_utils(spi_reset_seq)


    // The body() task is the actual logic of the sequence
    virtual task body();
        req = spi_data_item::type_id::create("req");
	
	start_item(req);
	
	if(!req.randomize()) 
            `uvm_error("body", "req randomization failure")
	    
        finish_item(req);
	
	status = req.status;
	
	if(status == UVM_TLM_INCOMPLETE_RESPONSE) begin
            `uvm_warning("Sequence body", "Interface reset occurred!");
             return;
        end
	
    endtask: body

endclass : spi_reset_seq

*/    
    


