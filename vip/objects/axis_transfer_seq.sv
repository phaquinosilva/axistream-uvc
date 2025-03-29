//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_transfer_seq.sv
// Description: This file comprises the byte trasnfer sequence for the
// AXI-Stream VIP.
//==============================================================================
`ifndef axis_transfer_seq__sv
`define axis_transfer_seq__sv


class axis_transfer_seq extends uvm_sequence #(axis_transfer);

  //  Group: Variables
  protected string report_id = "";

  // Data lanes
  rand bit [TDATA_WIDTH-1:0] tdata;

  // Byte qualifiers
  rand bit [(TDATA_WIDTH/8)-1:0] tkeep;
  rand bit [(TDATA_WIDTH/8)-1:0] tstrb;

  rand int unsigned delay;

  // num_samples

  //  Group: Constraints

  constraint delay_c {delay inside {[0 : 100]};}


  constraint strb_keep_c {
    // Guarantee TSTRB is active only if TKEEP
    // is active for that byte position
    // If TKEEP[x] == 0, TSTRB[x] == 0;
    // IF TKEEP[x] == 1, TSTRB[x] == any
    soft &((~tkeep & ~tstrb) | tkeep);
  }

  //  Group: Functions

  // Utils
  `uvm_object_utils_begin(axis_transfer_seq)
    `uvm_field_int(tdata, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(tkeep, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(tstrb, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(delay, UVM_DEFAULT | UVM_TIME)
  `uvm_object_utils_end


  //  Constructor: new
  function new(string name = "axis_transfer_seq");
    super.new(name);

    report_id = name;
  endfunction : new

  // Task: body
  task body;
    axis_transfer m_item;
    string report_id = $sformatf("%s.body", this.report_id);
    `uvm_info(report_id, $sformatf("Started sequence '%s'.", this.get_full_name()), UVM_MEDIUM)

    m_item = axis_transfer::type_id::create("m_item");

    start_item(m_item);

    `uvm_info(report_id, $sformatf("Started item on sequence '%s'.", this.get_full_name()),
              UVM_MEDIUM)
    if (!m_item.randomize() with {
          tdata == local:: tdata;
          tkeep == local:: tkeep;
          tstrb == local:: tstrb;
          delay == local:: delay;
        })
      `uvm_fatal(report_id, $sformatf("Unable to randomize m_item for %s", this.get_full_name()))

    `uvm_info(report_id, $sformatf("Randomized m_item for '%s'.", this.get_full_name()), UVM_MEDIUM)
    `uvm_info(report_id, $sformatf("Randomized item: \n%s", m_item.sprint()), UVM_FULL)

    finish_item(m_item);

    `uvm_info(report_id, $sformatf("Finished sequence '%s'.", this.get_full_name()), UVM_MEDIUM)
  endtask : body

endclass : axis_transfer_seq

`endif
