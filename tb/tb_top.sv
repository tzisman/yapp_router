module tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  import yapp_pkg::*;
  import channel_pkg::*;
  import clock_and_reset_pkg::*;
  import hbus_pkg::*;
  import router_module_pkg::*;
  `include "router_mcsequencer.sv"
  `include "router_mcseqs_lib.sv"
  
  `include "../sv/router_scoreboard.sv"
  `include "router_tb.sv"
  `include "router_test_lib.sv"



  initial begin
    yapp_vif_config::set(null, "uvm_test_top.tb.yapp.agent.*", "vif", hw_top.in0);
    
    channel_vif_config::set(null, "uvm_test_top.tb.channel0*", "vif", hw_top.channel0);
    channel_vif_config::set(null, "uvm_test_top.tb.channel1*", "vif", hw_top.channel1);
    channel_vif_config::set(null, "uvm_test_top.tb.channel2*", "vif", hw_top.channel2);
    clock_and_reset_vif_config::set(null, "uvm_test_top.tb.clock_and_reset*", "vif", hw_top.clock_and_reset);
    
    hbus_vif_config::set(null, "uvm_test_top.tb.hbus*", "vif", hw_top.hbus_in);
    
    run_test();
  end

endmodule