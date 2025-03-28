//==============================================================================
// Project: axis VIP
//==============================================================================
// Filename: axis_test_base.sv
// Description: This file comprises the base test for the axis integration env.
//==============================================================================

//  Class: axis_integ_test_base
//
class axis_test_base extends uvm_component;
  `uvm_component_utils(axis_test_base)

  //  Group: Configuration Object(s)
  axis_integ_config m_env_cfg;

  //  Group: Components
  axis_integ_env m_env;

  //  Group: Variables
  protected string report_id = "";

  //  Constructor: new
  function new(string name = "axis_test_base", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new

  // ===========================================================================
  // =============================== build_phase ===============================
  // ===========================================================================

  /* Function: build_phase

    Description:
      - Calls the sub-phases for the build_phase.
  */
  virtual function void build_phase(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase", this.report_id);

    super.build_phase(phase);

    `uvm_info(report_id, $sformatf("Starting build_phase for %s", this.get_full_name()), UVM_LOW)

    build_phase_create_cfg(phase);
    build_phase_create_components(phase);
    build_phase_uvm_config_db(phase);

    `uvm_info(report_id, $sformatf("Finished build_phase for %s", this.get_full_name()), UVM_LOW)

  endfunction : build_phase

  /* Function: build_phase_create_cfg

    Description:
      - Creates the agent configuration objects and sets them in the env configuration
  */
  virtual function void build_phase_create_cfg(uvm_phase phase);
    axis_config cfg_item_master, cfg_item_slave;
    string report_id = $sformatf("%s.build_phase_create_cfg", this.report_id);
    // `uvm_info(report_id, "Creating configurations.", UVM_LOW)


    cfg_item_master = axis_config::type_id::create("cfg_item_master");
    cfg_item_master.vip_id = 0;
    cfg_item_master.set_options(.device_type(TRANSMITTER), .use_packets(1));

    cfg_item_slave = axis_config::type_id::create("cfg_item_slave");
    cfg_item_slave.vip_id = 1;
    cfg_item_slave.set_options(.device_type(RECEIVER), .use_packets(1));

    m_env_cfg = axis_integ_config::type_id::create(.name("m_env_cfg"));
    m_env_cfg.set_agt_configs(2, '{cfg_item_master, cfg_item_slave});
    `uvm_info(
        report_id, $sformatf(
        "Created config items for %1d agents in %s.", m_env_cfg.get_n_agts(), this.get_full_name()),
        UVM_LOW)

    for (int i = 0; i < m_env_cfg.get_n_agts(); i++) begin
      `uvm_info(report_id, $sformatf(
                "axis_config item_%1d : \n%s", i, m_env_cfg.get_config(i).sprint()), UVM_FULL)
    end
  endfunction : build_phase_create_cfg


  /* Function: build_phase_create_components

    Description:
      -
  */
  virtual function void build_phase_create_components(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase_create_components", this.report_id);

    m_env = axis_integ_env::type_id::create("m_env", this);

  endfunction : build_phase_create_components

  /* Function: build_phase_uvm_config_db

    Description:
      -
  */
  virtual function void build_phase_uvm_config_db(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase_uvm_config_db", this.report_id);

    for (int i = 0; i < m_env_cfg.get_n_agts(); i++) begin
      uvm_config_db#(axis_config)::set(this, $sformatf("m_env.m_agts[%1d]*", i), "m_cfg",
                                       m_env_cfg.get_config(i));
      `uvm_info(report_id, $sformatf(
                "Added Agent config item into the uvm_config_db %1d/%1d", i, m_env_cfg.get_n_agts()
                ), UVM_LOW)
    end
    uvm_config_db#(axis_integ_config)::set(this, "m_env", "m_cfg", m_env_cfg);


  endfunction : build_phase_uvm_config_db


  // ===========================================================================
  // ============================== connect_phase ==============================
  // ===========================================================================

  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

  endfunction : connect_phase


  // ===========================================================================
  // ========================= end_of_elaboration_phase ========================
  // ===========================================================================

  /* Function: end_of_elaboration_phase

    Description:
      - Print the test topology.
  */
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (uvm_top.get_report_verbosity_level() > UVM_LOW) uvm_top.print_topology();
  endfunction : end_of_elaboration_phase


  // ===========================================================================
  // ================================= run_phase ===============================
  // ===========================================================================

  /* Function: run_phase

    Description:
      - Sanity test for the environment.
      - Randomizes a sequence and starts it.
  */
  task run_phase(uvm_phase phase);
    int num_samples;
    axis_packet_seq seq;
    // axis_transfer_seq seq;

    `uvm_info(get_name(), $sformatf("Starting run_phase for %s, objection raised.",
                                    this.get_full_name()), UVM_NONE)

    foreach (m_env.m_agts[i]) begin
      if (m_env.m_agts[i].m_cfg.device_type == RECEIVER) continue;
      if (!std::randomize(num_samples) with {num_samples inside {[2 : 10]};})
        `uvm_fatal(report_id, "Unable to randomize num_samples")

      `uvm_info(report_id, $sformatf("Running %0d samples", num_samples), UVM_NONE)

      seq = axis_packet_seq::type_id::create($sformatf("seq_%1d", i));
      // seq = axis_transfer_seq::type_id::create("seq");

      phase.raise_objection(this);

      #10;
      repeat (num_samples) begin
        if (!seq.randomize() with {size == 10;}) `uvm_fatal(report_id, "Unable to randomize seq.")
        `uvm_info(report_id, $sformatf("Randomized packet %s", seq.sprint()), UVM_NONE)
        seq.start(m_env.m_agts[i].m_transfer_seqr);
      end
    end

    #10ms;

    phase.drop_objection(this);

    `uvm_info(get_name(), $sformatf("Finished run_phase for %s, objection dropped.",
                                    this.get_full_name()), UVM_NONE)
  endtask : run_phase


endclass : axis_test_base
