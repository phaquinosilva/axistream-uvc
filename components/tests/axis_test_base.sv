//==============================================================================
// Project: axis VIP
//==============================================================================
// Filename: axis_test_base.sv
// Description: This file comprises the base test for the axis integration env.
//==============================================================================
`ifndef axis_test_base__sv
`define axis_test_base__sv

`define PACKET_SIZE 10
`define N_SAMPLES 5

class axis_test_base extends uvm_component;
  `uvm_component_utils(axis_test_base)

  //  Group: Configuration Obaect(s)
  axis_integ_config m_env_cfg;

  //  Group: Components
  axis_integ_env m_env;

  //  Group: Objects
  axis_packet_seq pseq[];
  axis_transfer_seq tseq[];
  axis_vseq vseq;

  //  Group: Variables
  protected string report_id = "";
  protected int num_samples;
  protected int seq_size;

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

    cfg_item_master.set_options(.device_type(TRANSMITTER), .use_packets(1), .use_transfers(0),
                                .stream_type(SPARSE), .TID_ENABLE(0), .TDEST_ENABLE(0),
                                .TUSER_ENABLE(0));
    cfg_item_slave.set_options(.device_type(RECEIVER), .use_packets(1), .use_transfers(0),
                               .stream_type(SPARSE), .TID_ENABLE(0), .TDEST_ENABLE(0),
                               .TUSER_ENABLE(0));

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
    super.connect_phase(phase);

  endfunction : connect_phase

  // ===========================================================================
  // ========================= end_of_elaboration_phase ========================
  // ===========================================================================

  /* Function: end_of_elaboration_phase

    Description:
      - 
  */
  function void end_of_elaboration_phase(uvm_phase phase);
    axis_config agt_config;
    super.end_of_elaboration_phase(phase);
    `uvm_info(report_id, $sformatf("Starting end_of_elaboration_phase for %s.", this.get_full_name()
              ), UVM_NONE)

    vseq = axis_vseq::type_id::create("vseq");

    vseq.setup_vseq(m_env_cfg);
    pseq = new[m_env_cfg.get_n_agts()];
    tseq = new[m_env_cfg.get_n_agts()];

    foreach (m_env.m_agts[i]) begin
      vseq.m_transfer_seqr[i] = m_env.m_agts[i].m_transfer_seqr;
      agt_config = m_env.m_agts[i].m_cfg;
      if (agt_config.use_transfers) begin
        tseq[i] = axis_transfer_seq::type_id::create($sformatf("tseq[%1d]", i));
        if (agt_config.device_type == RECEIVER) pseq[i].set_only_delay(1);
        vseq.m_transfer_seq[i] = tseq[i];
      end
      if (agt_config.use_packets) begin
        pseq[i] = axis_packet_seq::type_id::create($sformatf("vseq[%1d]", i));
        pseq[i].set_stream_type(agt_config.stream_type);

        // Set constraints to only randomize the delays in the receiver agent
        if (agt_config.device_type == RECEIVER) pseq[i].set_only_delay(1);

        vseq.m_pkt_seq[i] = pseq[i];
      end
    end  // foreach

    `uvm_info(report_id, $sformatf(
              "Finishing end_of_elaboration_phase for %s.", this.get_full_name()), UVM_NONE)

  endfunction : end_of_elaboration_phase


  // ===========================================================================
  // ========================= start_of_simulation_phase =======================
  // ===========================================================================

  /* Function: start_of_simulation_phase

    Description:
      - Print the test topology.
  */
  function void start_of_simulation_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (uvm_top.get_report_verbosity_level() > UVM_LOW) uvm_top.print_topology();
  endfunction : start_of_simulation_phase


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

    randomize_test_setup();
    repeat (num_samples) begin

      if (!m_env_cfg.fixed_seq_size) begin
        if (!std::randomize(seq_size) with {seq_size inside {[2 : 100]};})
          `uvm_fatal(report_id, "Unable to randomize seq_size")
        `uvm_info(report_id, $sformatf("Running %0d samples", num_samples), UVM_NONE)
      end

      foreach (m_env.m_agts[i]) begin
        randomize_seq(i, m_env.m_agts[i].m_cfg, tseq, pseq, seq_size);
      end
      vseq.start(null);

    end  // repeat

    #(2 * num_samples * seq_size);

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
  virtual function randomize_test_setup();
`ifdef N_SAMPLES
    num_samples = `N_SAMPLES;
`else
    if (!std::randomize(num_samples) with {num_samples inside {[2 : 100]};})
      `uvm_fatal(report_id, "Unable to randomize num_samples")
`endif

    `uvm_info(report_id, $sformatf("Running %0d samples", num_samples), UVM_NONE)
`ifdef PACKET_SIZE
    seq_size = `PACKET_SIZE;
`else
    if (m_env_cfg.fixed_seq_size) begin
      if (!std::randomize(seq_size) with {seq_size inside {[2 : 100]};})
        `uvm_fatal(report_id, "Unable to randomize seq_size")
    end
`endif

  endfunction : randomize_test_setup


  /* Function: randomize seq

    Description:
      - Randomizes a sequence.
      - Constraints should be set here.
  */
  virtual function randomize_seq(int i, ref axis_config agt_config, ref axis_transfer_seq tseq[],
                                 ref axis_packet_seq pseq[], int seq_size);

    if (agt_config.use_transfers) begin
      case (agt_config.device_type)
        RECEIVER: begin
          if (!tseq[i].randomize() with {
                tdata == 0;
                tkeep == 0;
                tstrb == 0;
                tid == 0;
                tuser == 0;
                tdest == 0;
              })
            `uvm_fatal(report_id, "Unable to randomize seq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized transfer for %s \n%s", agt_config.device_type.name, tseq[i].sprint()
                    ), UVM_NONE)
        end  // receiver
        TRANSMITTER: begin
          if (!tseq[i].randomize()) `uvm_fatal(report_id, "Unable to randomize tseq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized transfer for %s \n%s", agt_config.device_type.name, tseq[i].sprint()
                    ), UVM_NONE)
        end  // transmitter
        default: `uvm_fatal(report_id, "Invalid device type.")
      endcase
    end

    if (agt_config.use_packets) begin
      case (agt_config.device_type)
        RECEIVER: begin
          if (!pseq[i].randomize()) `uvm_fatal(report_id, "Unable to randomize pseq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized packet for %s: \n%s", agt_config.device_type.name, pseq[i].sprint()
                    ), UVM_NONE)
        end  // receiver
        TRANSMITTER: begin
          if (!pseq[i].randomize() with {size == seq_size;})
            `uvm_fatal(report_id, "Unable to randomize seq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized packet for %s: \n%s", agt_config.device_type.name, pseq[i].sprint()
                    ), UVM_NONE)
        end  // transmitter
        default: `uvm_fatal(report_id, "Invalid device type.")
      endcase
    end  // if

  endfunction : randomize_seq

endclass : axis_test_base

`endif
