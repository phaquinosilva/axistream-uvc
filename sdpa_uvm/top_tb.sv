//  Module: top_tb
//
`timescale 1ns/1ps
`include "uvm_macros.svh"
`include "axis_if.sv"

module top_tb;
  /*  package imports  */

  import uvm_pkg::*;
  import axis_pkg::*;

  logic ACLK;
  logic ARESETn;

  axis_if #(
      .TADDR_WIDTH(TADDR_WIDTH),
      .TDATA_WIDTH(TDATA_WIDTH),
      .TDEST_WIDTH(TDEST_WIDTH),
      .TUSER_WIDTH(TUSER_WIDTH),
      .TID_WIDTH(TID_WIDTH)
  ) q_if (
      .ACLK(ACLK),
      .ARESETn(ARESETn)
  );

  axis_if #(
      .TADDR_WIDTH(TADDR_WIDTH),
      .TDATA_WIDTH(TDATA_WIDTH),
      .TDEST_WIDTH(TDEST_WIDTH),
      .TUSER_WIDTH(TUSER_WIDTH),
      .TID_WIDTH(TID_WIDTH)
  ) k_if (
      .ACLK(ACLK),
      .ARESETn(ARESETn)
  );

  axis_if #(
      .TADDR_WIDTH(TADDR_WIDTH),
      .TDATA_WIDTH(TDATA_WIDTH),
      .TDEST_WIDTH(TDEST_WIDTH),
      .TUSER_WIDTH(TUSER_WIDTH),
      .TID_WIDTH(TID_WIDTH)
  ) v_if (
      .ACLK(ACLK),
      .ARESETn(ARESETn)
  );

  axis_if #(
      .TADDR_WIDTH(TADDR_WIDTH),
      .TDATA_WIDTH(TDATA_WIDTH),
      .TDEST_WIDTH(TDEST_WIDTH),
      .TUSER_WIDTH(TUSER_WIDTH),
      .TID_WIDTH(TID_WIDTH)
  ) out_if (
      .ACLK(ACLK),
      .ARESETn(ARESETn)
  );

  SDPA #(.M(4), .N(4), .WIDTH(8), .SCALE_FACTOR(2)) uuv (
    .i_Rst_L(i_Rst_L),
    .i_Clk(i_Clk),
    //AXI4-Stream Interface
    .s_axis_tdata_q(s_axis_tdata_q),
    .s_axis_tvalid_q(s_axis_tvalid_q),
    .s_axis_tready_q(s_axis_tready_q),
    .s_axis_tlast_q(s_axis_tlast_q),
    .m_axis_tdata_q(m_axis_tdata_q),
    .m_axis_tvalid_q(m_axis_tvalid_q),
    .m_axis_tready_q(m_axis_tready_q),
    .m_axis_tlast_q(m_axis_tlast_q),

    .s_axis_tdata_k(s_axis_tdata_k),
    .s_axis_tvalid_k(s_axis_tvalid_k),
    .s_axis_tready_k(s_axis_tready_k),
    .s_axis_tlast_k(s_axis_tlast_k),
    .m_axis_tdata_k(m_axis_tdata_k),
    .m_axis_tvalid_k(m_axis_tvalid_k),
    .m_axis_tready_k(m_axis_tready_k),
    .m_axis_tlast_k(m_axis_tlast_k),
    .s_axis_tdata_v(s_axis_tdata_v),
    .s_axis_tvalid_v(s_axis_tvalid_v),
    .s_axis_tready_v(s_axis_tready_v),
    .s_axis_tlast_v(s_axis_tlast_v),
    .m_axis_tdata_v(m_axis_tdata_v),
    .m_axis_tvalid_v(m_axis_tvalid_v),
    .m_axis_tready_v(m_axis_tready_v),
    .m_axis_tlast_v(m_axis_tlast_v),
    //AXI4-Stream status signals
    .status_depth_q(status_depth_q),
    .status_depth_commit_q(status_depth_commit_q),
    .status_depth_k(status_depth_k),
    .status_depth_commit_k(status_depth_commit_k),
    .status_depth_v(status_depth_v),
    .status_depth_commit_v(status_depth_commit_v),
    //AXI4-Stream error signals
    .error_incomplete_packet_q(error_incomplete_packet_q),
    .error_extra_data_q(error_extra_data_q),
    .error_fifo_overflow_q(error_fifo_overflow_q),
    .error_bad_frame_q(error_badframe_q),
    .error_incomplete_packet_k(error_incomplete_packet_k),
    .error_extra_data_k(error_extra_data_k),
    .error_fifo_overflow_k(error_fifo_overflow_k),
    .error_bad_frame_k(error_badframe_k),
    .error_incomplete_packet_v(error_incomplete_packet_v),
    .error_extra_data_v(error_extra_data_v),
    .error_fifo_overflow_v(error_fifo_overflow_v),
    .error_bad_frame_v(error_badframe_v),
    //Debug interface
    .clear_data(clear_data),
    .data_complete(data_complete),
    .matrix_received_q(matrix_received_q),
    .matrix_received_k(matrix_received_k),
    .matrix_received_v(matrix_received_v),
    .byte_count_q(byte_count_q),
    .byte_count_k(byte_count_k),
    .byte_count_v(byte_count_v),
    .q(q_m),
    .k(k_m),
    .v(v_m),
    .qk(qk),
    .start_qk_mult(start_qk_mult),
    .done_qk(done_qk),
    .qk_scale(qk_scale),
    .qk_masked(qk_masked),
    .qk_softmax(qk_softmax),
    .max_val(max_val),
    .exp_matrix(exp_matrix),
    .out_matrix_20b(out_matrix_20b),
    .sum_exp(sum_exp),
    .start_softmax(start_softmax),
    .done_softmax(done_softmax),
    .start_softmax_v_mult(start_softmax_v_mult),
    .final_result(final_result),
    .sdpa_done(sdpa_done),
    //Output AXI-Stream-Interface
    .s_axis_tdata_output(s_axis_tdata_output),
    .s_axis_tvalid_output(s_axis_tvalid_output),
    .s_axis_tready_output(s_axis_tready_output),
    .s_axis_tlast_output(s_axis_tlast_output),
    .m_axis_tvalid_output(m_axis_tvalid_output),
    .m_axis_tready_output(m_axis_tready_output),
    .m_axis_tlast_output(m_axis_tlast_output),
    .m_axis_tdata_output(m_axis_tdata_output)
  );

  initial begin
    ACLK = 1'b1;
    forever #2 ACLK = ~ACLK;
  end

  initial begin
    ARESETn = 1'b0;
    #0.5 ARESETn= 1'b1;
  end

  initial begin
    uvm_config_db#(vif_t)::set(null, "uvm_test_top", "vif", dut_if);
    run_test("axis_base_test");
  end
endmodule : top_tb
