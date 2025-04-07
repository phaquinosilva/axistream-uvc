//==============================================================================
// Project: axis VIP
//==============================================================================
// Filename: axis_test_base.sv
// Description: This file comprises the base test for the axis integration env.
//==============================================================================
`ifndef axis_test_base__sv
`define axis_test_base__sv


class axis_test_base extends uvm_component;
  `uvm_component_utils(axis_test_base)

  //  Group: Configuration Object(s)
  axis_integ_config m_env_cfg;

  //  Group: Components
  axis_integ_env m_env;

  //  Group: Objects
  axis_packet_seq pseq[];
  axis_transfer_seq tseq[];
  axis_vseq vseq[];

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

    cfg_item_master = axis_config::type_id::create("cfg_item_master");
    cfg_item_slave = axis_config::type_id::create("cfg_item_slave");

    cfg_item_master.vip_id = 0;
    cfg_item_slave.vip_id = 1;

    cfg_item_master.set_options(.device_type(TRANSMITTER));
    cfg_item_slave.set_options(.device_type(RECEIVER));

    m_env_cfg = axis_integ_config::type_id::create(.name("m_env_cfg"));
    m_env_cfg.has_scoreboard = 1;
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
    axis_config agt_config;
    super.connect_phase(phase);
    `uvm_info(report_id, $sformatf("Starting connect_phase for %s.", this.get_full_name()),
              UVM_NONE)

    vseq = new[m_env_cfg.get_n_agts()];
    pseq = new[m_env_cfg.get_n_agts()];
    tseq = new[m_env_cfg.get_n_agts()];

    foreach (m_env.m_agts[i]) begin
      agt_config = m_env.m_agts[i].m_cfg;

      vseq[i] = axis_vseq::type_id::create($sformatf("vseq[%0d]", i));
      vseq[i].setup_vseq(agt_config, m_env.m_agts[i].m_transfer_seqr);

      if (agt_config.use_transfers) begin
        tseq[i] = axis_transfer_seq::type_id::create($sformatf("tseq[%1d]", i));
        tseq[i].set_only_delay(agt_config.device_type == RECEIVER);
        vseq[i].m_transfer_seq = tseq[i];
      end

      if (agt_config.use_packets) begin
        pseq[i] = axis_packet_seq::type_id::create($sformatf("vseq[%1d]", i));
        pseq[i].set_stream_type(agt_config.stream_type);
        pseq[i].set_only_delay(agt_config.device_type == RECEIVER);
        vseq[i].m_pkt_seq = pseq[i];
      end
    end  // foreach

    `uvm_info(report_id, $sformatf("Finishing connect_phase for %s.", this.get_full_name()),
              UVM_NONE)

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
    phase.raise_objection(this);
    `uvm_info(report_id, $sformatf("Starting run_phase for %s, objection raised.",
                                   this.get_full_name()), UVM_NONE)

    randomize_n_samples();
    for (int i = 0; i < m_env_cfg.get_n_agts(); i++) begin
      automatic int _i = i;
      fork
        begin : SEQ
          repeat (m_env_cfg.num_samples) begin
            if (!m_env_cfg.fixed_seq_size) begin
              if (!m_env_cfg.randomize(seq_size) with {seq_size inside {[1 : 100]};})
                `uvm_fatal(report_id, "Unable to randomize seq_size")
              `uvm_info(report_id, $sformatf("Sending packet of size: %0d transfers",
                                             m_env_cfg.seq_size), UVM_NONE)
            end

            randomize_seq(_i, m_env.m_agts[_i].m_cfg, tseq[_i], pseq[_i], m_env_cfg.seq_size);
            vseq[_i].start(null);
          end
        end  // repeat
      join_none
    end
    wait fork;

    #(2 * m_env_cfg.num_samples * m_env_cfg.seq_size);

    phase.drop_objection(this);
    `uvm_info(report_id, $sformatf("Finished run_phase for %s, objection dropped.",
                                   this.get_full_name()), UVM_NONE)
  endtask : run_phase


  /* Function: randomize n_samples

    Description:
      - Randomizes a number of samples and sequence size for test.
      - If sequence
      - Constraints should be set here.
  */
  virtual function void randomize_n_samples();

    if (m_env_cfg.num_samples == 0)
      if (!m_env_cfg.randomize(num_samples) with {num_samples inside {[2 : 100]};})
        `uvm_fatal(report_id, "Unable to randomize num_samples")
    `uvm_info(report_id, $sformatf("Running %0d samples", m_env_cfg.num_samples), UVM_NONE)

    if (m_env_cfg.fixed_seq_size) begin
      if (m_env_cfg.seq_size == 0)
        if (!m_env_cfg.randomize(seq_size) with {seq_size inside {[2 : 100]};})
          `uvm_fatal(report_id, "Unable to randomize seq_size")
      `uvm_info(report_id, $sformatf("Running %0d samples", m_env_cfg.num_samples), UVM_NONE)
    end

  endfunction : randomize_n_samples

  /* Function: randomize seq

    Description:
      - Randomizes a sequence.
      - Constraints should be set here.
  */
  virtual function void randomize_seq(int i, ref axis_config agt_config, ref axis_transfer_seq tseq,
                                      ref axis_packet_seq pseq, int seq_size);
    `uvm_info("axis_test_base", "started randomize", UVM_NONE)
    if (agt_config.use_transfers) begin
      case (agt_config.device_type)
        RECEIVER: begin
          if (!tseq.randomize()) `uvm_fatal(report_id, "Unable to randomize seq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized transfer for %s \n%s", agt_config.device_type.name, tseq.sprint()),
                    UVM_NONE)
        end  // receiver
        TRANSMITTER: begin
          if (!tseq.randomize()) `uvm_fatal(report_id, "Unable to randomize tseq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized transfer for %s \n%s", agt_config.device_type.name, tseq.sprint()),
                    UVM_NONE)
        end  // transmitter
        default: `uvm_fatal(report_id, "Invalid device type.")
      endcase
    end

    if (agt_config.use_packets) begin
      case (agt_config.device_type)
        RECEIVER: begin
          if (!pseq.randomize() with {size == seq_size;})
            `uvm_fatal(report_id, "Unable to randomize pseq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized packet for %s: \n%s", agt_config.device_type.name, pseq.sprint()),
                    UVM_NONE)
        end  // receiver
        TRANSMITTER: begin
          if (!pseq.randomize() with {size == seq_size;})
            `uvm_fatal(report_id, "Unable to randomize seq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized packet for %s: \n%s", agt_config.device_type.name, pseq.sprint()),
                    UVM_NONE)
        end  // transmitter
        default: `uvm_fatal(report_id, "Invalid device type.")
      endcase
    end  // if

  endfunction : randomize_seq

endclass : axis_test_base

`endif
