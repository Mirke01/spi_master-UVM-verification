class wb_master_monitor extends uvm_monitor;
  
  `uvm_component_utils(wb_master_monitor)
  
  virtual wb_if vif;
  uvm_analysis_port #(wb_seq_item) monitor_analysis_port;
  wb_seq_item item;
  int ack_counter = 0;
  int init_delay_counter = 0;
  int final_delay_counter = 0;
  int wsm_counter = 0;
  int wss_counter = 0;
  
  covergroup wb_single_read_cg;
    option.comment = "WB SINGLE READ coverage group";
    option.per_instance = 1;
    ADDR: coverpoint item.addr[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    DATA: coverpoint item.data[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    SEL: coverpoint item.sel[ack_counter] {
         bins low_range = {[0:'h3F]};
         bins mid_range1 = {['h40:'h7F]};
         bins mid_range2 = {['h80:'hBF]};
         bins high_range = {['hC0:'hFF]};
    }
    TRANS_TYPE: coverpoint item.trans_type {
         bins single_read = SINGLE_RD;
    }  
    SEL_x_DATA: cross SEL,DATA;
    SEL_x_ADDR: cross SEL,ADDR;
  endgroup
    
  covergroup wb_single_write_cg;
    option.comment = "WB SINGLE WRITE coverage group";
    option.per_instance = 1;
    ADDR: coverpoint item.addr[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    DATA: coverpoint item.data[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    SEL: coverpoint item.sel[ack_counter] {
         bins low_range = {[0:'h3F]};
         bins mid_range1 = {['h40:'h7F]};
         bins mid_range2 = {['h80:'hBF]};
         bins high_range = {['hC0:'hFF]};
    }
    TRANS_TYPE: coverpoint item.trans_type {
         bins single_write = SINGLE_WR;
    }
    SEL_x_DATA: cross SEL,DATA;
    SEL_x_ADDR: cross SEL,ADDR;
  endgroup
  
  covergroup wb_block_read_cg;
    option.comment = "WB BLOCK READ coverage group";
    option.per_instance = 1;
    ADDR: coverpoint item.addr[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    DATA: coverpoint item.data[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    SEL: coverpoint item.sel[ack_counter] {
         bins low_range = {[0:'h3F]};
         bins mid_range1 = {['h40:'h7F]};
         bins mid_range2 = {['h80:'hBF]};
         bins high_range = {['hC0:'hFF]};
    }
    TRANS_TYPE: coverpoint item.trans_type {
         bins block_read = BLOCK_RD;
    }
    SEL_x_DATA: cross SEL,DATA;
    SEL_x_ADDR: cross SEL,ADDR;
  endgroup
    
  covergroup wb_block_write_cg;
    option.comment = "WB BLOCK WRITE coverage group";
    option.per_instance = 1;
    ADDR: coverpoint item.addr[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    DATA: coverpoint item.data[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    SEL: coverpoint item.sel[ack_counter] {
         bins low_range = {[0:'h3F]};
         bins mid_range1 = {['h40:'h7F]};
         bins mid_range2 = {['h80:'hBF]};
         bins high_range = {['hC0:'hFF]};
    }
    TRANS_TYPE: coverpoint item.trans_type {
         bins block_write = BLOCK_WR;
    }
    SEL_x_DATA: cross SEL,DATA;
    SEL_x_ADDR: cross SEL,ADDR;
  endgroup
      
  covergroup wb_rmw_cg;
    option.comment = "WB RMW coverage group";
    option.per_instance = 1;
    ADDR: coverpoint item.addr[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    DATA: coverpoint item.data[ack_counter] {
          bins min_range  = {[0:'h1FFF_FFFF_FFFF_FFFF]};
          bins mid_range1 = {['h2000_0000_0000_0000:'h3FFF_FFFF_FFFF_FFFF]};
          bins mid_range2 = {['h4000_0000_0000_0000:'h5FFF_FFFF_FFFF_FFFF]};
          bins mid_range3 = {['h6000_0000_0000_0000:'h7FFF_FFFF_FFFF_FFFF]};
          bins mid_range4 = {['h8000_0000_0000_0000:'h9FFF_FFFF_FFFF_FFFF]};
          bins mid_range5 = {['hA000_0000_0000_0000:'hBFFF_FFFF_FFFF_FFFF]};
          bins mid_range6 = {['hC000_0000_0000_0000:'hDFFF_FFFF_FFFF_FFFF]};
          bins max_range  = {['hE000_0000_0000_0000:'hFFFF_FFFF_FFFF_FFFF]};
    }
    SEL: coverpoint item.sel[ack_counter] {
         bins low_range = {[0:'h3F]};
         bins mid_range1 = {['h40:'h7F]};
         bins mid_range2 = {['h80:'hBF]};
         bins high_range = {['hC0:'hFF]};
    }
    TRANS_TYPE: coverpoint item.trans_type {
         bins rmw = RMW;
    }
    SEL_x_DATA: cross SEL,DATA;
    SEL_x_ADDR: cross SEL,ADDR;
  endgroup
  
  function new(string name = "wb_master_monitor", uvm_component parent=null);
    super.new(name,parent);
     wb_single_read_cg = new();
     wb_single_write_cg = new();
     wb_block_read_cg = new();
     wb_block_write_cg = new();
     wb_rmw_cg = new();  
     wb_single_read_cg.set_inst_name("wb_single_read_cg");
     wb_single_write_cg.set_inst_name("wb_single_write_cg");
     wb_block_read_cg.set_inst_name("wb_block_read_cg");
     wb_block_write_cg.set_inst_name("wb_block_write_cg");
     wb_rmw_cg.set_inst_name("wb_rmw_cg");
    monitor_analysis_port = new("monitor_analysis_port", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual wb_if)::get(this, "", "vif", vif))
         `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"}); 
  endfunction

   task collect_item(); //task for collecting information from vif and putting it in item
       @(posedge vif.ack iff vif.ack == 1); //collects every time ack is asserted
       if(vif.we == 0)begin //block for read type of cycles
         item.addr[ack_counter] = vif.addr;
         item.data[ack_counter] = vif.data_rd;
         item.sel[ack_counter]  = vif.sel;
         wb_single_read_cg.sample();
         wb_block_read_cg.sample();
         wb_rmw_cg.sample();
       end
       else if (vif.we == 1)begin //block for write type of cycles
         item.addr[ack_counter] = vif.addr;
         item.data[ack_counter] = vif.data_wr;
         item.sel[ack_counter]  = vif.sel;
         wb_single_write_cg.sample();
         wb_block_write_cg.sample();
         wb_rmw_cg.sample();
       end
       ack_counter++; //ack_counter increments every time an assertion of ack has happened, so that we have an item for every ack that has happened in order to collect different values of data, addr, sel
       if(ack_counter == 1 && vif.we == 0)begin //condition for single read trans type
         item.trans_type = SINGLE_RD;
         wb_single_read_cg.sample();
       end
       else if(ack_counter == 1 && vif.we == 1)begin //condition for single write trans type(trans_number constrained to 1 in wb_seq_item)
         item.trans_type = SINGLE_WR;
         wb_single_write_cg.sample();
       end
       else if(ack_counter == 2)begin //condition for rmw trans type(trans_number constrained to 2 in wb_seq_item)
         item.trans_type = RMW;
         wb_rmw_cg.sample();
       end
       else if(ack_counter > 2 && vif.we == 0)begin //condition for block read trans type(trans_number constrained to 2 in wb_seq_item)
         item.trans_type = BLOCK_RD;
         wb_block_read_cg.sample();
       end
       else if(ack_counter > 2 && vif.we == 1)begin //condition for block write trans type(trans_number constrained to 2 in wb_seq_item)
         item.trans_type = BLOCK_WR; 
         wb_block_write_cg.sample();
       end
       item.print(); //printing everything put into an item during one ack assertion, and printing it for every ack increment     
   endtask
   
  virtual task collect_transactions(uvm_phase phase); //task for creating item object and fork joining collecting item
     item = wb_seq_item::type_id::create("item",this);
     forever begin
       fork 
          collect_item();
       join //exits the fork only when all of the tasks within fork have executed
     end 
  endtask   
   //TODO:to review or change    
  task collect_delays(uvm_phase phase);
    @(posedge vif.clk iff vif.rst == 0)begin
     if(vif.cyc == 1)begin
       if(vif.addr === 'x)begin
         wsm_counter++;
         `uvm_info("UVM_INFO", $sformatf("wsm_counter is %0d",wsm_counter), UVM_NONE)
       end
       else if(vif.stb == 1 && vif.ack == 0)begin
         wss_counter++;
        `uvm_info("UVM_INFO", $sformatf("wss_counter is %0d",wss_counter), UVM_NONE)
       end
       else if(vif.ack == 0)begin
         final_delay_counter++;
         `uvm_info("UVM_INFO", $sformatf("final_delay_counter is %0d",final_delay_counter), UVM_NONE)
       end
     end
     else begin
       init_delay_counter++; //keeps counting during reset operation after data transfer, should be reseted 
      `uvm_info("UVM_INFO", $sformatf("init_delay_counter is %0d",init_delay_counter), UVM_NONE)
     end
    end
  endtask

  task run_phase(uvm_phase phase);
      forever begin
        collect_delays(phase); //WORKS SOLO
        @(posedge vif.clk iff !vif.rst);
        collect_transactions(phase);
      end
  endtask
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass
