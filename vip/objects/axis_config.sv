//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_config.sv
// Description: This file comprises the configuration object fpr the AXI-Stream
//              UVC agents.
//==============================================================================

class axis_config extends uvm_object;

  /* Identifier for each UVC in the environment. */
  integer  vip_id;

  /* Port type: TRANSMITTER or RECEIVER */
  port_t   device_type   = TRANSMITTER;

  /* Stream type: CONT_ALIGNED, CONT_UNALIGNED or SPARSE. */
  stream_t stream_type   = CONT_ALIGNED;

  /* Sequence config:
  *  - if both use_packets and use_frames are deasserted
  *    will only consider single-transfer transactions.
  *  - used to setup subscribers for packets and frames in
  *    both transmitters or receivers.
  *  NOTE: monitor for transfers is always set, use_transfers
  *    for completeness.
  */
  bit      use_packets   = 1;
  bit      use_frames    = 0;
  bit      use_transfers = !(use_packets | use_frames);

  /* Signal config:
  *   - will disable generation, driver and monitor captures
  *     for deasserted signals.
  */
  // Optional signals
  bit      TDATA_ENABLE  = 1;
  bit      TKEEP_ENABLE  = (TDATA_WIDTH > 7);

  // Conditional signal
  bit      TLAST_ENABLE  = use_packets | use_frames;
  bit      TSTRB_ENABLE  = 0;
  bit      TID_ENABLE    = 0;
  bit      TDEST_ENABLE  = 0;
  bit      TUSER_ENABLE  = 0;


  // AXI5-Stream specific signals
`ifdef __AXI5_STREAM__
  bit CheckType = 0;
  bit TWAKEUP_ENABLE = 0;
`endif

  `uvm_object_utils_begin(axis_config)
    `uvm_field_int(vip_id, UVM_DEFAULT | UVM_DEC)
    `uvm_field_enum(port_t, device_type, UVM_DEFAULT)
    `uvm_field_enum(stream_t, stream_type, UVM_DEFAULT)
    `uvm_field_int(use_packets, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(use_frames, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(TDATA_ENABLE, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(TKEEP_ENABLE, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(TLAST_ENABLE, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(TSTRB_ENABLE, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(TID_ENABLE, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(TDEST_ENABLE, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(TUSER_ENABLE, UVM_DEFAULT | UVM_BIN)
`ifdef __AXI5_STREAM__
    `uvm_field_int(CheckType, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(TWAKEUP_ENABLE, UVM_DEFAULT | UVM_BIN)
`endif
  `uvm_object_utils_end


  function new(string name = "axis_config");
    super.new(name);
  endfunction : new

endclass : axis_config
