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
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import axis_uvc::*;
  // import axis_uvc::vif_t;


  // Group: UVM Components
  `include "axis_vseqr.sv"
  // `include "axis_scoreboard.sv"
  `include "axis_env.sv"

  // Group: tests
  // Base test setup
  `include "axis_test_base.sv"
  // `include "axis_base_test.sv"

  // Extended tests
  // `include "axis_smoke_test.sv"

endpackage : axis_integ_pkg
