//  Class: axi_s_env
//
class axi_s_env extends uvm_env;
  `uvm_component_utils(axi_s_env)

  //  Group: Components
  axi_s_agent m_agt_transmitter;
  axi_s_agent m_agt_receiver;

  //  Group: Variables

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s", get_full_name()), UVM_NONE)

    m_agt_transmitter  = axi_s_agent::type_id::create("m_agt_transmitter", this);
    m_agt_receiver = axi_s_agent::type_id::create("m_agt_receiver", this);

    `uvm_info("END_PHASE", $sformatf("Finishing build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase

  //  Constructor: new
  function new(string name = "axi_s_env", uvm_component parent);
    super.new(name, parent);
  endfunction : new


endclass : axi_s_env



