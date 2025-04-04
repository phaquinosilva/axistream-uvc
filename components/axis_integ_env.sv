`ifndef axis_integ_env__sv
`define axis_integ_env__sv 


class axis_integ_env extends uvm_env;
  `uvm_component_utils(axis_integ_env)

  //  Group: Configuration objects
  axis_integ_config m_cfg;

  //  Group: Components
  axis_scoreboard m_scbd = null;
  axis_agent m_agts[];

  vif_t vifs[];

  //  Group: Variables
  string report_id = "";

  //  Group: Functions

  /* build_phase:
  *    - create agents
  *    - create vseqr
  *    - fetch vif
  */
  function void build_phase(uvm_phase phase);
    string report = $sformatf("%s.build_phase", this.report_id);

    super.build_phase(phase);
    `uvm_info(report, $sformatf("Starting build_phase for %s", get_full_name()), UVM_NONE)

    if (!uvm_config_db#(axis_integ_config)::get(this, "", "m_cfg", m_cfg))
      `uvm_fatal(report, $sformatf("Error to get axis_integ_config for %s", this.get_full_name()))

    m_agts = new[m_cfg.get_n_agts()];
    vifs   = new[m_cfg.get_n_agts()];

    foreach (m_agts[i]) begin
      string agt_id = $sformatf("m_agts[%1d]", i);
      m_agts[i] = axis_agent::type_id::create(agt_id, this);

      uvm_config_db#(axis_config)::get(this, $sformatf("%s*", agt_id), "m_cfg", m_agts[i].m_cfg);
      `uvm_info(report_id, $sformatf(
                "Agent configuration Configuration:\n%s", m_agts[i].m_cfg.sprint()), UVM_MEDIUM)

      if (!uvm_config_db#(vif_t)::get(this, "", $sformatf("vifs[%1d]", i), vifs[i]))
        `uvm_fatal(
            report, $sformatf(
            "Unable to get virtual interface vifs[%1d] for agent %s", i, m_agts[i].get_full_name()))

      uvm_config_db#(vif_t)::set(this, $sformatf("%s*", agt_id), "vif", vifs[i]);
    end

    if (m_cfg.has_scoreboard) begin
      if (m_cfg.get_n_agts() == 2) begin
        m_scbd = axis_scoreboard::type_id::create("m_scbd", this);

        m_scbd.m_cfg_transmitter = m_agts[0].m_cfg.device_type == TRANSMITTER ? m_agts[0].m_cfg : m_agts[1].m_cfg;
        m_scbd.m_cfg_receiver = m_agts[1].m_cfg.device_type == RECEIVER ? m_agts[1].m_cfg : m_agts[1].m_cfg;

      end else begin
        `uvm_fatal(report, "Component axis_scoreboard only works with 2 agents.")
      end
    end

    `uvm_info(report, $sformatf("Finishing build_phase for %s", this.get_full_name()), UVM_NONE)
  endfunction : build_phase


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (m_scbd != null) begin
      foreach (m_agts[i]) begin
        case (m_agts[i].m_cfg.device_type)
          TRANSMITTER: m_agts[i].m_mon.transfer_ap.connect(m_scbd.tr_transmitter_ap);
          RECEIVER: m_agts[i].m_mon.transfer_ap.connect(m_scbd.tr_receiver_ap);
        endcase
      end
    end
  endfunction : connect_phase


  //  Constructor: new
  function new(string name = "axis_integ_env", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new

endclass : axis_integ_env

`endif
