//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axi_s_agent.sv
// Description: This file comprises the AXI-Stream agent for the AXI-Stream VIP.
//==============================================================================

class axi_s_agent extends uvm_agent;
  `uvm_component_utils(axi_s_agent)

  //  Group: Components
  axi_s_sequencer m_seqr;
  axi_s_driver    m_drv;
  axi_s_monitor   m_mon;

  //  Group: Variables
  axi_s_config    m_cfg;

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s", get_full_name()), UVM_NONE)

    if (!uvm_config_db#(axi_s_config)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal("AGT_CFG", $sformatf("Error to get axi_s_config for %s", get_full_name()))

    if (m_cfg.port == TRANSMITTER) begin
      m_seqr = axi_s_sequencer::type_id::create("m_seqr", this);
    end
    m_drv  = axi_s_driver::type_id::create("m_drv", this);
    m_mon = axi_s_monitor::type_id::create("m_mon", this);

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
  function new(string name = "axi_s_agent", uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : axi_s_agent

