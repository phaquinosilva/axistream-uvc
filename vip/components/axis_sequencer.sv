//  Class: axis_sequencer
//
class axis_sequencer extends uvm_sequencer #(axis_transfer);
  `uvm_component_utils(axis_sequencer)

  //  Constructor: new
  function new(string name = "axis_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction : new


endclass : axis_sequencer
