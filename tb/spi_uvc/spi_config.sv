class spi_config extends uvm_object;	
	
    // Configurable fields
    rand int unsigned ss_line;
    rand bit lsb_first;
    rand bit [0 : 6] char_len;
    rand trans_type_t trans_type;  
    rand int clk_divider;
    
        
    // Constraints
    constraint c_ss_line{soft ss_line inside {[0 : `SS_MAX]}; }
    constraint c_char_len{soft char_len inside {[1 : `MAX_DATA_WIDTH]}; }
    constraint c_clk_divider{soft clk_divider inside {[2 : 15]}; }
    

    // Factory registration and automatic implementations of core methods
    `uvm_object_utils_begin(spi_config)
        `uvm_field_int(ss_line, UVM_ALL_ON)
	`uvm_field_int(lsb_first, UVM_ALL_ON)
	`uvm_field_int(char_len, UVM_ALL_ON)
	`uvm_field_int(clk_divider, UVM_ALL_ON)
	`uvm_field_enum(trans_type_t ,trans_type, UVM_ALL_ON)
    `uvm_object_utils_end
	
	
    // Constructor
    function new(string name = "spi_config");
        super.new(name);
    endfunction : new

	
endclass : spi_config
