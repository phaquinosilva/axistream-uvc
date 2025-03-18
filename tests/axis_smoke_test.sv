//  Class: axis_smoke_test
//
class axis_smoke_test extends axis_base_test;
  `uvm_component_utils(axis_smoke_test)

  task run_phase(uvm_phase phase);
    axis_transfer_seq seq = axis_transfer_seq::type_id::create("seq");
    `uvm_info("START_PHASE", $sformatf("Starting run_phase for %s", get_full_name()), UVM_NONE)

    phase.raise_objection(this);
    `uvm_info(get_name(), "<run_phase> started, objection raised.", UVM_NONE)
    repeat (10) begin
      if (!seq.randomize())
        `uvm_fatal("TEST_SEQ", $sformatf("Unable to randomize seq for %s", get_full_name()))
      seq.start(m_env.m_agt_transmitter.m_seqr);
    end

    #10;
    phase.drop_objection(this);
    `uvm_info(get_name(), "<run_phase> finished, objection dropped.", UVM_NONE)

    `uvm_info("END_PHASE", $sformatf("Finishing run_phase for %s", get_full_name()), UVM_NONE)
  endtask : run_phase

  //  Constructor: new
  function new(string name = "axis_smoke_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : axis_smoke_test
