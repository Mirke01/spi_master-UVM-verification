class spi_monitor extends uvm_monitor;

    // Factory registratiom
    `uvm_component_utils(spi_monitor)



    // Monitor fields
    virtual spi_interface vif;
    spi_config cfg;
    uvm_analysis_port #(spi_data_item) analysis_port_collected;
    protected spi_data_item data_item;



    // Coverage
    covergroup cg;
        spi_protocol_modes : coverpoint cfg.trans_type {
            bins mode_zero = {NEG_MOSI_NEG_MISO};
            bins mode_one = {NEG_MOSI_POS_MISO};
            bins mode_two = {POS_MOSI_NEG_MISO};
            bins mode_three = {POS_MOSI_POS_MISO};
        }
        lsb_or_msb_first : coverpoint cfg.lsb_first {
            bins b0 = {1'b0};
            bins b1 = {1'b1};
        }
        slaves_active : coverpoint cfg.ss_line {
            bins b0 = {0};
            bins b1 = {1};
            bins b2 = {2};
            bins b3 = {3};
            bins b4 = {4};
            bins b5 = {5};
            bins b6 = {6};
            bins b7 = {7};
        }
        periods_number_of_sclk : coverpoint cfg.char_len {
            bins LOW = {[1 : (`MAX_DATA_WIDTH / 3 - 1)]};
            bins MEDIUM = {[(`MAX_DATA_WIDTH / 3) : (`MAX_DATA_WIDTH - (`MAX_DATA_WIDTH / 3 - 1))]};
            bins HIGH = {[(`MAX_DATA_WIDTH / 3) : `MAX_DATA_WIDTH]};
        }
        cross cfg.trans_type, cfg.lsb_first;
        cross cfg.trans_type, cfg.ss_line;
        cross cfg.trans_type, cfg.char_len;
    endgroup
        


    // Constructor
    function new(string name = "spi_slave_monitor", uvm_component parent = null);
        super.new(name, parent);
        analysis_port_collected = new("analysis_port_collected", this);
	      
        // Coverage group instance
        cg = new();
    endfunction : new
    



    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual spi_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ", get_full_name(), ".vif"})
        end

        if(!uvm_config_db#(spi_config)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal(get_full_name(), "Failed to get config object")
        end
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
	        begin
                    spi_sample_tr();                      
                end
                begin
                    @(posedge vif.rst);
		    @(posedge vif.clk);
                end
	     join_any
	     
             disable fork;
             wait(vif.rst == 1'b0);
        end
    endtask : run_phase                                 
                
                 
             
    // Task for monitoring slave's sampling of the mosi and master's sampling of the miso
    task spi_sample_tr();
        spi_data_item data_item;
        data_item = spi_data_item::type_id::create("data_item", this);
	
        case(cfg.trans_type)
        NEG_MOSI_NEG_MISO :
            $display("MONITOR ENTERED MODE ZERO @ %t", $time);
        NEG_MOSI_POS_MISO :
            $display("MONITOR ENTERED MODE ONE @ %t", $time);
        POS_MOSI_NEG_MISO :
            $display("MONITOR ENTERED MODE TWO @ %t", $time);
        POS_MOSI_POS_MISO :
            $display("MONITOR ENTERED MODE THREE @ %t", $time);
        endcase
                                                                        		 
        if(!cfg.lsb_first) begin
            for(int i = cfg.char_len - 1; i >= 0; i--) begin
                case(cfg.trans_type)
                    NEG_MOSI_NEG_MISO : begin
                        @(posedge vif.sclk_pad_o);
                        data_item.miso_data[i] = vif.miso_pad_i;
                        data_item.mosi_data[i] = vif.mosi_pad_o;
                                                		    
                        $display("value of mosi_data[%0d] = %b, sclk period is %0d", i,  data_item.mosi_data[i], cfg.char_len - 1 - i);
                        $display("value of miso_data[%0d] = %b, sclk period is %0d", i,  data_item.miso_data[i], cfg.char_len - 1 - i);
                    end
                                                                  
                    NEG_MOSI_POS_MISO : begin  
                        @(posedge vif.sclk_pad_o);
                        data_item.mosi_data[i] = vif.mosi_pad_o;
                        @(negedge vif.sclk_pad_o);
                        data_item.miso_data[i] = vif.miso_pad_i;
		    
                        $display("value of mosi_data[%0d] = %b, sclk period is %0d", i,  data_item.mosi_data[i], cfg.char_len - 1 - i);
                        $display("value of miso_data[%0d] = %b, sclk period is %0d", i,  data_item.miso_data[i], cfg.char_len - 1 - i);
                    end
                                          		    
                    POS_MOSI_NEG_MISO : begin
                        @(posedge vif.sclk_pad_o);
                        data_item.miso_data[i] = vif.miso_pad_i;
                        @(negedge vif.sclk_pad_o);
                        data_item.mosi_data[i] = vif.mosi_pad_o;
                                             		    
                        $display("value of mosi_data[%0d] = %b, sclk period is %0d", i,  data_item.mosi_data[i], cfg.char_len - 1 - i);
                        $display("value of miso_data[%0d] = %b, sclk period is %0d", i,  data_item.miso_data[i], cfg.char_len - 1 - i);
                    end		    
                                                     		    
                    POS_MOSI_POS_MISO : begin    
                        @(negedge vif.sclk_pad_o);
                        data_item.miso_data[i] = vif.miso_pad_i;
                        data_item.mosi_data[i] = vif.mosi_pad_o;
                                                                   		    
                        $display("value of mosi_data[%0d] = %b, sclk period is %0d", i,  data_item.mosi_data[i], cfg.char_len - 1 - i);
                        $display("value of miso_data[%0d] = %b, sclk period is %0d", i,  data_item.miso_data[i], cfg.char_len - 1 - i);
                    end
		endcase
            end 
	    
        end else begin
            for(int i = 0; i <= cfg.char_len - 1; i++) begin
                case(cfg.trans_type)
                    NEG_MOSI_NEG_MISO : begin  
                        @(posedge vif.sclk_pad_o);
                        data_item.miso_data[i] = vif.miso_pad_i;
                        data_item.mosi_data[i] = vif.mosi_pad_o;
		    
                        $display("value of mosi_data[%0d] = %b, sclk period is %0d", i,  data_item.mosi_data[i], i);
                        $display("value of miso_data[%0d] = %b, sclk period is %0d", i,  data_item.miso_data[i], i);
                    end
                
                    NEG_MOSI_POS_MISO : begin
                        @(posedge vif.sclk_pad_o);
                        data_item.mosi_data[i] = vif.mosi_pad_o;
                        @(negedge vif.sclk_pad_o);
                        data_item.miso_data[i] = vif.miso_pad_i;
		    
                        $display("value of mosi_data[%0d] = %b, sclk period is %0d", i,  data_item.mosi_data[i], i);
                        $display("value of miso_data[%0d] = %b, sclk period is %0d", i,  data_item.miso_data[i], i);
                    end
		    
                    POS_MOSI_NEG_MISO : begin
                        @(posedge vif.sclk_pad_o);
                        data_item.miso_data[i] = vif.miso_pad_i;
                        @(negedge vif.sclk_pad_o);
                        data_item.mosi_data[i] = vif.mosi_pad_o;
		    
                        $display("value of mosi_data[%0d] = %b, sclk period is %0d", i,  data_item.mosi_data[i], i);
                        $display("value of miso_data[%0d] = %b, sclk period is %0d", i,  data_item.miso_data[i], i);
                    end		    
		    
                    POS_MOSI_POS_MISO : begin   
                        @(negedge vif.sclk_pad_o);
                        data_item.miso_data[i] = vif.miso_pad_i;
                        data_item.mosi_data[i] = vif.mosi_pad_o;
		    
                        $display("value of mosi_data[%0d] = %b, sclk period is %0d", i,  data_item.mosi_data[i], i);
                        $display("value of miso_data[%0d] = %b, sclk period is %0d", i,  data_item.miso_data[i], i);
                    end
		endcase
            end
        end 
	cg.sample();
        analysis_port_collected.write(data_item);
        $display("DATA SENT VIA ANALYSIS PORT @ %t", $time);
    endtask : spi_sample_tr
    
    
    // Task for reseting data signals
    task reset_signals();
        vif.mosi_pad_o <= 1'bx;
        vif.miso_pad_i <= 1'bx;
    endtask : reset_signals



     // reset_and_suspend task
    task reset_and_suspend();
        if(vif.rst) begin
            vif.mosi_pad_o <= 1'bx;
            vif.miso_pad_i <= 1'bx;
        end
    endtask : reset_and_suspend


endclass : spi_monitor
