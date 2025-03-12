//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axi_s_config.sv
// Description: This file comprises the configuration object fpr the AXI-Stream VIP.
//==============================================================================

class axi_s_config extends uvm_object;
  `uvm_object_utils(axi_s_config)

  integer                 vip_id              = 0;

  /* Port type: TRANSMITTER or RECEIVER */
  port_t port = TRANSMITTER;

  function new(string name = "axi_s_config");
    super.new(name);
  endfunction : new

endclass : axi_s_config
