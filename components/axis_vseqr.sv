//  Class: axis_vseqr

class axis_vseqr extends uvm_sequencer;
  `uvm_component_utils(axis_vseqr)


  //  Group: Components
  axis_packet_seqr   m_pkt_seqr;
  axis_transfer_seqr m_transfer_seqr;


  //  Group: Variables


  //  Group: Functions

  //  Constructor: new
  function new(string name = "axis_vseqr", uvm_component parent);
    super.new(name, parent);
  endfunction : new


endclass : axis_vseqr
