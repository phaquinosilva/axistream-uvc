//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_packet_seq.sv
// Description: This file comprises the base sequence for the AXI-Stream VIP.
//==============================================================================

class axis_packet_seq extends uvm_sequence #(axis_transfer);

  //  Group: Variables
  protected string                        report_id    = "";

  /* size:
      - number of transfers in this packet.
  */
  rand int                                size;

  /* p_data:
      - packet data. should be sent in transfers by transmitter driver.
      - keep and strb are generated as well to allow full randomization,
        when necessary.
  */
  rand bit          [    TDATA_WIDTH-1:0] p_data   [];
  rand bit          [(TDATA_WIDTH/8)-1:0] p_keep   [];
  rand bit          [(TDATA_WIDTH/8)-1:0] p_strb   [];

  /* delay:
      - Holds a delay to be applied prior to sending this item.
      - This delay is an integer and represents a number of clock cycles.
  */
  rand int unsigned                       delays   [];

  // Utils
  `uvm_object_utils_begin(axis_packet_seq)
    `uvm_field_int(size, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_int(p_data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(p_keep, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(p_strb, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(delays, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end

  // Group: Constraints

  constraint size_c {soft size inside {[1 : 100]};}

  constraint delay_c {
    solve size before delays;
    delays.size() == size;
    foreach (delays[i]) soft delays[i] inside {[0 : 10]};
  }

  constraint strb_keep_c {
    solve size before p_data;
    solve size before p_keep;
    solve size before p_strb;

    p_data.size() == size;
    p_keep.size() == size;
    p_strb.size() == size;

    // Guarantee TSTRB is active only if TKEEP
    // is active for that byte position
    // If TKEEP[x] == 0, TSTRB[x] == 0;
    // IF TKEEP[x] == 1, TSTRB[x] == any
    foreach (p_keep[i]) &((~p_keep[i] & ~p_strb[i]) | p_keep[i]);
  }

  //  Group: Functions

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
            tdata == local:: p_data[i];
            tkeep == local:: p_keep[i];
            tstrb == local:: p_strb[i];
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
