class router_module_env extends uvm_env;

  `uvm_component_utils(router_module_env)

  router_sb scoreboard;
  router_ref  router_reference;

  function new(string name = "router_module_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    scoreboard = router_sb::type_id::create("scoreboard", this);
    router_reference = router_ref::type_id::create("router_reference", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    router_reference.yapp_out.connect(scoreboard.yapp_in);
  endfunction : connect_phase

endclass : router_module_env