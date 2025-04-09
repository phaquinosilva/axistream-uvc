//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: driver_receiver.sv
// Description: This file comprises the RECEIVER methods for the driver component
//              of the AXI-Stream VIP.
//==============================================================================
`ifdef axis_driver__sv

/* Task: run_phase_receiver

  Description:
    - run_phase for the receiver driver.
*/
task axis_driver::run_phase_receiver();
  string report_id = $sformatf("%s.run_phase_receiver", this.report_id);
  axis_transfer item;
  `uvm_info(report_id, "Starting the run_phase for the receiver agent.", UVM_LOW)

  forever begin
    if (vif.ARESETn !== 1) reset_receiver();
    fork
      begin : DRIVE_ITEM
        seq_item_port.get_next_item(item);
        drive_transfer_receiver(item);
      end
      begin : WAIT_RESET
        @(negedge vif.ARESETn);
        `uvm_info(report_id, "Captured reset. Starting reset mode.", UVM_NONE)
      end
    join_any
    seq_item_port.item_done();
    disable fork;
  end

  `uvm_info(report_id, "Finish run_phase for the receiver agent.", UVM_FULL)
endtask : run_phase_receiver


task axis_driver::reset_receiver;
  vif.TREADY = 0;
  @(posedge vif.ARESETn);
endtask : reset_receiver


/* Task: drive_transfer_receiver

  Description:
    - [AXI-Stream Spec, Sec. 2.2.2]
    If RECEIVER initiates the transaction, it may assert TREADY and
    wait for a TVALID signal to finish the transfer. However, it may
    deassert TREADY at any time before a handshake is started.
    - This task finishes the handshake only when initiated by the TRANSMITTER.
    NOTE: Uses a event to botch signaling to the monitor the handshake finished.
*/
task axis_driver::drive_transfer_receiver(axis_transfer item);
  string report_id = $sformatf("%s.drive_transfer_receiver", this.report_id);

  // start not ready to receive
  repeat (item.delay) @(posedge vif.ACLK);
  vif.TREADY = 1'b1;

  // Wait for handshake to complete
  @(negedge vif.ACLK iff (vif.TREADY === 1 && vif.TVALID === 1));
  @(posedge vif.ACLK);
  ->handshake;

  // Deassert TVALID after handshake
  vif.TREADY = 1'b0;

  `uvm_info(report_id, $sformatf("Finished driving item on receiver"), UVM_NONE)

endtask : drive_transfer_receiver

`endif
