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
task axi_s_driver::run_phase_receiver();

  `uvm_info(report_id, "Starting the run_phase for the receiver agent.", UVM_LOW)
  vif.TREADY = 1'b0;
  forever begin
    drive_transfer_receiver();
  end

endtask : run_phase_receiver


/* Task: drive_transfer_receiver

  Description:
    - [AXI-Stream Spec, Sec. 2.2.2]
    If RECEIVER initiates the transaction, it may assert TREADY and
    wait for a TVALID signal to finish the transfer. However, it may
    deassert TREADY at any time before a handshake is started.
    - This task finishes the handshake only when initiated by the TRANSMITTER.
*/
task axi_s_driver::drive_transfer_receiver();
  // start not ready to receive

  // HANDSHAKE 2.2.3 -- asserts TREADY at the same time or after TVALID
  // @(posedge vif.ACLK);
  wait(vif.TVALID);
  vif.TREADY = 1'b1;

  // complete transfer
  @(posedge vif.ACLK);
  // wait for tvalid to go to low
  wait(!vif.TVALID);
  vif.TREADY = 1'b0;

endtask : drive_transfer_receiver
