//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_packet_seq.sv
// Description: This file comprises the base sequence for the AXI-Stream VIP.
//==============================================================================
`ifndef axis_packet_seq__sv
`define axis_packet_seq__sv


class axis_packet_seq extends uvm_sequence #(axis_transfer);


  //  Group: Variables
  protected string                         report_id      = "";

  /* size:
      - number of transfers in this packet.
  */
  rand int                                 size;

  /* p_data:
      - packet data. should be sent in transfers by transmitter driver.
      - keep and strb are generated as well to allow full randomization,
        when necessary.
  */
  rand bit           [    TDATA_WIDTH-1:0] p_data     [];
  rand bit           [(TDATA_WIDTH/8)-1:0] p_keep     [];
  rand bit           [(TDATA_WIDTH/8)-1:0] p_strb     [];
  rand bit           [  (TID_WIDTH/8)-1:0] tid;
  rand bit           [(TUSER_WIDTH/8)-1:0] tuser;
  rand bit           [(TDEST_WIDTH/8)-1:0] tdest;

  /* delay:
      - Holds a delay to be applied prior to sending this item.
      - This delay is an integer and represents a number of clock cycles.
  */
  rand int unsigned                        delays     [];

  /* stream_type:
  *   - defines the data generation constraints of the package.
  *   - should be obtained from the m_agt.m_cfg that will consume this
  *   - sequence, and maintained constant in the testbench.
  */
  protected stream_t                       stream_type    = SPARSE;
  // Strobe signaling required for CONT_UNALIGNED streams
  rand int                                 strb_start     = 1;
  rand int                                 strb_end       = 1;
  bit                                      only_delay     = 0;


  // Utils
  `uvm_object_utils_begin(axis_packet_seq)
    `uvm_field_enum(stream_t, stream_type, UVM_DEFAULT)
    `uvm_field_int(size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_int(p_data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(p_keep, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(p_strb, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(delays, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(tid, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(tdest, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(tuser, UVM_NOCOMPARE | UVM_BIN)
  `uvm_object_utils_end

  //  Group: Constraints
  constraint size_c {
    solve size before p_data;
    solve size before p_keep;
    solve size before p_strb;
    solve size before delays;
    soft size inside {[1 : 100]};

    p_data.size() == size;
    p_keep.size() == size;
    p_strb.size() == size;
    delays.size() == size;
  }

  constraint delay_c {
    solve size before delays;
    foreach (delays[i]) soft delays[i] inside {[0 : 10]};
  }

  constraint strb_keep_c {
    solve p_keep before p_strb;

    // Guarantee TSTRB is active only if TKEEP
    // is active for that byte position
    // If TKEEP[x] == 0, TSTRB[x] == 0;
    // IF TKEEP[x] == 1, TSTRB[x] == any
    foreach (p_keep[i]) &((~p_keep[i] & ~p_strb[i]) | p_keep[i]);
  }

  constraint stream_t_c {
    // Custom streams have no further constraints

    /* 1.2.1 no position bytes */
    if (stream_type == BYTE) foreach (p_strb[i]) p_strb[i] == p_keep[i];

    /* 1.2.2 every packet has no null or position bytes */
    if (stream_type == CONT_ALIGNED) {
      foreach (p_keep[i]) p_keep[i] == '1;
      foreach (p_strb[i]) p_strb[i] == '1;
    }

    /* 1.2.3 only packets in the boundaries may have position bytes, no null
    * bytes */
    if (stream_type == CONT_UNALIGNED) {
      solve strb_start before p_strb;
      solve strb_end before p_strb;

      foreach (p_keep[i]) p_keep[i] == '1;
      foreach (p_strb[i]) if (i != 0 && i != this.size - 1) p_strb[i] == '1;
      // position bytes should only appear in boundary transfers
      // and be contiguous within this transfer
      strb_start inside {[0 : $bits(p_strb[0])]};
      strb_end inside {[0 : $bits(p_strb[0])]};
      foreach (p_strb[0][j]) p_strb[0][j] == (j >= strb_start);
      foreach (p_strb[size-1][j]) p_strb[size-1][j] == (j < strb_end);
    }

    /* 1.2.4 no null bytes */
    if (stream_type == SPARSE) foreach (p_keep[i]) p_keep[i] == '1;
  }

  constraint only_delay_c {
    if (only_delay) {
      tid == 0;
      tuser == 0;
      tdest == 0;
      foreach (p_strb[i]) p_strb[i] == 0;
      foreach (p_keep[i]) p_keep[i] == 0;
      foreach (p_data[i]) p_data[i] == 0;
    }
  }

  //  Group: Functions
  function set_stream_type(stream_t stream_type);
    this.stream_type = stream_type;
  endfunction : set_stream_type

  function get_stream_type();
    get_stream_type = stream_type;
  endfunction : get_stream_type

  function set_only_delay(bit mode);
    this.only_delay = mode;
    this.only_delay_c.constraint_mode(mode);
    this.stream_t_c.constraint_mode(!mode);
  endfunction

  //  Constructor: new
  function new(string name = "axis_packet_seq");
    super.new(name);
    report_id = name;
  endfunction : new

  task body;
    string report = $sformatf("%s.body", this.report_id);
    axis_transfer transfer;
    `uvm_info(report_id, $sformatf("Started sequence %s.", this.get_full_name()), UVM_MEDIUM)
    for (int i = 0; i < this.size; i++) begin
      transfer = axis_transfer::type_id::create("transfer");

      start_item(transfer);
      if (!transfer.randomize() with {
            tkeep == local:: p_keep[i];
            tstrb == local:: p_strb[i];
            tuser == local:: tuser;
            tdest == local:: tdest;
            tid == local:: tid;
            tdata == local:: p_data[i];
            delay == local:: delays[i];
          })
        `uvm_fatal(report_id, $sformatf("Unable to randomize m_item for %s", this.get_full_name()))

      // assert TLAST for last transfer
      transfer.tlast = (i == this.size - 1);

      `uvm_info(report_id, $sformatf("Randomized m_item for '%s'.", this.get_full_name()),
                UVM_MEDIUM)
      `uvm_info(report_id, $sformatf("Randomized item: \n%s", transfer.sprint()), UVM_FULL)

      finish_item(transfer);
    end
  endtask : body

endclass : axis_packet_seq

`endif
