`ifndef axis_scoreboard__sv
`define axis_scoreboard__sv


`uvm_analysis_imp_decl(_tr_receiver_ap)
`uvm_analysis_imp_decl(_tr_transmitter_ap)

class axis_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axis_scoreboard)

  uvm_analysis_imp_tr_transmitter_ap #(axis_transfer, axis_scoreboard) tr_transmitter_ap;
  uvm_analysis_imp_tr_receiver_ap #(axis_transfer, axis_scoreboard) tr_receiver_ap;

  //  Group: Objects
  axis_transfer transmitter_transfer_q[$];
  axis_transfer receiver_transfer_q[$];

  //  Group: Variables
  protected string report_id = "";

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    string report_id = $sformatf("%s.build_phase", this.report_id);
    `uvm_info(report_id, $sformatf("Started build_phase for %s", get_full_name()), UVM_NONE)
    super.build_phase(phase);

    tr_receiver_ap = new("tr_receiver_ap", this);
    tr_transmitter_ap = new("tr_transmitter_ap", this);

    `uvm_info(report_id, $sformatf("Finishing build_phase for %s", get_full_name()), UVM_NONE)
  endfunction : build_phase


  function write_tr_transmitter_ap(axis_transfer item);
    string report_id = $sformatf("%s.write_tr_transmitter_ap", this.report_id);
    transmitter_transfer_q.push_back(item);
    `uvm_info(report_id, $sformatf("Received item from TRANSMITTER: \n%s", item.sprint()), UVM_NONE)
  endfunction


  function write_tr_receiver_ap(axis_transfer item);
    string report_id = $sformatf("%s.write_tr_receiver_ap", this.report_id);
    receiver_transfer_q.push_back(item);
    `uvm_info(report_id, $sformatf("Received item from RECEIVER: \n%s", item.sprint()), UVM_NONE)
  endfunction


  virtual function void check_phase(uvm_phase phase);
    string report_id = $sformatf("%s.check_phase", this.report_id);
    `uvm_info(report_id, $sformatf("Started check_phase for %s", get_full_name()), UVM_NONE)
    super.check_phase(phase);

    if (transmitter_transfer_q.size() == receiver_transfer_q.size()) begin
      foreach (transmitter_transfer_q[i]) begin
        if (!transmitter_transfer_q[i].compare(receiver_transfer_q[i])) begin
          `uvm_error(report_id, $sformatf(
                     "Comparison mismatch: \n%s\n%s",
                     transmitter_transfer_q[i].miscompares,
                     receiver_transfer_q[i].sprint()
                     ));
        end
      end
    end else begin
      `uvm_error(report_id, $sformatf(
                 "Number of transfers mismatch: TRANSMITTER sent %0d transfers, RECEIVER got %0d.",
                 transmitter_transfer_q.size(),
                 receiver_transfer_q.size()
                 ));
    end

    `uvm_info(report_id, $sformatf("Finishing check_phase for %s", get_full_name()), UVM_NONE)
  endfunction : check_phase


  virtual function void report_phase(uvm_phase phase);
    string report_id = $sformatf("%s.report_phase", this.report_id);
    super.report_phase(phase);

    `uvm_info(report_id, $sformatf(
              "Received %1d transfers from TRASMITTER", transmitter_transfer_q.size()), UVM_NONE)

    `uvm_info(report_id, $sformatf(
              "Received %1d transfers from RECEIVER", receiver_transfer_q.size()), UVM_NONE)
  endfunction : report_phase


  function new(string name = "axis_scoreboard", uvm_component parent);
    super.new(name, parent);
    this.report_id = name;
  endfunction

endclass

`endif
