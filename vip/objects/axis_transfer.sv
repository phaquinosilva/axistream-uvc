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
  rand bit          [    TDATA_WIDTH-1:0] tdata;

  /* tkeep
    - Indicates whether the associated byte is null.
    - One bit per byte in TDATA.
  */
  rand bit          [(TDATA_WIDTH/8)-1:0] tkeep;

  /* tstrb
    - Indicates whether the associated byte is a data or position
    byte.
    - If the related bit in TKEEP is zero (byte is null),
    the bit in TSTRB is preffered to also be zero (no null byte
    is either data or position, so TSTRB is probably ignored by
    the endpoints).
    - One bit per byte in TDATA.
  */
  rand bit          [(TDATA_WIDTH/8)-1:0] tstrb;

  /* delay:
    - Holds a delay to be applied prior to sending this item.
    - This delay is an integer and represents a number of clock cycles.
  */
  rand int unsigned                       delay;

  /* tlast
    - indicates transfer is the last in the packet.
    - defaults to 1 for cases where no concept of packet is present.
  */
  bit                                     tlast       = 1;


  /* TID, TUSER, TDES */
  rand bit          [  (TID_WIDTH/8)-1:0] tid;
  rand bit          [(TUSER_WIDTH/8)-1:0] tuser;
  rand bit          [(TDEST_WIDTH/8)-1:0] tdest;


  /* timestamp:
    - Holds the time in which the item was received.
  */
  time                                    timestamp;

  /* miscompares:
  *   - used for custom comparer.
  */
  string                                  miscompares = "";

  // Utils
  `uvm_object_utils_begin(axis_transfer)
    `uvm_field_int(tdata, UVM_NOCOMPARE | UVM_HEX)
    `uvm_field_int(tkeep, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(tstrb, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(tlast, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(tid, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(tdest, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(tuser, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(delay, UVM_NOCOMPARE | UVM_DEC)
    `uvm_field_int(timestamp, UVM_NOCOMPARE | UVM_TIME)
  `uvm_object_utils_end

  //  Group: Constraints

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    axis_transfer rhs_;
    do_compare = 1;
    if (!$cast(rhs_, rhs))
      `uvm_fatal($sformatf("%s.do_compare", get_full_name()), "Unable to cast rhs.")

    do_compare &= comparer.compare_field("tdata", this.tdata, rhs_.tdata, TDATA_WIDTH, UVM_HEX);
    do_compare &= comparer.compare_field("tkeep", this.tkeep, rhs_.tkeep, TDATA_WIDTH / 8, UVM_HEX);
    do_compare &= comparer.compare_field("tstrb", this.tstrb, rhs_.tstrb, TDATA_WIDTH / 8, UVM_HEX);
    do_compare &= comparer.compare_field("tlast", this.tlast, rhs_.tlast, 1, UVM_HEX);
    do_compare &= comparer.compare_field("tid", this.tid, rhs_.tid, TID_WIDTH, UVM_HEX);
    do_compare &= comparer.compare_field("tuser", this.tuser, rhs_.tuser, TUSER_WIDTH, UVM_HEX);
    do_compare &= comparer.compare_field("tdest", this.tdest, rhs_.tdest, TDEST_WIDTH, UVM_HEX);

    this.miscompares = comparer.miscompares;
  endfunction


  function void remove_disabled_sig(axis_config cfg);
    if (!cfg.TDATA_ENABLE) this.tdata = '0;
    if (!cfg.TKEEP_ENABLE) this.tkeep = '1;
    if (!cfg.TSTRB_ENABLE) this.tstrb = '1;
    if (!cfg.TLAST_ENABLE) this.tlast = '1;
    if (!cfg.TDEST_ENABLE) this.tdest = '0;
    if (!cfg.TUSER_ENABLE) this.tuser = '0;
    if (!cfg.TID_ENABLE) this.tid = '0;
  endfunction


  //  Constructor: new
  function new(string name = "axis_transfer");
    super.new(name);
  endfunction : new

endclass : axis_transfer

`endif
