//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: driver_receiver.sv
// Description: This file comprises the RECEIVER methods for the driver component
//              of the AXI-Stream VIP.
//==============================================================================

/* Task: run_phase_receiver

  Description:
    - run_phase for the receiver driver.
*/
task axis_driver::run_phase_receiver();
  `uvm_info(report_id, "Starting the run_phase for the receiver agent.", UVM_LOW)

  forever begin
    reset_receiver();
    fork
      drive_transfer_receiver();
      @(negedge vif.ARESETn);
    join_any
    disable fork;
  end

  `uvm_info(report_id, "Finish run_phase for the receiver agent.", UVM_FULL)
endtask : run_phase_receiver


task axis_driver::reset_receiver;
endtask: reset_receiver


/* Task: drive_transfer_receiver

  Description:
    - [AXI-Stream Spec, Sec. 2.2.2]
    If RECEIVER initiates the transaction, it may assert TREADY and
    wait for a TVALID signal to finish the transfer. However, it may
    deassert TREADY at any time before a handshake is started.
    - This task finishes the handshake only when initiated by the TRANSMITTER.
*/
task axis_driver::drive_transfer_receiver;
  // start not ready to receive
  vif.TREADY = 1'b0;

  // HANDSHAKE 2.2.3 -- asserts TREADY at the same clock or after TVALID
  while (!vif.TVALID) begin
    @(vif.ACLK);
  end

  `uvm_info(report_id, "Finish handshake", UVM_FULL)
  vif.TREADY = 1'b1;

  // Wait for transfer completion to drive TREADY low
  @(posedge vif.ACLK);
  vif.TREADY = 1'b0;

endtask : drive_transfer_receiver
