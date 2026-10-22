/*-----------------------------------------------------------------
File name     : yapp_packet.sv
Description   : lab01_data YAPP UVC packet template file
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

class yapp_packet extends uvm_sequence_item;

  rand bit [5:0] length;
  rand bit [1:0] addr;
  rand bit [7:0] payload[];
  bit [7:0] parity;

  rand int packet_delay;
  rand parity_t parity_type;

  function new (string name = "yapp_packet");
    super.new(name);
  endfunction

  function bit [7:0] calc_parity();
    calc_parity = {6'b0, addr} ^ length;
    foreach (payload[i])
      calc_parity = calc_parity ^ payload[i];
  endfunction

  function void set_parity();
    parity = calc_parity();
    if (parity_type == BAD_PARITY)
      parity = ~parity;
  endfunction

  function void post_randomize();
    set_parity();
  endfunction

  //constraint valid_addr { addr != 3; }
  constraint payload_size { length == payload.size(); }
  constraint default_length { length > 0; length < 64; }
  constraint pkt_delay { packet_delay > 1; packet_delay < 20; }

  constraint parity_dist {
    parity_type dist { GOOD_PARITY := 70, BAD_PARITY := 30 };
  }

  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int( length, UVM_ALL_ON)
    `uvm_field_int( addr, UVM_ALL_ON)
    `uvm_field_array_int( payload, UVM_ALL_ON)
    `uvm_field_int( parity, UVM_ALL_ON)

    `uvm_field_int( packet_delay, UVM_ALL_ON)
    `uvm_field_enum(parity_t, parity_type, UVM_ALL_ON)
  `uvm_object_utils_end
endclass: yapp_packet



class short_yapp_packet extends yapp_packet;
  `uvm_object_utils(short_yapp_packet)
  

  function new (string name = "short_yapp_packet");
    super.new(name);
  endfunction

  //constraint valid_addr2 { addr != 2; }
  constraint limit_length {length < 15; }


endclass: short_yapp_packet



