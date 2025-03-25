//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: driver_transmitter.sv
// Description: This file comprises the TRANSMITTER methods for the driver component
//              of the AXI-Stream VIP.
//==============================================================================

/* Task: run_phase_transmitter

  Description:
    - run_phase for the transmitter driver.
*/
task axis_driver::run_phase_transmitter();
  string report_id = $sformatf("%s.run_phase_transmitter", this.report_id);

  `uvm_info(report_id, "Started run_phase for driver.", UVM_LOW)

  forever begin
    reset_transmitter();
    fork
      main_transmitter();
      @(negedge vif.ARESETn);
    join
    disable fork;
  end

  `uvm_info(report_id, "Finished run_phase for driver.", UVM_LOW)
endtask : run_phase_transmitter


task axis_driver::reset_transmitter;
  vif.TVALID = 1'b0;
  @(posedge vif.ARESETn);
endtask: reset_transmitter


task axis_driver::main_transmitter;
  axis_transfer item;

  fork
    forever begin
      // Fetch item
      seq_item_port.get_next_item(item);
      drive_transfer_transmitter(item);
      seq_item_port.item_done();
    end
    begin
      @(negedge vif.ARESETn);
      seq_item_port.item_done();
    end
  join_any
  disable fork;

endtask: main_transmitter


/* Task: drive_transfer_transmitter
  Description:
  - [AXI-Stream Spec, Sec. 2.2.1 and 2.2.3]
    If TRANSMITTER initiates the transaction,
    it must make the data available and assert TVALID.
    It then must keep TVALID on 1 until the RECEIVER asserts
    TREADY and the handshake is finished.
  - This task implements this handshake procedure and drives the current transfer.
*/
task axis_driver::drive_transfer_transmitter(axis_transfer item);
  `uvm_info(report_id, $sformatf("Driving the item:\n%s", item.sprint()), UVM_FULL)
  repeat (item.delay) @(posedge vif.ACLK);

  begin : DRIVE_BUS
    vif.TVALID = 1'b1;
    vif.TDATA = item.tdata;
    vif.TKEEP = item.tkeep;
    vif.TSTRB = item.tstrb;
    vif.TLAST = item.tlast;
  end

  // NOTE: cannot drive TVALID = 0 until a TREADY is received
  `uvm_info(report_id, $sformatf(
            "Waiting for handshake to drive item: \nTVALID=%d ARESETn=%d at time=%d",
            vif.TVALID, vif.ARESETn, $time),
            UVM_FULL)
  do begin
    @(posedge vif.ACLK);
  end while (!vif.TREADY);

  // turn control signals off after handshake
  vif.TVALID = 0;
endtask : drive_transfer_transmitter
