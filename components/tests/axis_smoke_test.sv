`ifndef axis_smoke_test__sv
`define axis_smoke_test__sv


class axis_smoke_test extends axis_test_base;
  `uvm_component_utils(axis_smoke_test)

  function new(string name = "axis_smoke_test", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new

  /* Function: build_phase_create_cfg

    Description:
      - Creates the agent configuration objects and sets them in the env configuration
  */
  function void build_phase_create_cfg(uvm_phase phase);
    axis_config cfg_item_master, cfg_item_slave;
    string report_id = $sformatf("%s.build_phase_create_cfg", this.report_id);

    cfg_item_master = axis_config::type_id::create("cfg_item_master");
    cfg_item_slave = axis_config::type_id::create("cfg_item_slave");

    cfg_item_master.vip_id = 0;
    cfg_item_slave.vip_id = 1;

    cfg_item_master.set_options(.device_type(TRANSMITTER), .use_packets(1), .use_transfers(0),
                                .stream_type(CONT_UNALIGNED), .TKEEP_ENABLE(1), .TSTRB_ENABLE(1));
    cfg_item_slave.set_options(.device_type(RECEIVER), .use_packets(1), .use_transfers(0),
                               .stream_type(CONT_UNALIGNED), .TKEEP_ENABLE(1), .TSTRB_ENABLE(1));

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


  function randomize_n_samples();
    m_env_cfg.num_samples = 10;
    m_env_cfg.seq_size = 10;
    m_env_cfg.fixed_seq_size = 1;
    `uvm_info(report_id, $sformatf("Running %0d samples", m_env_cfg.num_samples), UVM_NONE)
  endfunction : randomize_n_samples


  /* Function: randomize seq

    Description:
      - Randomizes a sequence.
      - Constraints should be set here.
  */
  function randomize_seq(int i, ref axis_config agt_config, ref axis_transfer_seq tseq,
                         ref axis_packet_seq pseq, int seq_size);
    if (agt_config.use_transfers) begin
      case (agt_config.device_type)
        RECEIVER: begin
          if (!tseq.randomize() with {delay == 0;})
            `uvm_fatal(report_id, "Unable to randomize seq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized transfer for %s \n%s", agt_config.device_type.name, tseq.sprint()),
                    UVM_NONE)
        end  // receiver
        TRANSMITTER: begin
          if (!tseq.randomize() with {delay == 0;})
            `uvm_fatal(report_id, "Unable to randomize tseq.")
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
          if (!pseq.randomize() with {
                size == m_env_cfg.seq_size;
                foreach (delays[i]) delays[i] != 0;
              })
            `uvm_fatal(report_id, "Unable to randomize pseq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized packet for %s: \n%s", agt_config.device_type.name, pseq.sprint()),
                    UVM_NONE)
        end  // receiver
        TRANSMITTER: begin
          if (!pseq.randomize() with {
                size == seq_size;
                foreach (delays[i]) delays[i] == 0;
              })
            `uvm_fatal(report_id, "Unable to randomize seq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized packet for %s: \n%s", agt_config.device_type.name, pseq.sprint()),
                    UVM_NONE)
        end  // transmitter
        default: `uvm_fatal(report_id, "Invalid device type.")
      endcase
    end  // if

  endfunction


endclass : axis_smoke_test

`endif
