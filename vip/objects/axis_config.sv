//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_config.sv
// Description: This file comprises the configuration object fpr the AXI-Stream VIP.
//==============================================================================

class axis_config extends uvm_object;
 
  function new(string name = "axis_config");
    super.new(name);
  endfunction : new

  integer                 vip_id;

  /* Port type: TRANSMITTER or RECEIVER */
  port_t port = TRANSMITTER;
  bit has_pkt_seqr = 1'b1;

  `uvm_object_utils_begin(axis_config)
    `uvm_field_int      (vip_id, UVM_DEFAULT|UVM_BIN)
    `uvm_field_enum     (port_t, port, UVM_DEFAULT)
    `uvm_field_int      (has_pkt_seqr, UVM_DEFAULT|UVM_BIN)
  `uvm_object_utils_end

endclass : axis_config
