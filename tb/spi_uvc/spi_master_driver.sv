class spi_master_driver extends uvm_driver#(spi_data_item);
    
    // Factory registration
    `uvm_component_utils(spi_master_driver)
    
    
    // Master_driver fields
    virtual spi_interface vif;
    spi_config cfg;
    spi_data_item req_item;
    
    
    // Constructor
    function new(string name = "spi_master_driver", uvm_component parent); 
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
        wait (vif.rst == 1'b1); 
        @(posedge vif.clk);
        reset_signals();
        @(negedge vif.rst); 
        @(posedge vif.clk);
                        
        forever begin
            fork
                drive_sclk();
		
		begin
	            seq_item_port.get_next_item(req_item);
	            drive_trans();
	            seq_item_port.item_done();
		end
		
                begin
                     @(posedge vif.rst);
                     seq_item_port.item_done();
                     @(posedge vif.clk);
                     reset_signals();		
                end
	    join_any
	    
	    disable fork;
            wait(vif.rst == 1'b0);
	end
    endtask : run_phase



    // Task for driving slave lines and mosi data
    task drive_trans();
        void'(begin_tr(req_item, "spi_master_driver", 0)); 
                         
        foreach(vif.ss_pad_o[i]) begin
            if(i == cfg.ss_line)
                vif.ss_pad_o[i] <= 1'b0;      // Slave #i is activated on '0'
            else
                vif.ss_pad_o[i] <= 1'b1;
         end 
	
        //MODE 2 or MODE 3/ MSB 1st -> master toggles mosi at rising edge. Master should sample miso on rising(mode 2) or falling(mode 3) edge. Transfer MSB first
        if(!cfg.lsb_first) begin  
	    if (cfg.trans_type == POS_MOSI_NEG_MISO || cfg.trans_type == POS_MOSI_POS_MISO) begin  
	        @(posedge vif.sclk_pad_o);
                for(int i = cfg.char_len; i > 0; i--) begin   
		    vif.mosi_pad_o <= req_item.mosi_data[i];
		    @(posedge vif.sclk_pad_o);       
	        end
	//MODE 0 or MODE 1/ MSB 1st -> master toggles mosi at falling edge. Master should sample miso on rising(mode 0) or falling(mode 1) edge. Transfer MSB first  
	    end else if(cfg.trans_type == NEG_MOSI_NEG_MISO || cfg.trans_type == NEG_MOSI_POS_MISO) begin 
	        @(negedge vif.sclk_pad_o);
	        for(int i = cfg.char_len - 1; i > 0; i--) begin  
                    //@(negedge vif.sclk_pad_o);
	            vif.mosi_pad_o <= req_item.mosi_data[i];
                    @(negedge vif.sclk_pad_o);
	        end 
	    end   
        end else begin
	//MODE 2 or MODE 3/ LSB 1st -> master toggles mosi at rising edge. Master should sample miso on rising(mode 2) or falling(mode 3) edge. Transfer LSB first
	    if (cfg.trans_type == POS_MOSI_NEG_MISO || cfg.trans_type == POS_MOSI_POS_MISO) begin
	        @(posedge vif.sclk_pad_o);
                for(int i = 0; i < cfg.char_len; i++) begin
		    vif.mosi_pad_o <= req_item.mosi_data[i];
		    @(posedge vif.sclk_pad_o);
	        end
	//MODE 0 or MODE 1/ LSB 1st -> master toggles mosi at falling edge. Master should sample miso on rising(mode 0) or falling(mode 1) edge. Transfer LSB first  
	    end else if(cfg.trans_type == NEG_MOSI_POS_MISO || cfg.trans_type == NEG_MOSI_NEG_MISO) begin
	        @(negedge vif.sclk_pad_o);
	        for(int i = 0; i < cfg.char_len - 1; i++) begin
                    //@(negedge vif.sclk_pad_o);
	            vif.mosi_pad_o <= req_item.mosi_data[i];
                    @(negedge vif.sclk_pad_o);
	        end
	    end
	end
	
	//@(posedge vif.clk);
	vif.sclk_pad_o = 1'b0;
	vif.ss_pad_o <= 'hFF; 
	
	end_tr(req_item, 0, 1);
    endtask : drive_trans



    // Task for reseting signals
    task reset_signals();
        vif.ss_pad_o <= 'hFF;
        vif.mosi_pad_o <= 1'bx;
        vif.sclk_pad_o <= 1'b0;
    endtask : reset_signals
    
    

    // Task for driving spi clk
    task drive_sclk();
        int divider_tclk = 0;
	
	
	divider_tclk = (cfg.clk_divider + 1) * 2;
	
	wait(vif.ss_pad_o != 8'hFF );
	
	repeat(divider_tclk / 2) @(posedge vif.clk);
	    
	
        forever begin
	    if(vif.ss_pad_o == 8'hFF)                                  // "Turn of" the sclk when the transaction is over(exit forever loop) 
 	        return;
	
            vif.sclk_pad_o <= 1'b1;
	    repeat(divider_tclk / 2) @(posedge vif.clk);                // Wait for half sclk period
            vif.sclk_pad_o <= 1'b0;
	    repeat(divider_tclk / 2) @(posedge vif.clk);
	end
    endtask : drive_sclk
    
    
    
    // reset_and_suspend task
    task reset_and_suspend();
        if(vif.rst) begin
            vif.ss_pad_o <= 'hFF;
            vif.mosi_pad_o <= 1'bx;
            vif.sclk_pad_o <= 1'b0;
        end
    endtask : reset_and_suspend

endclass : spi_master_driver
