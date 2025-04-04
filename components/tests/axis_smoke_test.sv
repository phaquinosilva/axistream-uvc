`ifndef axis_smoke_test__sv
`define axis_smoke_test__sv


class axis_smoke_test extends axis_test_base;
  `uvm_component_utils(axis_smoke_test)

  function new(string name = "axis_smoke_test", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new

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
  function randomize_seq(int i, ref axis_config agt_config, ref axis_transfer_seq tseq[],
                         ref axis_packet_seq pseq[], int seq_size);
    if (agt_config.use_transfers) begin
      case (agt_config.device_type)
        RECEIVER: begin
          if (!tseq[i].randomize() with {
                // delay == 0;
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
                size == m_env_cfg.seq_size;
                foreach (delays[k]) delays[k] != 0;
              })
            `uvm_fatal(report_id, "Unable to randomize pseq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized packet for %s: \n%s", agt_config.device_type.name, pseq[i].sprint()
                    ), UVM_NONE)
        end  // receiver
        TRANSMITTER: begin
          if (!pseq[i].randomize() with {
                size == seq_size;
                foreach (p_data[k]) p_data[k] != 0;
                foreach (delays[k]) delays[k] == 0;
              })
            `uvm_fatal(report_id, "Unable to randomize seq.")
          `uvm_info(report_id, $sformatf(
                    "Randomized packet for %s: \n%s", agt_config.device_type.name, pseq[i].sprint()
                    ), UVM_NONE)
        end  // transmitter
        default: `uvm_fatal(report_id, "Invalid device type.")
      endcase
    end  // if

  endfunction


endclass : axis_smoke_test
`endif
