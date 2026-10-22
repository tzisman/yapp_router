class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    router_tb tb;

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_int::set(this, "*", "recording_detail", 1);
      tb = router_tb::type_id::create("tb", this);
      `uvm_info("BASE_TB", "Build phase executed successfully", UVM_HIGH)

      // uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
      //                   "default_sequence",
      //                   yapp_5_packets::get_type());
    endfunction : build_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction :end_of_elaboration_phase

    virtual task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection();
        obj.set_drain_time (this, 200ns);
    endtask
    virtual function void check_phase(uvm_phase phase);
      super.check_phase(phase);
      check_config_usage();
    endfunction

endclass: base_test

class simple_test extends base_test;

  `uvm_component_utils(simple_test)


  function new(string name = "simple_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);

    yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());

    uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_012_seq::get_type());

    uvm_config_wrapper::set(this, "tb.channel*.rx_agent.sequencer.run_phase",
                            "default_sequence",
                            channel_rx_resp_seq::get_type());

    uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                            "default_sequence",
                            clk10_rst5_seq::get_type());
    super.build_phase(phase);

  endfunction
endclass


class router_mcseq_test extends base_test;
  `uvm_component_utils(router_mcseq_test)

  function new(string name = "router_mcseq_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);

    //set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());
    uvm_config_wrapper::set(this, "tb.channel*.rx_agent.sequencer.run_phase",
                           "default_sequence",
                           channel_rx_resp_seq::get_type());

    uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                           "default_sequence",
                           clk10_rst5_seq::get_type());

    uvm_config_wrapper::set(this, "tb.mcseqr.run_phase",
                           "default_sequence",
                           router_simple_mcseq::get_type());

    super.build_phase(phase);
    
  endfunction

endclass : router_mcseq_test

