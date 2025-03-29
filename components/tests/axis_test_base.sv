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
  axis_vseq vseq;


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

    cfg_item_master.set_options(.device_type(TRANSMITTER), .use_packets(1), .use_transfers(0));
    cfg_item_slave.set_options(.device_type(RECEIVER), .use_packets(1), .use_transfers(0));

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
    axis_config agt_config;
    super.connect_phase(phase);
    `uvm_info(report_id, $sformatf("Starting connect_phase for %s.", this.get_full_name()),
              UVM_NONE)

    vseq = axis_vseq::type_id::create("vseq");
    vseq.setup_vseq(m_env_cfg);
    pseq = new[m_env_cfg.get_n_agts()];
    tseq = new[m_env_cfg.get_n_agts()];

    foreach (m_env.m_agts[i]) begin
      vseq.m_transfer_seqr[i] = m_env.m_agts[i].m_transfer_seqr;
      agt_config = m_env.m_agts[i].m_cfg;
      if (agt_config.use_transfers) begin
        tseq[i] = axis_transfer_seq::type_id::create($sformatf("tseq[%1d]", i));
        vseq.m_transfer_seq[i] = tseq[i];
      end
      if (agt_config.use_packets) begin
        pseq[i] = axis_packet_seq::type_id::create($sformatf("vseq[%1d]", i));
        vseq.m_pkt_seq[i] = pseq[i];
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
    int num_samples;
    int clk_period;
    int seq_size = 10;

    if (!uvm_config_db#(int)::get(null, "uvm_test_top.m_env", "CLK_PERIOD", clk_period))
      `uvm_fatal(report_id, "Unable to find clock period for test.")
    `uvm_info(report_id, $sformatf("Clock period for test is %1d.", clk_period), UVM_NONE)

    if (!std::randomize(num_samples) with {num_samples inside {[2 : 100]};})
      `uvm_fatal(report_id, "Unable to randomize num_samples")
    `uvm_info(report_id, $sformatf("Running %0d samples", num_samples), UVM_NONE)

    phase.raise_objection(this);
    `uvm_info(report_id, $sformatf("Starting run_phase for %s, objection raised.",
                                   this.get_full_name()), UVM_NONE)

    #clk_period;
    repeat (num_samples) begin
      foreach (m_env.m_agts[i]) begin
        randomize_seq(i, m_env.m_agts[i].m_cfg, tseq, pseq, seq_size);
      end
      vseq.start(null);
    end  // repeat

    // #(100 * num_samples * seq_size * clk_period);
    #1000;

    phase.drop_objection(this);

    `uvm_info(report_id, $sformatf("Finished run_phase for %s, objection dropped.",
                                   this.get_full_name()), UVM_NONE)
  endtask : run_phase



  /* Function: randomize seq

    Description:
      - Randomizes a sequence.
      - Constraints should be set here.
  */
  function randomize_seq(int i, ref axis_config agt_config, ref axis_transfer_seq tseq[],
                         ref axis_packet_seq pseq[], int seq_size);
    if (agt_config.use_transfers) begin
      case (agt_config.device_type)
        RECEIVER: begin
          if (!tseq[i].randomize() with {
                tdata == 0;
                tkeep == 0;
                tstrb == 0;
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
          if (!pseq[i].randomize() with {
                size == seq_size;
                foreach (p_data[k]) p_data[k] == 0;
                foreach (p_keep[k]) p_keep[k] == 0;
                foreach (p_strb[k]) p_strb[k] == 0;
              })
            `uvm_fatal(report_id, "Unable to randomize pseq.")
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

  endfunction

endclass : axis_test_base

`endif
