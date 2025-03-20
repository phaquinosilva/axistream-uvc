//  Class: axis_env
//
class axis_env extends uvm_env;
  `uvm_component_utils(axis_env)

  //  Group: Configuration objects
  // axis_integ_cfg m_cfg;

  //  Group: Components
  axis_agent m_agt_transmitter;
  axis_agent m_agt_receiver;

  vif_t vif;

  axis_vseqr m_vseqr;

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

    m_vseqr           = axis_vseqr::type_id::create("m_vseqr", this);
    m_agt_transmitter = axis_agent::type_id::create("m_agt_transmitter", this);
    m_agt_receiver    = axis_agent::type_id::create("m_agt_receiver", this);

    // NOTE: figure out why I had to fetch them after setting it on the db on the test_base
    uvm_config_db#(axis_config)::get(this, "m_agt_transmitter*", "m_cfg", m_agt_transmitter.m_cfg);
    uvm_config_db#(axis_config)::get(this, "m_agt_receiver*", "m_cfg", m_agt_receiver.m_cfg);

    `uvm_info(report_id,
              $sformatf("Transmitter Configuration:\n%s", m_agt_transmitter.m_cfg.sprint()),
              UVM_MEDIUM)

    `uvm_info(report_id,
              $sformatf("Receiver Configuration:\n%s", m_agt_receiver.m_cfg.sprint()),
              UVM_MEDIUM)

    if (!uvm_config_db#(vif_t)::get(this, "", "vif", vif))
      `uvm_fatal(report, $sformatf("Unable to get vif for %s", get_full_name()))

    uvm_config_db#(vif_t)::set(this, "m_agt*", "vif", vif);

    `uvm_info(report, $sformatf("Finishing build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase


  /* connect_phase:
  *    - connect handles to vseqr
  */
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (m_agt_transmitter.m_cfg.has_pkt_seqr) begin
      m_vseqr.m_pkt_seqr = m_agt_transmitter.m_pkt_seqr;
    end

    m_vseqr.m_transfer_seqr = m_agt_transmitter.m_transfer_seqr;
  endfunction : connect_phase


  //  Constructor: new
  function new(string name = "axis_env", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new


endclass : axis_env


