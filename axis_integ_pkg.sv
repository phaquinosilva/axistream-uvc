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
  // `include "axis_vseq.sv"
  // `include "axis_scoreboard.sv"
  `include "axis_env.sv"

  // Group: tests
  // transfer test setup
  `include "axis_transfer_base_test.sv"
  `include "axis_transfer_smoke_test.sv"


  // packet_tests
  `include "axis_test_base.sv"

endpackage : axis_integ_pkg
