class spi_data_item extends uvm_sequence_item;

    // Fields associated with transaction
    rand logic [`MAX_DATA_WIDTH  : 0] mosi_data;
    rand logic [`MAX_DATA_WIDTH  : 0] miso_data;

 
    // Factory registration and automatic implementations of core methods
    `uvm_object_utils_begin(spi_data_item)
        `uvm_field_int(mosi_data, UVM_ALL_ON)
        `uvm_field_int(miso_data, UVM_ALL_ON)
    `uvm_object_utils_end
    

    // Constructor
    function new (string name = "spi_data_item");
        super.new(name);
    endfunction : new


endclass : spi_data_item
