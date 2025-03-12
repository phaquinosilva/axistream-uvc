//  Class: axi_s_sequencer
//
class axi_s_sequencer extends uvm_sequencer #(axi_s_transfer);
  `uvm_component_utils(axi_s_sequencer)

  //  Constructor: new
  function new(string name = "axi_s_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction : new


endclass : axi_s_sequencer
