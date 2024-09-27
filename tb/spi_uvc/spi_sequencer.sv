class spi_sequencer extends uvm_sequencer#(spi_data_item);

    // Factory registration
    `uvm_component_utils (spi_sequencer)
    
    
    // Virtual interface
    virtual spi_interface vif;
    
	
    // Constructor
    function new(string name = "spi_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction : new
	
	
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	
        if(!uvm_config_db#(virtual spi_interface)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ", get_full_name(), ".vif"}); 
	    
    endfunction : build_phase 


endclass : spi_sequencer
