//  Class: axis_transfer_seqr
//
class axis_transfer_seqr extends uvm_sequencer #(axis_transfer);
  `uvm_component_utils(axis_transfer_seqr)

  //  Constructor: new
  function new(string name = "axis_transfer_seqr", uvm_component parent);
    super.new(name, parent);
  endfunction : new


endclass : axis_transfer_seqr
