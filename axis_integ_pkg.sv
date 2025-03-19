//==============================================================================
// Project: AXI-Stream VIP
//==============================================================================
// Filename: axis_integ_pkg.sv
// Description: This file comprises the integration package for the AXI-Stream 
// VIP. Tests and env components should be included here.
//==============================================================================

//  Package: axis_pkg
//
package axis_integ_pkg;

  //  Group: UVM
  import uvm_pkg::*;
  import axis_uvc::*;
  `include "uvm_macros.svh"

  // Group: UVM Components
  `include "axis_env.sv"
  `include "axis_vseqr.sv"
  // `include "axis_scoreboard.sv"

  // Group: tests
  // Base test setup
  `include "axis_base_test.sv"

  // Extended tests
  `include "axis_smoke_test.sv"

endpackage : axis_integ_pkg
