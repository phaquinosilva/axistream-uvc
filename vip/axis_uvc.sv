//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_uvc.sv
// Description: This file comprises the package for the AXI-Stream VIP.
//==============================================================================


// Uncomment this line for AXI5-Stream functionality
// `ifndef __AXI5_STREAM__
// `define __AXI5_STREAM__
// `endif

//  Package: axis_uvc
//
package axis_uvc;

  //  Group: UVM
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //  Group: Parameters
  /* AXI-Stream Properties */
  localparam int TDATA_WIDTH = 8;
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
    CONT_ALIGNED,
    CONT_UNALIGNED,
    SPARSE
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

endpackage : axis_uvc
