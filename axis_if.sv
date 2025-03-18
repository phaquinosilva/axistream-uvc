//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_if.sv
// Description: This file comprises the interface for the AXI-Stream VIP.
//==============================================================================

`timescale 1ns/1ps
`ifndef axis_if__sv
`define axis_if__sv

interface axis_if #(
    parameter int TADDR_WIDTH = 0,
    parameter int TDATA_WIDTH = 8,
    parameter int TDEST_WIDTH = 0,
    parameter int TUSER_WIDTH = 0,
    parameter int TID_WIDTH = 0
) (
    input logic ACLK, input logic ARESETn
);

  /* Group: INTERFACE SIGNALS [AXI4-Stream] */
  // Required
  logic TVALID;
  logic TREADY;
  // Optional
  logic [(TDATA_WIDTH - 1): 0] TDATA;
  logic [(TDATA_WIDTH/8 - 1): 0] TKEEP;  // indicates non-null bytes
  // Conditional
  logic [(TDATA_WIDTH/8 - 1): 0] TSTRB;
  logic TLAST = 1;
  logic [(TID_WIDTH-1):0] TID;
  logic [(TDEST_WIDTH-1):0] TDEST;
  logic [(TUSER_WIDTH-1):0] TUSER;

  `ifdef __AXI5_STREAM__
  logic TWAKEUP;  // AXI5-Stream
  /* Group: CHECK SIGNALS [AXI5-Stream]
     NOTE: conditional on CheckType
  */
  logic TVALIDCHK;
  logic TREADYCHK;
  logic TLASTCHK;
  logic [($ceil(TID_WIDTH/8)-1):0] TIDCHK;
  logic [($ceil(TDEST_WIDTH/8)-1):0] TDESTCHK;
  logic [($ceil(TUSER_WIDTH/8)-1):0] TUSERCHK;
  logic TWAKEUPCHK;
  // Optional
  logic [(TDATA_WIDTH/8 - 1): 0] TDATACHK;
  logic [($ceil(TDATA_WIDTH/64) - 1): 0] TSTRBCHK;
  logic [($ceil(TDATA_WIDTH/64) - 1): 0] TKEEPCHK;
  `endif  // __AXI5_STREAM__

  endinterface : axis_if
`endif
