//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_cov_collector.sv
// Description: This file comprises the coverage collector for the 
// AXI-Stream VIP.
//==============================================================================
`ifndef axis_cov_collector__sv
`define axis_cov_collector__sv

import axis_uvc_pkg::TDATA_WIDTH;
import axis_uvc_pkg::TID_WIDTH;
import axis_uvc_pkg::TDEST_WIDTH;

covergroup cg_handshake(vif_t vif) @(posedge vif.TVALID, posedge vif.TREADY);
  cp_tready_before_tvalid: coverpoint vif.TREADY iff (!vif.TVALID && vif.ARESETn) {
    option.at_least = 20;
  }
  cp_tvalid_before_tready: coverpoint vif.TVALID iff (!vif.TREADY && vif.ARESETn) {
    option.at_least = 20;
  }
endgroup

class axis_cov_collector extends uvm_component;

  `uvm_component_utils(axis_cov_collector)

  `uvm_analysis_imp_decl(_tr_transmitter)
  `uvm_analysis_imp_decl(_tr_receiver)
  `uvm_analysis_imp_decl(_pkt_transmitter)
  `uvm_analysis_imp_decl(_pkt_receiver)

  uvm_analysis_imp_tr_transmitter #(axis_transfer, axis_cov_collector) tr_transmitter_imp;
  uvm_analysis_imp_tr_receiver #(axis_transfer, axis_cov_collector) tr_receiver_imp;
  uvm_analysis_imp_pkt_transmitter #(axis_packet, axis_cov_collector) pkt_transmitter_imp;
  uvm_analysis_imp_pkt_receiver #(axis_packet, axis_cov_collector) pkt_receiver_imp;

  protected string report_id = "";

  vif_t vifs[];
  axis_integ_config m_cfg;

  //  Group: Covergroups
  cg_handshake cg_vifs[];

  covergroup cg_transfer_tr with function sample (axis_transfer t, stream_t s);
    cp_stream_type: coverpoint s;
    cp_prev_tvalid_delay: coverpoint t.delay {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : 98]};
      bins b_max_m1 = {'d99};
      bins b_max = {'d100};
    }
    cp_tdata: coverpoint t.tdata {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TDATA_WIDTH - 3)]};
      bins b_max_m1 = {2 ** TDATA_WIDTH - 2};
      bins b_max = {2 ** TDATA_WIDTH - 1};
    }
    cp_tkeep: coverpoint t.tkeep {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TDATA_WIDTH >> 8 - 3)]};
      bins b_max_m1 = {2 ** TDATA_WIDTH >> 8 - 2};
      bins b_max = {2 ** TDATA_WIDTH - 1};
    }
    cp_tstrb: coverpoint t.tstrb {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TDATA_WIDTH >> 8 - 3)]};
      bins b_max_m1 = {2 ** TDATA_WIDTH >> 8 - 2};
      bins b_max = {2 ** TDATA_WIDTH >> 8 - 1};
    }
    cp_tid: coverpoint t.tid {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TID_WIDTH >> 8 - 3)]};
      bins b_max_m1 = {2 ** TID_WIDTH >> 8 - 2};
      bins b_max = {2 ** TID_WIDTH >> 8 - 1};
    }
    cp_tdest: coverpoint t.tdest {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TDEST_WIDTH >> 8 - 3)]};
      bins b_max_m1 = {2 ** TDEST_WIDTH >> 8 - 2};
      bins b_max = {2 ** TDEST_WIDTH >> 8 - 1};
    }
    type_x_tid_x_tdest: cross cp_stream_type, cp_tid, cp_tdest;
    type_x_tkeep_x_tstrb: cross cp_stream_type, cp_tkeep, cp_tstrb;
  endgroup : cg_transfer_tr

  covergroup cg_transfer_re with function sample (axis_transfer t, stream_t s);
    cp_stream_type: coverpoint s;
    cp_prev_tvalid_delay: coverpoint t.delay {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : 98]};
      bins b_max_m1 = {'d99};
      bins b_max = {'d100};
    }
    cp_tdata: coverpoint t.tdata {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TDATA_WIDTH - 3)]};
      bins b_max_m1 = {2 ** TDATA_WIDTH - 2};
      bins b_max = {2 ** TDATA_WIDTH - 1};
    }
    cp_tkeep: coverpoint t.tkeep {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TDATA_WIDTH >> 8 - 3)]};
      bins b_max_m1 = {2 ** TDATA_WIDTH >> 8 - 2};
      bins b_max = {2 ** TDATA_WIDTH - 1};
    }
    cp_tstrb: coverpoint t.tstrb {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TDATA_WIDTH >> 8 - 3)]};
      bins b_max_m1 = {2 ** TDATA_WIDTH >> 8 - 2};
      bins b_max = {2 ** TDATA_WIDTH >> 8 - 1};
    }
    cp_tid: coverpoint t.tid {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TID_WIDTH >> 8 - 3)]};
      bins b_max_m1 = {2 ** TID_WIDTH >> 8 - 2};
      bins b_max = {2 ** TID_WIDTH >> 8 - 1};
    }
    cp_tdest: coverpoint t.tdest {
      bins b_min = {'d0};
      bins b_min_p1 = {'d1};
      bins b_[10] = {[2 : (2 ** TDEST_WIDTH >> 8 - 3)]};
      bins b_max_m1 = {2 ** TDEST_WIDTH >> 8 - 2};
      bins b_max = {2 ** TDEST_WIDTH >> 8 - 1};
    }
    type_x_tid_x_tdest: cross cp_stream_type, cp_tid, cp_tdest;
    type_x_tkeep_x_tstrb: cross cp_stream_type, cp_tkeep, cp_tstrb;
  endgroup : cg_transfer_re

  covergroup cg_packet_tr with function sample (axis_packet item);
    cp_stream_type: coverpoint item.stream_type;
    cp_size: coverpoint item.size {
      bins b_min = {'d1};
      bins b_min_p1 = {'d2};
      bins b_[10] = {[2 : 98]};
      bins b_max_m1 = {'d99};
      bins b_max = {'d100};
    }
    type_x_size: cross cp_stream_type, cp_size;
  endgroup : cg_packet_tr

  covergroup cg_packet_re with function sample (axis_packet item);
    cp_stream_type: coverpoint item.stream_type;
    cp_size: coverpoint item.size {
      bins b_min = {'d1};
      bins b_min_p1 = {'d2};
      bins b_[10] = {[2 : 98]};
      bins b_max_m1 = {'d99};
      bins b_max = {'d100};
    }
    type_x_size: cross cp_stream_type, cp_size;
  endgroup : cg_packet_re

  covergroup cg_timedelta_tr with function sample (time prev, time current);
    cp_timestamps_interval: coverpoint (current - prev) {
      bins b_5 = {[0 : 5]};
      bins b_10 = {[6 : 10]};
      bins b_15 = {[7 : 15]};
      bins b_20 = {[16 : 20]};
      bins b_25 = {[20 : 25]};
      bins b_default = default;
    }
  endgroup : cg_timedelta_tr

  covergroup cg_timedelta_re with function sample (time prev, time current);
    cp_timestamps_interval: coverpoint (current - prev) {
      bins b_5 = {[0 : 5]};
      bins b_10 = {[6 : 10]};
      bins b_15 = {[7 : 15]};
      bins b_20 = {[16 : 20]};
      bins b_25 = {[20 : 25]};
      bins b_default = default;
    }
  endgroup : cg_timedelta_re

  time prev_t_re = 0;
  time prev_t_tr = 0;

  //  Group: Functions

  virtual function void build_phase(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase", this.report_id);
    `uvm_info(report_id, $sformatf("Started build_phase for %s", this.get_full_name()), UVM_NONE)

    super.build_phase(phase);

    tr_transmitter_imp = new("tr_transmitter_imp", this);
    tr_receiver_imp = new("tr_receiver_imp", this);
    pkt_transmitter_imp = new("pkt_transmitter_imp", this);
    pkt_receiver_imp = new("pkt_receiver_imp", this);

    if (!uvm_config_db#(axis_integ_config)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal(report_id, "Unable to fetch env configuration for coverage colletor.")

    vifs = new[m_cfg.get_n_agts()];

    foreach (vifs[i]) begin
      if (!uvm_config_db#(vif_t)::get(this, "", $sformatf("vifs[%0d]", i), vifs[i]))
        `uvm_fatal(report_id, "Unable to fetch vif for cov collector.")
    end

    cg_vifs = new[vifs.size()];
    foreach (cg_vifs[i]) begin
      cg_vifs[i] = new(vifs[i]);
    end

    `uvm_info(report_id, $sformatf("Finished build_phase for %s", this.get_full_name()), UVM_NONE)
  endfunction : build_phase


  virtual function void report_phase(uvm_phase phase);
    string report_id = $sformatf("%s.report_phase", this.report_id);
    super.report_phase(phase);

    // Coverage reports for transmitters
    `uvm_info(report_id, $sformatf(
              "Coverage for cg_transfer_tr is %0.2f %%", cg_transfer_tr.get_coverage()), UVM_HIGH)
    `uvm_info(report_id, $sformatf(
              "Coverage for cg_packet_tr is %0.2f %%", cg_packet_tr.get_coverage()), UVM_HIGH)
    `uvm_info(report_id, $sformatf(
              "Coverage for cg_timedelta_tr is %0.2f %%", cg_timedelta_tr.get_coverage()), UVM_HIGH)

    // Coverage reports for receivers
    `uvm_info(report_id, $sformatf(
              "Coverage for cg_transfer_re is %0.2f %%", cg_transfer_re.get_coverage()), UVM_HIGH)
    `uvm_info(report_id, $sformatf(
              "Coverage for cg_packet_re is %0.2f %%", cg_packet_re.get_coverage()), UVM_HIGH)
    `uvm_info(report_id, $sformatf(
              "Coverage for cg_timedelta_re is %0.2f %%", cg_timedelta_re.get_coverage()), UVM_HIGH)


    // Coverage report for handshake monitoring
    foreach (vifs[i])
      `uvm_info(report_id, $sformatf(
                "Coverage for cg_handshake[%0d] is %0.2f %%", i, cg_vifs[i].get_inst_coverage()),
                UVM_NONE)

  endfunction : report_phase


  //  Write port functions
  function write_tr_transmitter(axis_transfer item);
    string report_id = $sformatf("%s.write_tr_transmitter", this.report_id);
    `uvm_info(report_id, $sformatf("Received item in coverage collector: %s", item.sprint()),
              UVM_DEBUG)

    cg_transfer_tr.sample(item, CUSTOM);
    cg_timedelta_tr.sample(item.timestamp, prev_t_tr);
    prev_t_tr = item.timestamp;
  endfunction

  function write_tr_receiver(axis_transfer item);
    string report_id = $sformatf("%s.write_tr_receiver", this.report_id);
    `uvm_info(report_id, $sformatf("Received item in coverage collector: %s", item.sprint()),
              UVM_DEBUG)

    cg_transfer_re.sample(item, CUSTOM);
    cg_timedelta_re.sample(item.timestamp, prev_t_re);
    prev_t_re = item.timestamp;
  endfunction

  function write_pkt_transmitter(axis_packet item);
    string report_id = $sformatf("%s.write_pkt_transmitter", this.report_id);
    `uvm_info(report_id, $sformatf("Received item in coverage collector: %s", item.sprint()),
              UVM_DEBUG)

    foreach (item.transfers[i]) begin
      cg_transfer_tr.sample(item.transfers[i], item.stream_type);
      cg_timedelta_tr.sample(item.transfers[i].timestamp, prev_t_tr);
      prev_t_tr = item.transfers[i].timestamp;
    end

    cg_packet_tr.sample(item);
  endfunction

  function write_pkt_receiver(axis_packet item);
    string report_id = $sformatf("%s.write_pkt_receiver", this.report_id);
    `uvm_info(report_id, $sformatf("Received item in coverage collector: %s", item.sprint()),
              UVM_DEBUG)

    foreach (item.transfers[i]) begin
      cg_transfer_re.sample(item.transfers[i], item.stream_type);
      cg_timedelta_re.sample(item.transfers[i].timestamp, prev_t_re);
      prev_t_re = item.transfers[i].timestamp;
    end

    cg_packet_re.sample(item);
  endfunction


  //  Group: Constructor
  function new(string name = "axis_cov_collector", uvm_component parent);
    super.new(name, parent);

    cg_timedelta_tr = new();
    cg_transfer_tr = new();
    cg_packet_tr = new();

    cg_timedelta_re = new();
    cg_transfer_re = new();
    cg_packet_re = new();

    this.report_id = name;
  endfunction

endclass

`endif
