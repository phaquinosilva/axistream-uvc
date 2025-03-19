//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_seqr_ctrl.sv
// Description: sequencer controller, deals with sending transfers from a packet
// to the transfer driver.
//==============================================================================

class axis_seqr_ctrl extends uvm_component;
    `uvm_component_utils(axis_seqr_ctrl);

    //  Group: Configuration Object(s)
    axis_config m_cfg;

    //  Group: Components
    axis_packet_seqr pkt_seqr = null;
    axis_transfer_seqr transfer_seqr = null;

    //  Group: Variables
    protected string report_id = "";

    //  Group: Functions

    //  Constructor: new
    function new(string name = "axis_seqr_ctrl", uvm_component parent);
        super.new(name, parent);
        this.report_id = name;
    endfunction: new

    function void build_phase(uvm_phase phase);
        string report_id = $sformatf("%s.build_phase", this.report_id);
        super.build_phase(phase);

        if (!uvm_config_db#(axis_config)::get(this, "", "cfg", m_cfg))
        `uvm_fatal(report_id,
                  $sformatf("Unable to retrieve configuration item for '%s'.",
                  this.get_full_name()))
    endfunction: build_phase


    task run_phase(uvm_phase phase);
      string report_id = $sformatf("%s.run_phase", this.report_id);

      axis_packet2transfer_seq seq;

      `uvm_info(report_id, $sformatf("<run_phase> started for %s.",
      this.get_full_name), UVM_LOW)

      if (pkt_seqr == null)
        `uvm_fatal(report_id,
                  $sformatf("txn_seqr not initialized correctly for %s.",
                  this.get_full_name()))

      if (transfer_seqr == null)
        `uvm_fatal(report_id,
                  $sformatf("beat_seqr not initialized correctly for %s.",
                  this.get_full_name()))

      seq = axis_packet2transfer_seq::type_id::create("packet2transfer_seq");
      seq.pkt_seqr = pkt_seqr;
      seq.start(transfer_seqr);

      `uvm_info(report_id, $sformatf("<run_phase> finished for %s.",
          this.get_full_name), UVM_LOW)
    endtask: run_phase

endclass: axis_seqr_ctrl
