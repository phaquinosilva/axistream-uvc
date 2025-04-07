`ifndef axis_transfer2packet_subs__sv
`define axis_transfer2packet_subs__sv

class axis_transfer2packet_subs extends uvm_subscriber #(axis_transfer);

  `uvm_component_utils(axis_transfer2packet_subs)

  //  Group: Configuration Object(s)
  axis_config m_cfg;

  //  Group: Variables
  protected string report_id = "";

  //  Group: Components

  /* axis_transfer_imp:
  *   - used to receive data from the axis_monitor.
  *   - Receives axis_transfer objects.
  */
  uvm_analysis_imp #(axis_transfer, axis_transfer2packet_subs) axis_transfer_imp;

  /* axis_packet_a:
  *   - Used to send full packet out of the monitor.
  *   - The packet object corresponds to multiple axis_transfer instances.
  */
  uvm_analysis_port #(axis_packet) axis_packet_ap;

  /* transfers: queue of received axis_transfer objects. */
  protected axis_transfer transfers[$];
  /* ongoing: flag to indicate ongoing transaction. */
  protected bit ongoing = 0;

  //  Group: Functions

  function void build_phase(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase", this.report_id);
    super.build_phase(phase);

    `uvm_info(report_id, $sformatf("Started build_phase for %s.", this.get_full_name()), UVM_HIGH)
    if (!uvm_config_db#(axis_config)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal(report_id, $sformatf("Unable to retrieve config for %s.", this.get_full_name()));

    if (!m_cfg.use_packets) `uvm_fatal(report_id, "Agent is not setup to use packets.")

    axis_transfer_imp = new("axis_transfer_imp", this);
    axis_packet_ap = new("axis_packet_ap", this);

    `uvm_info(report_id, $sformatf("Finished build_phase for %s.", this.get_full_name()), UVM_HIGH)
  endfunction : build_phase


  virtual function void write(axis_transfer t);
    string report_id = $sformatf("%s.write", this.report_id);
    `uvm_info(report_id, $sformatf("Received axis_transfer in %s.", this.get_full_name()), UVM_HIGH)
    `uvm_info(report_id, $sformatf("Received transfer:\n%s", t.sprint()), UVM_DEBUG)

    if (!this.ongoing) ongoing = 1;

    this.transfers.push_back(t);
    if (t.tlast == 1) publish_packet();
  endfunction : write


  /* publish_packet:
  *    - Uses the transfer queue to rebuild received packets and writes it in
  *    the packet analysis port.
  *    - Single transfers are converted to packets with size 1.
  *    - NOTE: Does NOT support transfer interleaving, i.e. only supports continuous packets.
  */
  function void publish_packet();
    string report_id = $sformatf("%s.publish_packet", this.report_id);
    axis_packet pkt = axis_packet::type_id::create("axis_packet");

    `uvm_info(report_id, $sformatf(
              "Publishing complete axis_packet received in %s.", this.get_full_name()), UVM_HIGH)

    while (transfers.size() > 0) begin
      axis_transfer trn = transfers.pop_front();
      pkt.transfers.push_back(trn);
    end
    pkt.extract_data(m_cfg);

    this.ongoing = 0;
    axis_packet_ap.write(pkt);
  endfunction : publish_packet


  //  Group: Tasks

  function new(string name = "axis_transfer2packet_subs", uvm_component parent);
    super.new(name, parent);

    this.report_id = name;
  endfunction

endclass : axis_transfer2packet_subs

`endif
