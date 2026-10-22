class router_ref extends uvm_component;
    `uvm_component_utils(router_ref)

    bit [5:0] maxpktsize = 6'd63; 
    bit       router_en  = 1'b1;  

    // מונים מפורטים לפי סוג תקלה (מתוך router_reference)
    int unsigned dropped_disabled = 0;
    int unsigned dropped_size     = 0;
    int unsigned dropped_addr     = 0;

    `uvm_analysis_imp_decl(_yapp)
    uvm_analysis_imp_yapp#(yapp_packet, router_ref) yapp_in;
    
    `uvm_analysis_imp_decl(_hbus)
    uvm_analysis_imp_hbus#(hbus_transaction, router_ref) hbus_in;

    uvm_analysis_port#(yapp_packet) yapp_out;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        yapp_in  = new("yapp_in", this);
        hbus_in  = new("hbus_in", this);
        yapp_out = new("yapp_out", this);
    endfunction : build_phase

    virtual function void write_yapp(yapp_packet pkt);
        yapp_packet ypkt;

        if (router_en == 1'b0) begin
            dropped_disabled++;
            `uvm_info(get_type_name(), "Packet dropped: Router disabled", UVM_HIGH)
        end
        else if (pkt.length > maxpktsize) begin
            dropped_size++;
            `uvm_info(get_type_name(), $sformatf("Packet dropped: Length (%0d) exceeds maxpktsize (%0d)", pkt.length, maxpktsize), UVM_HIGH)
        end
        else if (pkt.addr == 2'b11 || pkt.addr > 2) begin
            dropped_addr++;
            `uvm_info(get_type_name(), "Packet dropped: Illegal address (3)", UVM_HIGH)
        end
        else begin
            // שכפול הפקט באמצעות clone להגנה על המקור (מתוך router_reference)
            $cast(ypkt, pkt.clone());
            yapp_out.write(ypkt);
        end
    endfunction : write_yapp

    function void write_hbus(input hbus_transaction hbus_tr);       
        if (hbus_tr.hwr_rd == HBUS_WRITE) begin
          case (hbus_tr.haddr)
            16'h1000: begin 
              maxpktsize = hbus_tr.hdata[5:0];
              `uvm_info(get_type_name(), $sformatf("Updated maxpktsize to %0d", maxpktsize), UVM_HIGH)
            end
            16'h1001: begin 
              router_en = hbus_tr.hdata[0];
              `uvm_info(get_type_name(), $sformatf("Updated router_en to %0b", router_en), UVM_HIGH)
            end
            default: ;
          endcase
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "=== Reference Model Drop Statistics ===", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Dropped (Router Disabled): %0d", dropped_disabled), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Dropped (Size Exceeded):   %0d", dropped_size), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Dropped (Illegal Address): %0d", dropped_addr), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Total Dropped Packets:     %0d", (dropped_disabled + dropped_size + dropped_addr)), UVM_LOW)
    endfunction : report_phase

endclass : router_ref