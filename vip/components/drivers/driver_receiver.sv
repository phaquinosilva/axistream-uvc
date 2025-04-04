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
  `uvm_info(report_id, "Starting the run_phase for the receiver agent.", UVM_LOW)

  vif.TREADY = 1'b0;
  forever begin
    if (vif.ARESETn !== 1) reset_receiver();
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
  string report_id = $sformatf("%s.main_receiver", this.report_id);
  axis_transfer item;

  fork
    forever begin
      seq_item_port.get_next_item(item);
      drive_transfer_receiver(item);
      seq_item_port.item_done();
      `uvm_info(report_id, $sformatf("Finished driving item on receiver"), UVM_DEBUG)
    end
    begin : RESET_ITEM
      @(negedge vif.ARESETn);
      seq_item_port.item_done();
      `uvm_info(report_id, $sformatf("Finished driving item on receiver after reset"), UVM_DEBUG)
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
  string report_id = $sformatf("%s.drive_transfer_receiver", this.report_id);

  // start not ready to receive
  repeat (item.delay) @(posedge vif.ACLK);
  vif.TREADY <= 1'b1;

  // Wait for handshake to complete
  @(posedge vif.ACLK iff (vif.TREADY === 1 && vif.TVALID === 1));
  ->handshake;

  // Deassert TVALID after handshake
  vif.TREADY <= 1'b0;

  `uvm_info(report_id, $sformatf("Finished driving item on receiver"), UVM_NONE)

endtask : drive_transfer_receiver

`endif
