//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_driver.sv
// Description: This file comprises the driver of the AXI-Stream VIP.
// The driver is responsible to handle byte transfers, generated as axis_transfers
// by the axis_transfer_seq. Packets, frames, etc. are generated separately
// and must be sent to the driver explicitly for the relevant signals to be drived.
//==============================================================================

class axis_driver extends uvm_driver #(axis_transfer);
  `uvm_component_utils(axis_driver)

  //  Group: Components
  vif_t vif;

  //  Group: Config objects
  axis_config m_cfg;

  // Group: Variables
  protected string report_id = "";

  //  Constructor: new
  function new(string name = "axis_driver", uvm_component parent);
    super.new(name, parent);
    report_id = name;
  endfunction : new

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    `uvm_info("START_PHASE", $sformatf("build_phase for %s", get_full_name()), UVM_NONE)

    super.build_phase(phase);

    if (!uvm_config_db#(vif_t)::get(this, "", "vif", vif))
      `uvm_fatal("DRV_IF", $sformatf("Error to get vif for %s", get_full_name()))

    if (!uvm_config_db#(axis_config)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal("DRV_CFG", $sformatf("Error to get axis_config for %s", get_full_name()))

    `uvm_info("END_PHASE", $sformatf("build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // `uvm_info("START_PHASE", $sformatf("run_phase for %s", get_full_name()), UVM_NONE)

    case (m_cfg.port)
      TRANSMITTER: begin
        `uvm_info("START_PHASE",
          $sformatf("run_phase for TRANSMITTER."),
          UVM_LOW)
        run_phase_transmitter();
      end  // transmitter
      RECEIVER: begin
        `uvm_info("START_PHASE",
          $sformatf("run_phase for RECEIVER."),
          UVM_LOW)
        run_phase_receiver();
      end  // receiver
      default: `uvm_fatal("ERROR",
        $sformatf("Invalid m_cfg.port for %s.",
        this.get_full_name()))
    endcase  // m_config.port

    // `uvm_info("END_PHASE", $sformatf("run_phase for %s", get_full_name()), UVM_NONE)
  endtask : run_phase


  // Group: TRANSMITTER methods
  extern task run_phase_transmitter();
  extern task drive_transfer_transmitter(axis_transfer m_item);

  // Group: RECEIVER methods
  extern task run_phase_receiver();
  extern task drive_transfer_receiver();

endclass : axis_driver
