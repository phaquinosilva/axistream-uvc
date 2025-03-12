//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axi_s_monitor.sv
// Description: This file comprises the monitor of the AXI-Stream VIP.
//==============================================================================

class axi_s_monitor extends uvm_monitor;
  `uvm_component_utils(axi_s_monitor)

  //  Group: Components
  vif_t vif;

  //  Group: Variables
  uvm_analysis_port #(axi_s_transfer) mon_analysis_port;
  axi_s_config m_cfg;


  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s", get_full_name()), UVM_NONE)

    if (!uvm_config_db#(vif_t)::get(this, "", "vif", vif))
      `uvm_fatal("MON_IF", $sformatf("Error to get vif for %s", get_full_name()))

    if (!uvm_config_db#(axi_s_config)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal("MON_CFG", $sformatf("Error to get axi_s_config for %s", get_full_name()))

    mon_analysis_port = new("mon_analysis_port", this);

    `uvm_info("END_PHASE", $sformatf("Finishing build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("START_PHASE", $sformatf("run_phase for %s", get_full_name()), UVM_NONE);
    forever begin
      axi_s_transfer item;

      // TRANSMITTER monitor already knows the data is valid before TREADY is asserted
      if (m_cfg.port == TRANSMITTER)
        wait(vif.TVALID);
      else
        wait(vif.TVALID && vif.TREADY);

      @(posedge vif.ACLK);
      item = axi_s_transfer::type_id::create("item");
      item.tdata = vif.TDATA;
      item.tkeep = vif.TKEEP;
      `uvm_info($sformatf("MON_%s", m_cfg.port.name), $sformatf("ITEM \n%s", item.sprint()), UVM_FULL)
      mon_analysis_port.write(item);
    end

    `uvm_info("END_PHASE", $sformatf("run_phase for %s", get_full_name()), UVM_NONE)
  endtask : run_phase


  //  Constructor: new
  function new(string name = "axi_s_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : axi_s_monitor

