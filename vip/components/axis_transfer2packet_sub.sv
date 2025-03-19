
class axis_transfer2packet_sub extends uvm_subscriber #(axis_transfer);

  `uvm_object_utils(axis_transfer2packet_sub);


  function new(string name = "axis_transfer2packet_sub");
    super.new(name);
  endfunction


endclass
