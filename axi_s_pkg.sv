//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axi_s_pkg.sv
// Description: This file comprises the package for the AXI-Stream VIP.
//==============================================================================


// Uncomment this line for AXI5-Stream functionality
// `ifndef __AXI5_STREAM__
// `define __AXI5_STREAM__
// `endif

//  Package: axi_s_pkg
//
package axi_s_pkg;

  //  Group: UVM
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //  Group: Parameters
  /* AXI-Stream Properties */
  localparam   int   TADDR_WIDTH = 0;
  localparam   int   TDATA_WIDTH = 8*16;
  localparam   int   TDEST_WIDTH = 0;
  localparam   int   TUSER_WIDTH = 0;
  localparam   int   TID_WIDTH = 0;
  localparam   bit   Continuous_Packets = 0;

  `ifdef __AXI5_STREAM__
    localparam bit   Check_Type = 0;
    localparam bit   Wakeup_Signal = 0;
  `endif // __AXI5_STREAM__

  // Group: Interfaces
  `include "axi_s_if.sv"

  //  Group: Typedefs

  typedef enum bit {
    TRANSMITTER,
    RECEIVER
  } port_t;

  typedef virtual axi_s_if #(
    .TADDR_WIDTH(TADDR_WIDTH),
    .TDATA_WIDTH(TDATA_WIDTH),
    .TDEST_WIDTH(TDEST_WIDTH),
    .TUSER_WIDTH(TUSER_WIDTH),
    .TID_WIDTH(TID_WIDTH)
  ) vif_t;

  //  Group: Includes

  // Objects
  `include "axi_s_transfer.sv"
  `include "axi_s_config.sv"
  `include "axi_s_transfer_seq.sv"

  // Components
  `include "axi_s_driver.sv"
  `include "driver_transmitter.sv"
  `include "driver_receiver.sv"
  `include "axi_s_monitor.sv"
  `include "axi_s_sequencer.sv"

  // `include "axi_s_vseqr.sv"
  `include "axi_s_agent.sv"
  `include "axi_s_env.sv"
  // `include "axi_s_scoreboard.sv"
  `include "axi_s_base_test.sv"

endpackage : axi_s_pkg
