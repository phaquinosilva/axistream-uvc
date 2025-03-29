//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_transfer.sv
// Description: This file comprises the AXI-Stream transfer item
// for the AXI-Stream VIP.
//==============================================================================
`ifndef axis_transfer__sv
`define axis_transfer__sv


class axis_transfer extends uvm_sequence_item;

  //  Group: Variables

  /* tdata:
    - Holds the data for a given item.
    - Is composed of any number of bytes that grouped have
      size TDATA_WIDTH.
  */
  rand bit [TDATA_WIDTH-1:0] tdata;

  /* tkeep
    - Indicates whether the associated byte is null.
    - One bit per byte in TDATA.
  */
  rand bit [(TDATA_WIDTH/8)-1:0] tkeep;

  /* tstrb
    - Indicates whether the associated byte is a data or position
    byte.
    - If the related bit in TKEEP is zero (byte is null),
    the bit in TSTRB is preffered to also be zero (no null byte
    is either data or position, so TSTRB is probably ignored by
    the endpoints).
    - One bit per byte in TDATA.
  */
  rand bit [(TDATA_WIDTH/8)-1:0] tstrb;

  /* tlast
    - indicates transfer is the last in the packet.
    - defaults to 1 for cases where no concept of packet is present.
  */
  bit tlast = 1;

  /* timestamp:
    - Holds the time in which the item was received.
  */
  time timestamp;

  /* delay:
    - Holds a delay to be applied prior to sending this item.
    - This delay is an integer and represents a number of clock cycles.
  */
  rand int unsigned delay;

  // Utils
  `uvm_object_utils_begin(axis_transfer)
    `uvm_field_int(tdata, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(tkeep, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(tstrb, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(tlast, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(delay, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(timestamp, UVM_DEFAULT | UVM_TIME)
  `uvm_object_utils_end

  //  Group: Constraints
  //  Group: Functions

  //  Constructor: new
  function new(string name = "axis_transfer");
    super.new(name);
  endfunction : new

endclass : axis_transfer

`endif
