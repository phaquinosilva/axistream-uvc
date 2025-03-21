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
  localparam int TADDR_WIDTH = 0;
  localparam int TDATA_WIDTH = 8 * 16;
  localparam int TDEST_WIDTH = 0;
  localparam int TUSER_WIDTH = 0;
  localparam int TID_WIDTH = 0;
  localparam bit Continuous_Packets = 0;

`ifdef __AXI5_STREAM__
  localparam bit Check_Type = 0;
  localparam bit Wakeup_Signal = 0;
`endif  // __AXI5_STREAM__

  // Group: Interfaces
  // `include "axis_if.sv"

  //  Group: Typedefs
  typedef class axis_transfer_seqr;
  typedef class axis_packet_seqr;

  typedef enum bit {
    TRANSMITTER,
    RECEIVER
  } port_t;

  typedef virtual axis_if #(
    .TADDR_WIDTH(TADDR_WIDTH),
    .TDATA_WIDTH(TDATA_WIDTH),
    .TDEST_WIDTH(TDEST_WIDTH),
    .TUSER_WIDTH(TUSER_WIDTH),
    .TID_WIDTH  (TID_WIDTH)
  ) vif_t;

  //  Group: Includes

  // Objects
  `include "axis_config.sv"
  `include "axis_transfer.sv"
  `include "axis_transfer_seq.sv"
  `include "axis_packet.sv"
  `include "axis_packet_seq.sv"
  `include "axis_packet2transfer_seq.sv"

  // Components
  `include "axis_transfer_seqr.sv"
  `include "axis_packet_seqr.sv"
  `include "axis_seqr_ctrl.sv"
  `include "axis_driver.sv"
  `include "driver_transmitter.sv"
  `include "driver_receiver.sv"
  `include "axis_monitor.sv"
  `include "axis_agent.sv"

endpackage : axis_uvc
