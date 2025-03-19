//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_config.sv
// Description: This file comprises the configuration object fpr the AXI-Stream VIP.
//==============================================================================

class axis_config extends uvm_object;
  `uvm_object_utils(axis_config)

  integer                 vip_id;

  /* Port type: TRANSMITTER or RECEIVER */
  port_t port = TRANSMITTER;
  bit has_pkt_seqr = 1'b1;

  function new(string name = "axis_config");
    super.new(name);
  endfunction : new

endclass : axis_config
