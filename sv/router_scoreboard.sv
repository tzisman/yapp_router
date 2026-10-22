class router_sb extends uvm_scoreboard;
    `uvm_component_utils(router_sb)

    yapp_packet queue_addr0[$];
    yapp_packet queue_addr1[$];
    yapp_packet queue_addr2[$];

    int received_packets = 0;
    int warng_packets = 0;
    int match_packets = 0;


    `uvm_analysis_imp_decl(_yapp)
    uvm_analysis_imp_yapp#(yapp_packet, router_sb) yapp_in;

    function void write_yapp(input yapp_packet packet);       
        yapp_packet cloned_pkt;
            $cast(cloned_pkt, packet.clone());

        case (cloned_pkt.addr)
            2'b00: begin
                queue_addr0.push_back(cloned_pkt);
            end
            2'b01: begin
              queue_addr1.push_back(cloned_pkt);
            end
            2'b10: begin
              queue_addr2.push_back(cloned_pkt);
            end
            default: begin
              `uvm_warning("WRONG_ADDR", $sformatf("Received packet with illegal address: %0d", cloned_pkt.addr))
            end
        endcase
    endfunction


    `uvm_analysis_imp_decl(_chan0)
    uvm_analysis_imp_chan0#(channel_packet, router_sb) chan0_in;

    function void write_chan0(input channel_packet packet);
        if (queue_addr0.size() > 0) begin
            if (comp_equal(queue_addr0.pop_front(), packet)) begin
                match_packets++;
            end else begin
                warng_packets++;
            end
        end else begin
            `uvm_error("SB_ERR", "Received packet on chan0 but YAPP queue 0 is empty!")
        end
        received_packets++;
    endfunction

    `uvm_analysis_imp_decl(_chan1)
    uvm_analysis_imp_chan1#(channel_packet, router_sb) chan1_in;

    function void write_chan1(input channel_packet packet);
       if (queue_addr1.size() > 0) begin
            if (comp_equal(queue_addr1.pop_front(), packet)) begin
                match_packets++;
            end else begin
                warng_packets++;
            end
        end else begin
            `uvm_error("SB_ERR", "Received packet on chan1 but YAPP queue 1 is empty!")
        end
        received_packets++;
    endfunction

    `uvm_analysis_imp_decl(_chan2)
    uvm_analysis_imp_chan2#(channel_packet, router_sb) chan2_in;

    function void write_chan2(input channel_packet packet);
        if (queue_addr2.size() > 0) begin
            if (comp_equal(queue_addr2.pop_front(), packet)) begin
                match_packets++;
            end else begin
                warng_packets++;
            end
        end else begin
            `uvm_error("SB_ERR", "Received packet on chan2 but YAPP queue 2 is empty!")
        end
        received_packets++;
    endfunction

    function new(string name, uvm_component parent);
        super.new(name, parent);
        yapp_in = new("yapp_in", this);

        chan0_in = new("chan0_in", this);
        chan1_in = new("chan1_in", this);
        chan2_in = new("chan2_in", this);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        int total_left = queue_addr0.size() + queue_addr1.size() + queue_addr2.size();
        `uvm_info(get_type_name(), $sformatf("Report: Packets received: %0d | Match packets: %0d | Mismatch packets: %0d | Left in queues: %0d", 
                  received_packets, match_packets, warng_packets, total_left), UVM_LOW)
    endfunction
endclass

function bit comp_equal (input yapp_packet yp, input channel_packet cp);
      // returns first mismatch only
      if (yp.addr != cp.addr) begin
        `uvm_error("PKT_COMPARE",$sformatf("Address mismatch YAPP %0d Chan %0d",yp.addr,cp.addr))
        return(0);
      end
      if (yp.length != cp.length) begin
        `uvm_error("PKT_COMPARE",$sformatf("Length mismatch YAPP %0d Chan %0d",yp.length,cp.length))
        return(0);
      end
      foreach (yp.payload [i])
        if (yp.payload[i] != cp.payload[i]) begin
          `uvm_error("PKT_COMPARE",$sformatf("Payload[%0d] mismatch YAPP %0d Chan %0d",i,yp.payload[i],cp.payload[i]))
          return(0);
        end
      if (yp.parity != cp.parity) begin
        `uvm_error("PKT_COMPARE",$sformatf("Parity mismatch YAPP %0d Chan %0d",yp.parity,cp.parity))
        return(0);
      end
      return(1);
endfunction

