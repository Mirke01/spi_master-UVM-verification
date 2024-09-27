class spi_agent extends uvm_agent;


    // Agent fields
    spi_sequencer sqr;
    spi_monitor mon;
    spi_slave_driver s_drv;
    spi_master_driver m_drv;
    spi_config cfg;
    bit is_master;
    uvm_active_passive_enum is_active;

    
    
    // Factory registration and automatic implementations of core methods
    `uvm_component_utils_begin(spi_agent)
        `uvm_field_int(is_master, UVM_ALL_ON)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_component_utils_end
    

    
    // Constructor
    function new(string name = "spi_agent", uvm_component parent);
        super.new(name, parent);
    endfunction : new   
    

    
    // Agent build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase); 
	
	uvm_config_db#(spi_config)::set(this, "", "cfg" , cfg);
	
	if(is_active == UVM_ACTIVE) begin
	    if(is_master)
	        m_drv = spi_master_driver::type_id::create("m_drv", this);
            else
	        s_drv = spi_slave_driver::type_id::create("s_drv", this);
		
	    sqr = spi_sequencer::type_id::create("sqr", this);
	end
	
	mon = spi_monitor::type_id::create("mon", this);
	
    endfunction : build_phase



    // Agent connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
	
	if(is_active == UVM_ACTIVE) begin
	    if(is_master)
	        m_drv.seq_item_port.connect(sqr.seq_item_export);
            else
	        s_drv.seq_item_port.connect(sqr.seq_item_export);
	end
	
    endfunction : connect_phase

endclass : spi_agent
