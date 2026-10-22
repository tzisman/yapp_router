class router_tb extends uvm_env;

    `uvm_component_utils(router_tb)

    yapp_env yapp;
    channel_env channel0;
    channel_env channel1;
    channel_env channel2;
    hbus_env hbus;
    clock_and_reset_env clock_and_reset;
    router_mcsequencer mcseqr;
    router_module_env router_mod_env;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("ROUTER_TB", "Build phase executed successfully", UVM_HIGH)

        uvm_config_int::set (this, "channel0", "channel_id", 0);
        uvm_config_int::set (this, "channel1", "channel_id", 1);
        uvm_config_int::set (this, "channel2", "channel_id", 2);
        uvm_config_int::set(this, "hbus", "num_masters", 1);
        uvm_config_int::set(this, "hbus", "num_slaves", 0);

        yapp = yapp_env::type_id::create("yapp", this);
        channel0 = channel_env::type_id::create("channel0", this);
        channel1 = channel_env::type_id::create("channel1", this);
        channel2 = channel_env::type_id::create("channel2", this);
        hbus = hbus_env::type_id::create("hbus", this);
        clock_and_reset = clock_and_reset_env::type_id::create("clock_and_reset", this);
        mcseqr = router_mcsequencer::type_id::create("mcseqr",this);
        router_mod_env = router_module_env::type_id::create("router_mod_env", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        mcseqr.hbus_seqr = hbus.masters[0].sequencer;
        mcseqr.yapp_seqr = yapp.agent.sequencer;

        yapp.agent.monitor.pkt_col_port.connect(router_mod_env.router_reference.yapp_in);
        channel0.rx_agent.monitor.item_collected_port.connect(router_mod_env.scoreboard.chan0_in);
        channel1.rx_agent.monitor.item_collected_port.connect(router_mod_env.scoreboard.chan1_in);
        channel2.rx_agent.monitor.item_collected_port.connect(router_mod_env.scoreboard.chan2_in);
        hbus.masters[0].monitor.item_collected_port.connect(router_mod_env.router_reference.hbus_in);
    endfunction: connect_phase

endclass