//  Class: axis_packet_seqr
//
class axis_packet_seqr extends uvm_sequencer #(axis_packet);
  `uvm_component_utils(axis_packet_seqr)

  //  Constructor: new
  function new(string name = "axis_packet_seqr", uvm_component parent);
    super.new(name, parent);
  endfunction : new


endclass : axis_packet_seqr
