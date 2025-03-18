//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_base_packet_seq.sv
// Description: This file comprises the base sequence for the AXI-Stream VIP.
//==============================================================================

//  Class: axis_base_packet_seq
//
class axis_base_packet_seq extends uvm_sequence #(axis_txn);

  //  Group: Variables
  protected string report_id = "";

  /* p_data:
      - packet data. should be sent in transfers by transmitter driver.
      - keep and strb are generated as well to allow full randomization,
        when necessary.
  */
  rand bit [TDATA_WIDTH-1:0]     p_data[$];
  rand bit [(TDATA_WIDTH/8)-1:0] p_keep[$];
  rand bit [(TDATA_WIDTH/8)-1:0] p_strb[$];


  /* size:
      - number of transfers in this packet.
  */
  rand int size;

  /* delay:
      - Holds a delay to be applied prior to sending this item.
      - This delay is an integer and represents a number of clock cycles.
      NOTE: perhaps delay should be associated with the trasfer and not with
            the packet. If that's the case, it should likely be a queue of delays
            not a single value.
  */
  rand int unsigned delay;

  // Utils
  `uvm_object_utils_begin(axis_base_packet_seq)
    `uvm_field_queue_int(p_data,  UVM_DEFAULT|UVM_HEX)
    `uvm_field_queue_int(p_keep,  UVM_DEFAULT|UVM_HEX)
    `uvm_field_queue_int(p_strb,  UVM_DEFAULT|UVM_HEX)
    `uvm_field_int      (size,  UVM_DEFAULT|UVM_DEC)
    `uvm_field_int      (delay, UVM_DEFAULT|UVM_DEC)
  `uvm_object_utils_end


  // Group: Constraints

  constraint size_c {
    solve size before p_data;

    soft size inside {[1:100]};
    p_data.size() == size;
  }

  constraint delay_c {
    soft delay inside {[0:1000]};
  }

  //  Group: Functions

  //  Constructor: new
  function new(string name = "axis_base_packet_seq");
    super.new(name);

    report_id = name;
  endfunction: new


  // Task: body
  task body;
    axis_packet  m_item;
    string    report_id = $sformatf("%s.body", this.report_id);

    `uvm_info(report_id, $sformatf("Started sequence '%s'.",
              this.get_full_name()), UVM_MEDIUM)

    m_item = axis_packet::type_id::create("m_item");

    start_item(m_item);

    if (!m_item.randomize() with {
      size == local::size;

      foreach(p_data[i]) begin
        p_data[i]  == local::p_data[i];
        p_keep[i]  == local::p_keep[i];
        p_strb[i]  == local::p_strb[i];
      end

      delay == local::delay;
    }) `uvm_fatal(report_id, $sformatf("Unable to randomize m_item for %s",
                  this.get_full_name()))

    `uvm_info(report_id, $sformatf("Randomized m_item for '%s'.",
              this.get_full_name()), UVM_MEDIUM)
    `uvm_info(report_id, $sformatf("Randomized item: \n%s", m_item.sprint()),
              UVM_FULL)

    finish_item(m_item);

    `uvm_info(report_id, $sformatf("Finished sequence '%s'.",
              this.get_full_name()), UVM_MEDIUM)

  endtask : body

endclass: axis_base_packet_seq
