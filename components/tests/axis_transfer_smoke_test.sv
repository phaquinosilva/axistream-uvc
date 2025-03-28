
class axis_transfer_smoke_test extends axis_transfer_base_test;
  `uvm_component_utils(axis_transfer_smoke_test)

  task run_phase(uvm_phase phase);
    // axis_transfer_seq seq = axis_transfer_seq::type_id::create("seq");
    axis_packet_seq seq = axis_packet_seq::type_id::create("seq");

    string report = $sformatf("%s.run_phase", report_id);
    `uvm_info(report, $sformatf("Starting run_phase for %s", get_full_name()), UVM_NONE)

    phase.raise_objection(this);
    `uvm_info(report, "<run_phase> started, objection raised.", UVM_NONE)
    #10;
    repeat (10) begin
      if (!seq.randomize() with {
            size == 10;
            // foreach (delays[i]) delays[i] == 0;
          })
        `uvm_fatal(report, $sformatf("Unable to randomize seq for %s", get_full_name()))
      seq.start(m_env.m_agt_transmitter.m_transfer_seqr);
    end

    #100;

    phase.drop_objection(this);
    `uvm_info(report, "<run_phase> finished, objection dropped.", UVM_NONE)

    `uvm_info(report, $sformatf("Finishing run_phase for %s", get_full_name()), UVM_NONE)
  endtask : run_phase

  //  Constructor: new
  function new(string name = "axis_transfer_smoke_test", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction : new

endclass : axis_transfer_smoke_test
