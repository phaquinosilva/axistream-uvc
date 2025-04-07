//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_integ_pkg.sv
// Description: This file comprises the integration package for the AXI-Stream 
// VIP. Tests and env components should be included here.
//==============================================================================
`ifndef axis_integ_pkg__sv
`define axis_integ_pkg__sv

package axis_integ_pkg;

  //  Group: UVM
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import axis_uvc_pkg::*;

  // Group: Typedefs
  typedef axis_vseq;
  typedef axis_scoreboard;
  typedef axis_integ_config;
  typedef axis_integ_env;
  typedef axis_test_base;

  // Group: UVM Components
  `include "axis_vseq.sv"
  `include "axis_scoreboard.sv"
  `include "axis_integ_config.sv"
  `include "axis_cov_model.sv"
  `include "axis_integ_env.sv"

  // Group: tests
  `include "axis_test_base.sv"
  `include "axis_smoke_test.sv"

endpackage : axis_integ_pkg

`endif
