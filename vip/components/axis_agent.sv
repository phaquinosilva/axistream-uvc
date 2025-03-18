//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_agent.sv
// Description: This file comprises the AXI-Stream agent for the AXI-Stream VIP.
//==============================================================================

class axis_agent extends uvm_agent;
  `uvm_component_utils(axis_agent)

  //  Group: Components
  axis_transfer_seqr m_seqr;
  axis_driver    m_drv;
  axis_monitor   m_mon;

  //  Group: Variables
  axis_config    m_cfg;

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s", get_full_name()), UVM_NONE)

    if (!uvm_config_db#(axis_config)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal("AGT_CFG", $sformatf("Error to get axis_config for %s", get_full_name()))

    if (m_cfg.port == TRANSMITTER) begin
      m_seqr = axis_transfer_seqr::type_id::create("m_seqr", this);
    end
    m_drv  = axis_driver::type_id::create("m_drv", this);
    m_mon = axis_monitor::type_id::create("m_mon", this);

    `uvm_info("END_PHASE", $sformatf("Finishing build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting connect_phase for %s", get_full_name()), UVM_NONE)

    if (m_cfg.port == TRANSMITTER) begin
      m_drv.seq_item_port.connect(m_seqr.seq_item_export);
    end

    `uvm_info("END_PHASE", $sformatf("Finishing connect_phase for %s", get_full_name()), UVM_NONE)
  endfunction : connect_phase


  //  Constructor: new
  function new(string name = "axis_agent", uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : axis_agent

