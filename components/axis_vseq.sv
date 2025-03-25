//  Class: axis_vseq

class axis_vseq extends uvm_sequence;
  `uvm_component_utils(axis_vseq)
  `uvm_declare_p_sequencer (axis_vseq)

  //  Group: Components
  axis_packet_seq   m_pkt_seq;
  axis_transfer_seq m_transfer_seq;

  //  Group: Variables

  //  Group: Functions

  //  Constructor: new
  function new(string name = "axis_vseq");
    super.new(name);
  endfunction : new


endclass : axis_vseq
