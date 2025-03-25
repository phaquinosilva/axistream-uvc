//  Class: axis_transfer_base_test
//
class axis_transfer_base_test extends uvm_test;
  `uvm_component_utils(axis_transfer_base_test)

  //  Group: Components
  axis_env m_env;

  axis_config m_cfg_transmitter;
  axis_config m_cfg_receiver;

  //  Group: Variables
  string report_id = "";


  //  Group: Functions
  function void build_phase(uvm_phase phase);
    string report = $sformatf("%s.build_phase", report_id);
    super.build_phase(phase);
    `uvm_info(report, $sformatf("Starting build_phase for %s", get_full_name()), UVM_NONE)

    m_cfg_transmitter = axis_config::type_id::create(.name("m_cfg_transmitter"));
    m_cfg_receiver = axis_config::type_id::create(.name("m_cfg_receiver"));

    m_cfg_transmitter.vip_id = 0;
    m_cfg_transmitter.device_type = TRANSMITTER;
    m_cfg_transmitter.use_packets = 0;

    m_cfg_receiver.vip_id = 1;
    m_cfg_receiver.device_type = RECEIVER;
    m_cfg_receiver.use_packets = 0;

    m_env = axis_env::type_id::create("m_env", this);

    uvm_config_db#(axis_config)::set(this, "m_env.m_agt_transmitter*", "m_cfg", m_cfg_transmitter);
    uvm_config_db#(axis_config)::set(this, "m_env.m_agt_receiver*", "m_cfg", m_cfg_receiver);

    `uvm_info(report, $sformatf("Finishing build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase


  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  //  Constructor: new
  function new(string name = "axis_transfer_base_test", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new

endclass : axis_transfer_base_test
