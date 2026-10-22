class yapp_monitor extends uvm_monitor;
    `uvm_component_utils(yapp_monitor)

    virtual interface yapp_if vif;
    yapp_packet pkt;
    int num_pkt_col;

    uvm_analysis_port #(yapp_packet) pkt_col_port;

  covergroup yapp_mngr_cov;
    cp_length: coverpoint pkt.length {
        bins length_min    = {1};
        bins length_small  = {[2:10]};
        bins length_medium = {[11:40]};
        bins length_large  = {[41:62]};
        bins length_max    = {63};
    }

    cp_addr: coverpoint pkt.addr {
      bins legal_addrs[] = {[0:2]};
      bins illegal_addr  = {3};
    }

    cp_parity_error: coverpoint pkt.parity_type {
      bins error    = {0};
      bins no_error = {1};
    }

    length_addr_parity_cross:
      cross cp_length, cp_addr, cp_parity_error {
        ignore_bins illegal_addr = binsof(cp_addr.illegal_addr);

        ignore_bins good_parity =
          binsof(cp_parity_error.no_error);
        }
endgroup : yapp_mngr_cov

    function new(string name, uvm_component parent);
        super.new(name, parent);
        pkt_col_port = new("pkt_col_port", this);
        yapp_mngr_cov = new();
    endfunction

    virtual function void connect_phase(uvm_phase phase);        
        if (!yapp_vif_config :: get (this,"","vif", vif))
            `uvm_error ("NOVIF", "vif not set")
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
        `uvm_info("YAPP_MONITOR", "you are in the monitor", UVM_LOW);

        @(posedge vif.reset)
        @(negedge vif.reset)
        `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
        forever begin 
          pkt = yapp_packet::type_id::create("pkt", this);

          fork
            vif.collect_packet(pkt.length, pkt.addr, pkt.payload, pkt.parity);
            @(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_YAPP_Packet"));
          join

          pkt.parity_type = (pkt.parity == pkt.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
          end_tr(pkt);
          `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW)
          pkt_col_port.write(pkt);
          yapp_mngr_cov.sample();
          num_pkt_col++;
        end
    endtask : run_phase

    function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      `uvm_info(get_type_name(), "Entering start_of_simulation_phase", UVM_LOW)
    endfunction


    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction : report_phase

endclass