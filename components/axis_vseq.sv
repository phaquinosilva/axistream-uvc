`ifndef axis_vseq__sv
`define axis_vseq__sv 


class axis_vseq extends uvm_sequence;
  `uvm_object_utils(axis_vseq)

  // Group: Config object(s)
  axis_config m_cfg;

  //  Group: Sequencers
  axis_transfer_seqr m_transfer_seqr;

  //  Group: Sequences
  axis_packet_seq m_pkt_seq;
  axis_transfer_seq m_transfer_seq;

  //  Group: Variables
  protected string report_id = "";

  function void setup_vseq(axis_config cfg, axis_transfer_seqr seqr);
    this.m_cfg = cfg;
    this.m_transfer_seqr = seqr;
  endfunction


  //  Group: Tasks
  virtual task body;
    axis_config agt_cfg;
    string report_id = $sformatf("%s.body", this.report_id);
    `uvm_info(report_id, $sformatf("Starting body for %s", this.get_full_name()), UVM_LOW)

    // for (int i = 0; i < m_cfg.get_n_agts(); i++) begin
    // automatic int var_i = i;
    // agt_cfg = m_cfg.get_config(var_i);
    fork
      //begin
      if (m_cfg.use_packets) m_pkt_seq.start(m_transfer_seqr);
      if (m_cfg.use_transfers) m_transfer_seq.start(m_transfer_seqr);
      //end
    join_none
    // end
    wait fork;

    `uvm_info(report_id, $sformatf("Finishing body for %s", this.get_full_name()), UVM_LOW)
  endtask

  //  Constructor: new
  function new(string name = "axis_vseq");
    super.new(name);
    this.report_id = name;
  endfunction : new

endclass : axis_vseq

`endif
