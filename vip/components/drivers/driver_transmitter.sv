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

  vif.TVALID = 1'b0 & vif.ARESETn;
  forever begin
    // Fetch item
    axis_transfer m_item;
    seq_item_port.get_next_item(m_item);

    drive_transfer_transmitter(m_item);

    seq_item_port.item_done();
  end

endtask : run_phase_transmitter


/* Task: drive_transfer_transmitter
  Description:
  - [AXI-Stream Spec, Sec. 2.2.1 and 2.2.3]
    If TRANSMITTER initiates the transaction,
    it must make the data available and assert TVALID.
    It then must keep TVALID on 1 until the RECEIVER asserts
    TREADY and the handshake is finished.
  - This task implements this handshake procedure and drives the current transfer.
*/
task axis_driver::drive_transfer_transmitter(axis_transfer m_item);
  // start with TVALID low during delay
  repeat (m_item.delay) @(posedge vif.ACLK);
  `uvm_info(report_id, $sformatf("Driving the item:\n%s", m_item.sprint()), UVM_FULL)

  // Put data on bus
  vif.TDATA = m_item.tdata;
  vif.TKEEP = m_item.tkeep;
  vif.TSTRB = m_item.tstrb;
  vif.TLAST = m_item.tlast;

  // Assert TVALID required to be before clock edge
  vif.TVALID = 1'b1 & vif.ARESETn;
  // Wait for TREADY from receiver
  // NOTE: cannot drive TVALID = 0 until a TREADY is received
  `uvm_info(report_id, $sformatf(
            "Waiting for handshake to drive item: \nTVALID=%d ARESETn=%d at time=%d", 
            vif.TVALID, vif.ARESETn, $time),
            UVM_FULL)
  wait(vif.TREADY);

  // Wait for clock edge to turn control signals off
  @(posedge vif.ACLK);
  vif.TVALID = 1'b0;

endtask : drive_transfer_transmitter
