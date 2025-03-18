//  Class: axis_base_test
//
class axis_base_test extends uvm_test;
  `uvm_component_utils(axis_base_test)

  //  Group: Components
  axis_env m_env;
  // axis_scoreboard m_scbd;

  axis_config m_cfg_transmitter;
  axis_config m_cfg_receiver;

  //  Group: Variables
  vif_t vif;

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s", get_full_name()), UVM_NONE)

    m_cfg_transmitter = axis_config::type_id::create(.name("m_cfg_transmitter"));
    m_cfg_receiver = axis_config::type_id::create(.name("m_cfg_receiver"));

    m_cfg_transmitter.port = TRANSMITTER;
    m_cfg_transmitter.vip_id = 0;

    m_cfg_receiver.port = RECEIVER;
    m_cfg_receiver.vip_id = 1;

    m_env = axis_env::type_id::create("m_env", this);
    // m_scbd = axis_scoreboard::type_id::create("m_scbd", this);

    if (!uvm_config_db#(vif_t)::get(this, "", "vif", vif))
      `uvm_fatal("TEST_IF", $sformatf("Unable to get vif for %s", get_full_name()))

    uvm_config_db#(vif_t)::set(this, "m_env.m_agt*", "vif", vif);

    uvm_config_db#(axis_config)::set(this, "m_env.m_agt_transmitter*",
                                      "m_cfg", m_cfg_transmitter);
    uvm_config_db#(axis_config)::set(this, "m_env.m_agt_receiver*",
                                      "m_cfg", m_cfg_receiver);

    `uvm_info("END_PHASE", $sformatf("Finishing build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase


  // function void connect_phase(uvm_phase phase);
  //   super.connect_phase(phase);
  //   `uvm_info("START_PHASE", $sformatf("Starting connect_phase for %s", get_full_name()), UVM_NONE)

  //   m_env.m_agt_transmitter.m_mon.mon_analysis_port.connect(m_scbd.imp_transmitter);
  //   m_env.m_agt_receiver.m_mon.mon_analysis_port.connect(m_scbd.imp_receiver);

  //   `uvm_info("END_PHASE", $sformatf("Finishing connect_phase for %s", get_full_name()), UVM_NONE)
  // endfunction : connect_phase


  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  //  Constructor: new
  function new(string name = "axis_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : axis_base_test
