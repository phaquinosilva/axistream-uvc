//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_monitor.sv
// Description: This file comprises the monitor of the AXI-Stream VIP.
//==============================================================================
`ifndef axis_monitor__sv
`define axis_monitor__sv 


class axis_monitor extends uvm_monitor;
  `uvm_component_utils(axis_monitor)

  //  Group: Components
  vif_t vif;

  //  Group: Variables
  uvm_analysis_port #(axis_transfer) transfer_ap;
  axis_config m_cfg;

  string report_id = "";

  event handshake = null;

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    string report = $sformatf("%s.build_phase", report_id);
    super.build_phase(phase);
    `uvm_info(report, $sformatf("Starting build_phase for %s", get_full_name()), UVM_NONE)

    if (!uvm_config_db#(vif_t)::get(this, "", "vif", vif))
      `uvm_fatal(report, $sformatf("Error to get vif for %s", get_full_name()))

    if (!uvm_config_db#(axis_config)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal(report, $sformatf("Error to get axis_config for %s", get_full_name()))

    transfer_ap = new("transfer_ap", this);

    `uvm_info(report, $sformatf("Finishing build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase


  task run_phase(uvm_phase phase);
    string report = $sformatf("%s.run_phase", report_id);
    super.run_phase(phase);
    `uvm_info(report, $sformatf("Starting run_phase for %s", get_full_name()), UVM_NONE)

    forever begin
      @(posedge vif.ARESETn iff (vif.ARESETn === 1));

      fork
        main_monitor();
        @(negedge vif.ARESETn iff (vif.ARESETn === 0));
      join_any
      disable fork;
    end

    `uvm_info(report, $sformatf("run_phase for %s", get_full_name()), UVM_NONE)
  endtask : run_phase


  task main_monitor();
    string report = $sformatf("%s.main_monitor_%s", report_id, m_cfg.device_type.name);
    `uvm_info(report, $sformatf("Starting main_monitor for %s", get_full_name()), UVM_NONE)

    forever begin
      axis_transfer item;

      // Wait for handshake
      if (m_cfg.device_type == RECEIVER) @(handshake);
      else @(posedge vif.ACLK iff (vif.TVALID === 1 && vif.TREADY === 1));

      item = axis_transfer::type_id::create("item");
      if (m_cfg.TDATA_ENABLE) item.tdata = vif.TDATA;
      if (m_cfg.TKEEP_ENABLE) item.tkeep = vif.TKEEP;
      if (m_cfg.TLAST_ENABLE) item.tlast = vif.TLAST;
      if (m_cfg.TSTRB_ENABLE) item.tstrb = vif.TSTRB;
      if (m_cfg.TDEST_ENABLE) item.tdest = vif.TDEST;
      if (m_cfg.TUSER_ENABLE) item.tuser = vif.TUSER;
      if (m_cfg.TID_ENABLE) item.tid = vif.TID;

      item.timestamp = $time;
      `uvm_info(report, $sformatf(
                "MON_%s: Captured ITEM\n%s\n{TVALID,TREADY}=%0d%0d",
                m_cfg.device_type.name,
                item.sprint(),
                vif.TVALID,
                vif.TREADY
                ), UVM_FULL)
      transfer_ap.write(item);
    end
  endtask : main_monitor

  function new(string name = "axis_monitor", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new

endclass : axis_monitor

`endif
