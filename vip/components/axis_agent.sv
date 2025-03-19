//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_agent.sv
// Description: This file comprises the AXI-Stream agent for the AXI-Stream VIP.
//==============================================================================

class axis_agent extends uvm_agent;
  `uvm_component_utils(axis_agent)

  //  Group: Configuration object
  axis_config        m_cfg           = null;

  //  Group: Components
  vif_t              vif;

  // Packet handlers
  axis_packet_seqr   m_pkt_seqr      = null;
  axis_seqr_ctrl     m_seqr_ctrl     = null;

  // Transfer handlers
  axis_transfer_seqr m_transfer_seqr = null;
  axis_driver        m_drv           = null;
  axis_monitor       m_mon           = null;


  //  Group: Variables
  protected string   report_id       = "";


  //  Group: Functions

  function void build_phase(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase", this.report_id);

    super.build_phase(phase);

    `uvm_info(report_id, $sformatf("Starting build_phase for %s", this.get_full_name()), UVM_LOW)

    if (!uvm_config_db#(vif_t)::get(this, "", "vif", vif))
      `uvm_fatal(report_id, $sformatf("Unable to get vif for %s", get_full_name()))

    if (!uvm_config_db#(axis_config)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal(report_id, $sformatf("Error to get axis_config for %s", this.get_full_name()))

    // PACKET infra
    if (m_cfg.port == TRANSMITTER && m_cfg.has_pkt_seqr) begin
      `uvm_info(report_id, $sformatf("Creating sequence controller for '%s'.",
                                     this.get_full_name()), UVM_MEDIUM)
      m_seqr_ctrl = axis_seqr_ctrl::type_id::create("m_seqr_ctrl", this);
      `uvm_info(report_id, $sformatf("Creating packet sequencer for '%s'.", this.get_full_name()),
                UVM_MEDIUM)
      m_pkt_seqr = axis_packet_seqr::type_id::create("m_pkt_seqr", this);
    end

    // TRANSFER infra
    if (m_cfg.port == TRANSMITTER) begin
      `uvm_info(report_id, $sformatf("Creating transfer sequencer for '%s'.", this.get_full_name()),
                UVM_MEDIUM)
      m_transfer_seqr = axis_transfer_seqr::type_id::create("m_transfer_seqr", this);
    end

    // remaining components
    m_drv = axis_driver::type_id::create("m_drv", this);
    m_mon = axis_monitor::type_id::create("m_mon", this);

    `uvm_info(report_id, $sformatf("Finishing build_phase for %s", this.get_full_name()), UVM_LOW)

  endfunction : build_phase


  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (m_cfg.port == TRANSMITTER) begin
      m_drv.seq_item_port.connect(m_seqr.seq_item_export);

      // CTRL: add handles to each seqr
      if (m_cfg.has_pkt_seqr) begin
        m_seqr_ctrl.pkt_seqr = m_pkt_seqr;
        m_seqr_ctrl.transfer_seqr = m_transfer_seqr;
      end
    end
  endfunction : connect_phase


  //  Constructor: new
  function new(string name = "axis_agent", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new

endclass : axis_agent

