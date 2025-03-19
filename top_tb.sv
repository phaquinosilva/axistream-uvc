//  Module: top_tb
//
`timescale 1ns / 1ps
`include "uvm_macros.svh"
`include "axis_if.sv"

module top_tb;
  /*  package imports  */

  import uvm_pkg::*;
  import axis_integ_pkg::*;

  logic ACLK;
  logic ARESETn;

  axis_if #(
      .TADDR_WIDTH(TADDR_WIDTH),
      .TDATA_WIDTH(TDATA_WIDTH),
      .TDEST_WIDTH(TDEST_WIDTH),
      .TUSER_WIDTH(TUSER_WIDTH),
      .TID_WIDTH  (TID_WIDTH)
  ) dut_if (
      .ACLK(ACLK),
      .ARESETn(ARESETn)
  );

  initial begin
    ACLK = 1'b1;
    forever #2 ACLK = ~ACLK;
  end

  initial begin
    ARESETn = 1'b0;
    #0.5 ARESETn = 1'b1;
  end

  initial begin
    uvm_config_db#(vif_t)::set(null, "uvm_test_top", "vif", dut_if);
    run_test("axis_base_test");
  end
endmodule : top_tb

