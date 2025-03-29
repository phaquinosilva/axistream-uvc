`ifndef axis_scoreboard__sv
`define axis_scoreboard__sv


class axis_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axis_scoreboard)

  function new(string name = "axis_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

`endif
