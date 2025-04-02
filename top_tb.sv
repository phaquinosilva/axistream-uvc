`ifndef top_tb__sv
`define top_tb__sv 


`timescale 1ns / 100ps
`include "uvm_macros.svh"
`include "axis_if.sv"

// Conditional compile on DUT instantiation
`define AXI_FIFO_TEST 

// Conditional compile on reset interruptions
// `define RST_TEST


module top_tb;
  /*  package imports  */
  import uvm_pkg::*;
  import axis_uvc_pkg::*;
  import axis_integ_pkg::*;

  localparam CLK_PERIOD = 2;
  logic ACLK;
  logic ARESETn = 1;

`ifdef RST_TEST
  // randomize resets
  int num_rst = 0;
  int rst_delay;
  int rst_duration;
`endif

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

  parameter int DEPTH = 8;

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
      .DATA_W(TDATA_WIDTH),
      .ID_W(TID_WIDTH),
      .DEST_W(TDEST_WIDTH),
      .USER_W(TUSER_WIDTH),
      .OUTPUT_FIFO_EN(0)
  ) dut (
      .clk(ACLK),
      .rst(!ARESETn),
      /*
      * AXI input
      */
      .s_axis_tdata(dut_s_if.TDATA),
      .s_axis_tkeep(dut_s_if.TKEEP),
      .s_axis_tstrb(dut_s_if.TSTRB),
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
      .m_axis_tstrb(dut_m_if.TSTRB),
      .m_axis_tvalid(dut_m_if.TVALID),
      .m_axis_tready(dut_m_if.TREADY),
      .m_axis_tlast(dut_m_if.TLAST),
      .m_axis_tid(dut_m_if.TID),
      .m_axis_tdest(dut_m_if.TDEST),
      .m_axis_tuser(dut_m_if.TUSER)
  );
`endif

  // CLOCK GENERATION
  initial begin
    ACLK = 1'b1;
    forever #(CLK_PERIOD / 2) ACLK = ~ACLK;
  end


  // RESET BLOCK
  initial begin
    // NOTE: initial, common for all tests
    ARESETn = 1'b0;
    #2 ARESETn = 1'b1;

`ifdef RST_TEST
    // NOTE: Randomly generate reset signals given `num_rst` `rst_delay` and `rst_duration`
    repeat (num_rst) begin
      if (!std::randomize(rst_delay) with {rst_delay inside {[2 : 50]};})
        `uvm_fatal("top_tb", "Failed to randomize reset delay.")
      if (!std::randomize(rst_duration) with {rst_duration inside {[1 : 10]};})
        `uvm_fatal("top_tb", "Failed to randomize reset duration.")

      #rst_delay ARESETn = 1'b0;
      #rst_duration ARESETn = 1'b1;
    end
`endif

  end

  initial begin

    uvm_config_db#(int)::set(null, "uvm_test_top.m_env", "CLK_PERIOD", CLK_PERIOD);

    // input FIFO
`ifdef AXI_FIFO_TEST
    `uvm_info("top_tb", $sformatf("AXI_FIFO_TEST set"), UVM_NONE)
    uvm_config_db#(vif_t)::set(null, "uvm_test_top.m_env", "vifs[0]", dut_s_if);
`else
    `uvm_info("top_tb", $sformatf("AXI_FIFO_TEST not set"), UVM_NONE)
    uvm_config_db#(vif_t)::set(null, "uvm_test_top.m_env", "vifs[0]", dut_m_if);
`endif

    // output FIFO
    uvm_config_db#(vif_t)::set(null, "uvm_test_top.m_env", "vifs[1]", dut_m_if);

    run_test();
  end

endmodule : top_tb

`endif
