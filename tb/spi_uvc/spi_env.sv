class spi_env extends uvm_env;

    // Factory registration
    `uvm_component_utils(spi_env)
    
   
    // Environment fields
    spi_agent master_agent;
    spi_agent slave_agent;
    spi_config cfg;
    
    
    // Constructor
    function new(string name = "spi_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new
    
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	
	if(!uvm_config_db #(spi_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("spi_env - build_phase", "Unable to get configuration object for environment ");
	end 
	
        uvm_config_db#(int)::set(this, "master_agent", "is_master", 1);
        uvm_config_db#(int)::set(this, "slave_agent", "is_master", 0);
	
        uvm_config_db#(int)::set(this, "master_agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(int)::set(this, "slave_agent", "is_active", UVM_ACTIVE);
	
	master_agent = spi_agent::type_id::create("master_agent", this);
	
        slave_agent = spi_agent::type_id::create("slave_agent", this);
    endfunction : build_phase
    
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
	//empty -> no scoreboard, no coverage
    endfunction : connect_phase
    
     
endclass : spi_env



