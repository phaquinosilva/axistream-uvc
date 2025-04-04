
class axis_packet_subs extends uvm_subscriber #(axis_transfer);

  `uvm_component_utils(axis_packet_subs)

  //  Group: Configuration Object(s)
  axis_config m_cfg;

  //  Group: Variables
  protected string report_id = "";

  //  Group: Components
  uvm_analysis_imp #(axis_transfer, axis_packet_subs) axis_transfer_ap;
  uvm_analysis_port #(axis_packet_seq) axis_packet_ap;


  //  Group: Functions


  //  Group: Tasks


  function new(string name = "axis_packet_subs", uvm_component parent);
    super.new(name, parent);

    this.report_id = name;
  endfunction

endclass : axis_packet_subs
