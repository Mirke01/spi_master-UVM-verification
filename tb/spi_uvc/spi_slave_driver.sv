class spi_slave_driver extends uvm_driver#(spi_data_item);

    // Factory registration
    `uvm_component_utils(spi_slave_driver)


     
     // Slave_driver fields
     virtual spi_interface vif;
     spi_data_item req_item;
     spi_config cfg;
    
    
    
    // Constructor
    function new(string name = "spi_slave_driver", uvm_component parent = null);
        super.new(name, parent);    
    endfunction : new
  
  

     // Build phase
    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
	
	 if(!uvm_config_db#(virtual spi_interface)::get(this, "", "vif", vif))
             `uvm_fatal("NOVIF",{"virtual interface must be set for: ", get_full_name(), ".vif"})
	    
	 if(!uvm_config_db#(spi_config)::get(this, "", "cfg", cfg)) 
      	     `uvm_fatal(get_full_name(), "Failed to get config object")
   
    endfunction : build_phase
    


    // Run phase
    task run_phase(uvm_phase phase);    
        wait (vif.rst == 1);
        @(posedge vif.clk);
        reset_signals();
        @(negedge vif.rst);
        @(posedge vif.clk);
	    
	forever begin	
            fork
	        begin
                    seq_item_port.get_next_item(req_item);    
                    drive_tr();
                    seq_item_port.item_done();
                end
		
                begin
                    @(posedge vif.rst);
                    seq_item_port.item_done();
                    @(posedge vif.clk);
                    reset_signals();
                    //req = null;	
                end
            join_any
	    
	    disable fork;
	    wait(vif.rst == 1'b0);
	end
    endtask : run_phase
  
  

    // Task for driving miso data
    task drive_tr();
        wait(vif.ss_pad_o != 'hFF);         // One slave needs to be active. Only than it can transport data on miso
	 
	 void'(begin_tr(req_item, "spi_slave_driver", 0));
	 
	//MODE 1 or MODE 3/ MSB 1st -> slave toggles miso at rising edge. Slave should sample mosi on rising(mode 1) or falling(mode 3) edge. Transfer MSB first
        if(!cfg.lsb_first) begin
	    if (cfg.trans_type == NEG_MOSI_POS_MISO || cfg.trans_type == POS_MOSI_POS_MISO) begin
	        @(posedge vif.sclk_pad_o);
                for(int i = cfg.char_len - 1; i > 0; i--) begin
		    vif.miso_pad_i <= req_item.miso_data[i];
                    @(posedge vif.sclk_pad_o);
	        end
	//MODE 0 or MODE 2/ MSB 1st -> slave toggles miso at falling edge. Slave should sample mosi on rising(mode 0) or falling(mode 2) edge. Transfer MSB first  
	    end else if(cfg.trans_type == NEG_MOSI_NEG_MISO || cfg.trans_type == POS_MOSI_NEG_MISO) begin
	        for(int i = cfg.char_len; i > 0; i--) begin
                    @(negedge vif.sclk_pad_o);
	            vif.miso_pad_i <= req_item.miso_data[i];
	        end
	    end
        end else begin
	//MODE 1 or MODE 3/ LSB 1st -> slave toggles miso at rising edge. Slave should sample mosi on rising(mode 1) or falling(mode 3) edge. Transfer LSB first
	    if (cfg.trans_type == NEG_MOSI_POS_MISO || cfg.trans_type == POS_MOSI_POS_MISO) begin
	        @(posedge vif.sclk_pad_o);
                for(int i = 0; i < cfg.char_len - 1; i++) begin
		    vif.miso_pad_i <= req_item.miso_data[i];
		    @(posedge vif.sclk_pad_o);
	        end
	//MODE 0 or MODE 2/ LSB 1st -> slave toggles miso at falling edge. Slave should sample mosi on rising(mode 0) or falling(mode 2) edge. Transfer LSB first  
	    end else if(cfg.trans_type == NEG_MOSI_NEG_MISO || cfg.trans_type == POS_MOSI_NEG_MISO) begin
	        for(int i = 0; i < cfg.char_len; i++) begin
                    @(negedge vif.sclk_pad_o);
	            vif.miso_pad_i <= req_item.miso_data[i];
	        end
	    end
	end
	
	end_tr(req_item, 0, 1);
    endtask : drive_tr



    // Task for reseting signals 
    task reset_signals();
        vif.miso_pad_i <= 1'bx;
    endtask : reset_signals
    
    
    
    // reset_and_suspend task
    task reset_and_suspend();
        if(vif.rst)
            vif.miso_pad_i <= 1'bx;
    endtask : reset_and_suspend
    
    
endclass : spi_slave_driver
