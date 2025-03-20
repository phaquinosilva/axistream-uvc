
class axis_packet2transfer_seq extends uvm_sequence #(axis_transfer);

  `uvm_object_utils_begin(axis_packet2transfer_seq)
  `uvm_object_utils_end


  // Group: variables
  protected string report_id = "";

  /* pkt_seqr:
  *   - handle to packet sequencer
  */
  axis_packet_seqr pkt_seqr = null;

  /* Task: body
  *  Description:
  *   - Checks whether axis_packet_seqr was initialized correctly
  *   - Triggers a forever loop that retrieves each packet item started
  *   in the pkt_seqr here.
  *   - Incoming packet items are converted into transfers using the
  *   converter.
  *   - Generated transfers are started in the beat_seqr.
  */
  task body;
    string report = $sformatf("%s.body", this.report_id);

    if ((this.pkt_seqr == null))
      `uvm_fatal(report, $sformatf("pkt_seqr was not initialized correctly"))

    forever begin
      axis_packet pkt;
      pkt_seqr.get_next_item(pkt);

      `uvm_info(report_id, $sformatf("Received item '%s' in %s", pkt.get_name(),
          this.get_full_name()), UVM_FULL)
      `uvm_info(report_id, $sformatf("Received item: \n%s", pkt.sprint()),
          UVM_FULL)

      pkt.packet2transfer();

      for (int i = 0; i < pkt.get_size(); i++) begin
        axis_transfer transfer = pkt.get_transfer(i);

        start_item(transfer);
        `uvm_info(report_id, $sformatf("Sending transfer item: \n%s",
            transfer.sprint()), UVM_NONE)

        finish_item(transfer);
      end

      pkt_seqr.item_done();
    end
  endtask : body

  // Constructor: new
  function new(string name = "axis_packet2transfer_seq");
    super.new(name);
    this.report_id = name;
  endfunction : new

endclass
