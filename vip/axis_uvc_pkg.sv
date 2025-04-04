//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_uvc.sv
// Description: This file comprises the package for the AXI-Stream VIP.
//==============================================================================
`ifndef axis_uvc__sv
`define axis_uvc__sv

// NOTE: AXI5-Stream not yet supported
`ifndef __AXI5_STREAM__
// Uncomment following line for AXI5-Stream functionality:
// `define __AXI5_STREAM__
`endif

//  Package: axis_uvc_pkg
//
package axis_uvc_pkg;

  //  Group: UVM
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //  Group: Parameters
  /* AXI-Stream Properties */
  localparam int TDATA_WIDTH = 128;
  localparam int TDEST_WIDTH = 8;
  localparam int TUSER_WIDTH = 1;
  localparam int TID_WIDTH = 8;
  localparam bit Continuous_Packets = 0;

`ifdef __AXI5_STREAM__
  localparam bit Check_Type = 0;
  localparam bit Wakeup_Signal = 0;
`endif  // __AXI5_STREAM__

  // Group: Interfaces
  typedef virtual axis_if #(
      .TDATA_WIDTH(TDATA_WIDTH),
      .TDEST_WIDTH(TDEST_WIDTH),
      .TUSER_WIDTH(TUSER_WIDTH),
      .TID_WIDTH  (TID_WIDTH)
  ) vif_t;

  //  Group: Typedefs
  typedef class axis_transfer_seqr;  // for compilation

  // Stream types
  typedef enum {
    BYTE,
    CONT_ALIGNED,
    CONT_UNALIGNED,
    SPARSE,
    CUSTOM
  } stream_t;

  // Agent type
  typedef enum bit {
    TRANSMITTER,
    RECEIVER
  } port_t;

  //  Group: Includes

  // Objects
  `include "axis_config.sv"
  `include "axis_transfer.sv"
  `include "axis_transfer_seq.sv"
  `include "axis_packet_seq.sv"

  // Components
  `include "axis_transfer_seqr.sv"
  `include "axis_driver.sv"
  `include "driver_transmitter.sv"
  `include "driver_receiver.sv"
  `include "axis_monitor.sv"
  `include "axis_agent.sv"

endpackage : axis_uvc_pkg

`endif
