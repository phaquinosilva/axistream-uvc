//==============================================================================
// Project: axis VIP
//==============================================================================
// Filename: axis_scoreboard.sv
// Description: This file comprises the scoreboard for the axis integration env.
//==============================================================================
`ifndef axis_scoreboard__sv
`define axis_scoreboard__sv

`uvm_analysis_imp_decl(_tr_receiver_ap)
`uvm_analysis_imp_decl(_tr_transmitter_ap)

`uvm_analysis_imp_decl(_pkt_receiver_ap)
`uvm_analysis_imp_decl(_pkt_transmitter_ap)

class axis_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axis_scoreboard)

  uvm_analysis_imp_tr_transmitter_ap #(axis_transfer, axis_scoreboard) tr_transmitter_ap;
  uvm_analysis_imp_tr_receiver_ap #(axis_transfer, axis_scoreboard) tr_receiver_ap;

  uvm_analysis_imp_pkt_transmitter_ap #(axis_packet, axis_scoreboard) pkt_transmitter_ap;
  uvm_analysis_imp_pkt_receiver_ap #(axis_packet, axis_scoreboard) pkt_receiver_ap;


  //  Group: Objects
  axis_transfer transmitter_transfer_q[$];
  axis_transfer receiver_transfer_q[$];

  axis_packet transmitter_packet_q[$];
  axis_packet receiver_packet_q[$];


  axis_integ_config m_cfg;
  axis_config m_cfg_transmitter;
  axis_config m_cfg_receiver;

  //  Group: Variables
  protected string report_id = "";

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase", this.report_id);
    `uvm_info(report_id, $sformatf("Started build_phase for %s", get_full_name()), UVM_NONE)
    super.build_phase(phase);

    // NOTE: When using packets, transfers are interpreted as packets 
    // with size 1. Only use transfer_ap if `use_packets == 0`.
    if (!m_cfg_transmitter.use_packets) begin
      tr_receiver_ap = new("tr_receiver_ap", this);
      tr_transmitter_ap = new("tr_transmitter_ap", this);
    end else begin
      pkt_receiver_ap = new("pkt_receiver_ap", this);
      pkt_transmitter_ap = new("pkt_transmitter_ap", this);
    end

    `uvm_info(report_id, $sformatf("Finishing build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase


  function void write_tr_transmitter_ap(axis_transfer item);
    string report_id = $sformatf("%s.write_tr_transmitter_ap", this.report_id);
    if (!m_cfg_transmitter.use_packets && m_cfg_transmitter.use_transfers) begin
      transmitter_transfer_q.push_back(item);
      `uvm_info(report_id, $sformatf("Received item from TRANSMITTER: \n%s", item.sprint()),
                UVM_NONE)
    end
  endfunction


  function void write_tr_receiver_ap(axis_transfer item);
    string report_id = $sformatf("%s.write_tr_receiver_ap", this.report_id);
    if (!m_cfg_receiver.use_packets && m_cfg_receiver.use_transfers) begin
      receiver_transfer_q.push_back(item);
      `uvm_info(report_id, $sformatf("Received item from RECEIVER: \n%s", item.sprint()), UVM_NONE)
    end
  endfunction


  function void write_pkt_transmitter_ap(axis_packet item);
    string report_id = $sformatf("%s.write_pkt_transmitter_ap", this.report_id);
    if (m_cfg_transmitter.use_packets) begin
      transmitter_packet_q.push_back(item);
      `uvm_info(report_id, $sformatf("Received item from TRANSMITTER: \n%s", item.sprint()),
                UVM_NONE)
    end
  endfunction


  function void write_pkt_receiver_ap(axis_packet item);
    string report_id = $sformatf("%s.write_pkt_receiver_ap", this.report_id);
    if (m_cfg_receiver.use_packets) begin
      receiver_packet_q.push_back(item);
      `uvm_info(report_id, $sformatf("Received item from RECEIVER: \n%s", item.sprint()), UVM_NONE)
    end
  endfunction

  virtual function void extract_phase(uvm_phase phase);
    string report_id = $sformatf("%s.extract_phase", this.report_id);
    `uvm_info(report_id, $sformatf("Cleaning up data that is not propagated for %s", get_full_name()
              ), UVM_NONE)
    super.extract_phase(phase);

    if (m_cfg_transmitter.use_packets && m_cfg_receiver.use_packets) begin
      foreach (transmitter_packet_q[i]) begin
        receiver_packet_q[i].extract_data(m_cfg_receiver);
        transmitter_packet_q[i].extract_data(m_cfg_transmitter);
      end
    end else begin
      foreach (transmitter_transfer_q[i]) begin
        transmitter_transfer_q[i].remove_disabled_sig(m_cfg_transmitter);
        receiver_transfer_q[i].remove_disabled_sig(m_cfg_receiver);
      end
    end
  endfunction : extract_phase

  virtual function void check_phase(uvm_phase phase);
    string report_id = $sformatf("%s.check_phase", this.report_id);
    `uvm_info(report_id, $sformatf("Started check_phase for %s", get_full_name()), UVM_NONE)
    super.check_phase(phase);

    if (m_cfg_transmitter.use_packets && m_cfg_receiver.use_packets) begin
      // Handle packets
      if (transmitter_packet_q.size() == receiver_packet_q.size()) begin
        foreach (transmitter_packet_q[i]) begin
          if (!transmitter_packet_q[i].compare(receiver_packet_q[i])) begin
            `uvm_error(report_id, $sformatf(
                       "Comparison mismatch: \n%s\n%s",
                       transmitter_packet_q[i].miscompares,
                       receiver_packet_q[i].sprint()
                       ));
          end
        end
      end else begin
        `uvm_error(report_id, $sformatf(
                   "Number of packets mismatch: TRANSMITTER sent %0d packets, RECEIVER got %0d.",
                   transmitter_packet_q.size(),
                   receiver_packet_q.size()
                   ));
      end
    end else begin
      // Handle transfers individually
      if (transmitter_transfer_q.size() == receiver_transfer_q.size()) begin
        foreach (transmitter_transfer_q[i]) begin
          if (!transmitter_transfer_q[i].compare(receiver_transfer_q[i])) begin
            `uvm_error(report_id, $sformatf(
                       "Comparison mismatch: \n%s\n%s",
                       transmitter_transfer_q[i].miscompares,
                       receiver_transfer_q[i].sprint()
                       ));
          end
        end
      end else begin
        `uvm_error(report_id, $sformatf(
                   "Number of transfers mismatch: TRANSMITTER sent %0d transfers, RECEIVER got %0d.",
                   transmitter_transfer_q.size(),
                   receiver_transfer_q.size()
                   ));
      end
    end

    `uvm_info(report_id, $sformatf("Finishing check_phase for %s", get_full_name()), UVM_NONE)
  endfunction : check_phase


  virtual function void report_phase(uvm_phase phase);
    string report_id = $sformatf("%s.report_phase", this.report_id);
    super.report_phase(phase);

    `uvm_info(report_id, $sformatf(
              "Received %0d %s from TRASMITTER",
              m_cfg_transmitter.use_packets ? transmitter_packet_q.size() : transmitter_transfer_q.size(),
              m_cfg_transmitter.use_packets ? "packets" : "transfers"
              ), UVM_NONE)

    `uvm_info(report_id, $sformatf(
              "Received %0d %s from RECEIVER",
              m_cfg_receiver.use_packets ? receiver_packet_q.size() : receiver_transfer_q.size(),
              m_cfg_receiver.use_packets ? "packets" : "transfers"
              ), UVM_NONE)
  endfunction : report_phase


  function new(string name = "axis_scoreboard", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction

endclass

`endif
