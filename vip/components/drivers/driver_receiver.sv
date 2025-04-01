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
  `uvm_info(report_id, "Starting the run_phase for the receiver agent.", UVM_LOW)

  vif.TREADY <= 1'b0;
  forever begin
    if (!vif.ARESETn) reset_receiver();
    fork
      main_receiver();
      @(negedge vif.ARESETn);
    join_any
    disable fork;
  end

  `uvm_info(report_id, "Finish run_phase for the receiver agent.", UVM_FULL)
endtask : run_phase_receiver


task axis_driver::reset_receiver;
endtask : reset_receiver

task axis_driver::main_receiver;
  axis_transfer item;

  fork
    forever begin
      seq_item_port.get_next_item(item);
      drive_transfer_receiver(item);
      seq_item_port.item_done();
    end
    begin : RESET_ITEM
      @(negedge vif.ARESETn);
      seq_item_port.item_done();
    end
  join_any
  disable fork;

endtask


/* Task: drive_transfer_receiver

  Description:
    - [AXI-Stream Spec, Sec. 2.2.2]
    If RECEIVER initiates the transaction, it may assert TREADY and
    wait for a TVALID signal to finish the transfer. However, it may
    deassert TREADY at any time before a handshake is started.
    - This task finishes the handshake only when initiated by the TRANSMITTER.
*/
task axis_driver::drive_transfer_receiver(axis_transfer item);
  // start not ready to receive
  `uvm_info(report_id, $sformatf("Waiting the delay on port:\n%s", item.delay), UVM_FULL)
  repeat (item.delay) @(posedge vif.ACLK);
  vif.TREADY <= 1'b1;

  if (!vif.TVALID) @(posedge vif.TVALID);
  `uvm_info(report_id, "Assert TREADY and listen on TVALID", UVM_FULL)

  // HANDSHAKE 2.2.3 -- asserts TREADY at the same clock or after TVALID
  // Wait for transfer completion to drive TREADY low
  // TVALID may only be deasserted after transfer finished

  // @(negedge vif.TVALID);
  @(posedge vif.ACLK) vif.TREADY <= 1'b0;

endtask : drive_transfer_receiver

`endif
