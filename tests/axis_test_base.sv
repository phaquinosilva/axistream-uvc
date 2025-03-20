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
  // axis_integ_config m_cfg;


  //  Group: Components
  axis_env m_env;
  axis_config m_cfg_transmitter;
  axis_config m_cfg_receiver;

  //  Group: Variables
  protected string report_id;

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
      - Creates the configuration object
  */
  virtual function void build_phase_create_cfg(uvm_phase phase);
    axis_config cfg_item_master, cfg_item_slave;
    string report_id = $sformatf("%s.build_phase_create_cfg", this.report_id);

    m_cfg_transmitter = axis_config::type_id::create("m_cfg_transmitter");
    m_cfg_receiver = axis_config::type_id::create("m_cfg_receiver");

    m_cfg_transmitter.port = TRANSMITTER;
    m_cfg_transmitter.vip_id = 0;
    m_cfg_transmitter.has_pkt_seqr = 1'b1;

    m_cfg_receiver.port = RECEIVER;
    m_cfg_receiver.vip_id = 1;
    m_cfg_receiver.has_pkt_seqr = 1'b0;

  endfunction : build_phase_create_cfg


  /* Function: build_phase_create_components

    Description:
      -
  */
  virtual function void build_phase_create_components(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase_create_components", this.report_id);

    m_env = axis_env::type_id::create("m_env", this);

  endfunction : build_phase_create_components

  /* Function: build_phase_uvm_config_db

    Description:
      -
  */
  virtual function void build_phase_uvm_config_db(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase_uvm_config_db", this.report_id);

    uvm_config_db#(axis_config)::set(this, "m_env.m_agt_transmitter*", "m_cfg", m_cfg_transmitter);
    uvm_config_db#(axis_config)::set(this, "m_env.m_agt_receiver*", "m_cfg", m_cfg_receiver);

    `uvm_info(report_id, $sformatf("Added Agent Config item into the uvm_config_db"), UVM_LOW)

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

    phase.raise_objection(this);

    `uvm_info(get_name(), $sformatf("Starting run_phase for %s, objection raised.",
                                    this.get_full_name()), UVM_NONE)


    if (!std::randomize(num_samples) with {num_samples inside {[2 : 10]};})
      `uvm_fatal(report_id, "Unable to randomize num_samples")

    `uvm_info(report_id, $sformatf("Running %0d samples", num_samples), UVM_NONE)

    // NOTE: THIS IS A WORKAROUND -- wait for reset to end
    #1;

    repeat (1) begin
      axis_packet_seq seq;
      seq = axis_packet_seq::type_id::create("seq");
      if (!seq.randomize()) `uvm_fatal(report_id, "Unable to randomize seq.")
      seq.start(m_env.m_vseqr.m_pkt_seqr);
    end

    #10000;

    phase.drop_objection(this);

    `uvm_info(get_name(), $sformatf("Finished run_phase for %s, objection dropped.",
                                    this.get_full_name()), UVM_NONE)
  endtask : run_phase


endclass : axis_test_base
