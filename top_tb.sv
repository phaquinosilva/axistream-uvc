//  Module: top_tb
//
`timescale 1ns / 100ps
`include "uvm_macros.svh"
`include "axis_if.sv"

`ifndef AXI_FIFO_TEST
`define AXI_FIFO_TEST 
`endif

module top_tb;
  /*  package imports  */

  import uvm_pkg::*;
  import axis_uvc::*;
  import axis_integ_pkg::*;

  logic ACLK;
  logic ARESETn;


  axis_if #(
      .TDATA_WIDTH(TDATA_WIDTH),
      .TDEST_WIDTH(TDEST_WIDTH),
      .TUSER_WIDTH(TUSER_WIDTH),
      .TID_WIDTH  (TID_WIDTH)
  ) dut_m_if (
      .ACLK(ACLK),
      .ARESETn(ARESETn)
  );


`ifdef AXI_FIFO_TEST
  parameter int DEPTH = 16;

  axis_if #(
      .TDATA_WIDTH(TDATA_WIDTH),
      .TDEST_WIDTH(TDEST_WIDTH),
      .TUSER_WIDTH(TUSER_WIDTH),
      .TID_WIDTH  (TID_WIDTH)
  ) dut_s_if (
      .ACLK(ACLK),
      .ARESETn(ARESETn)
  );


  axis_fifo #(
      .DEPTH(DEPTH),
      .DATA_WIDTH(TDATA_WIDTH),
      .ID_WIDTH(TID_WIDTH),
      .DEST_WIDTH(TDEST_WIDTH),
      .USER_WIDTH(TUSER_WIDTH),
      .OUTPUT_FIFO_ENABLE(1'b0)
  ) dut (
      .clk(ACLK),
      .rst(ARESETn),
      /*
      * AXI input
      */
      .s_axis_tdata(dut_s_if.TDATA),
      .s_axis_tkeep(dut_s_if.TKEEP),
      .s_axis_tvalid(dut_s_if.TVALID),
      .s_axis_tready(dut_s_if.TREADY),
      .s_axis_tlast(dut_s_if.TLAST),
      .s_axis_tid(dut_s_if.TID),
      .s_axis_tdest(dut_s_if.TDEST),
      .s_axis_tuser(dut_s_if.TUSER),
      /*
      * AXI output
      */
      .m_axis_tdata(dut_m_if.TDATA),
      .m_axis_tkeep(dut_m_if.TKEEP),
      .m_axis_tvalid(dut_m_if.TVALID),
      .m_axis_tready(dut_m_if.TREADY),
      .m_axis_tlast(dut_m_if.TLAST),
      .m_axis_tid(dut_m_if.TID),
      .m_axis_tdest(dut_m_if.TDEST),
      .m_axis_tuser(dut_m_if.TUSER)
  );
`endif

  initial begin
    ACLK = 1'b1;
    forever #2 ACLK = ~ACLK;
  end

  initial begin
    ARESETn = 1'b0;
    #0.5 ARESETn = 1'b1;
  end

  initial begin
    uvm_config_db#(vif_t)::set(null, "uvm_test_top.m_env", "vif_tr", dut_s_if);
    uvm_config_db#(vif_t)::set(null, "uvm_test_top.m_env", "vif_re", dut_m_if);
    run_test();
  end

endmodule : top_tb
