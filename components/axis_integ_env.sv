`ifndef axis_integ_env__sv
`define axis_integ_env__sv 


class axis_integ_env extends uvm_env;
  `uvm_component_utils(axis_integ_env)

  //  Group: Configuration objects
  axis_integ_config m_cfg;

  //  Group: Components
  axis_agent m_agts[];
  vif_t vifs[];

  // axis_vseqr m_vseqr = null;

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
      `uvm_fatal(report_id, $sformatf("Error to get axis_integ_config for %s", this.get_full_name()
                 ))

    m_agts = new[m_cfg.get_n_agts()];
    vifs   = new[m_cfg.get_n_agts()];

    `uvm_info(report, "Allocated m_agts and vifs in env", UVM_NONE)
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

    `uvm_info(report, $sformatf("Finishing build_phase for %s", this.get_full_name()), UVM_NONE)
  endfunction : build_phase

  //  Constructor: new
  function new(string name = "axis_integ_env", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new

endclass : axis_integ_env

`endif
