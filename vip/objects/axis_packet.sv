`ifndef axis_packet__sv
`define axis_packet__sv

class axis_packet extends uvm_object;

  //  Group: Variables
  axis_transfer                            transfers  [ $];

  protected bit      [    TDATA_WIDTH-1:0] valid_data [];
  protected stream_t                       stream_type      = SPARSE;


  protected bit      [    TDATA_WIDTH-1:0] p_data     [];
  protected bit      [(TDATA_WIDTH/8)-1:0] p_keep     [];
  protected bit      [(TDATA_WIDTH/8)-1:0] p_strb     [];
  protected bit      [  (TID_WIDTH/8)-1:0] tid;
  protected bit      [(TUSER_WIDTH/8)-1:0] tuser;
  protected bit      [(TDEST_WIDTH/8)-1:0] tdest;
  protected time                           timestamps [];


  // for the do_compare method
  string                                   miscompares      = "";

  `uvm_object_utils_begin(axis_packet)
    `uvm_field_array_int(p_data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_array_int(p_keep, UVM_DEFAULT | UVM_BIN)
    `uvm_field_array_int(p_strb, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(tid, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(tdest, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_int(tuser, UVM_NOCOMPARE | UVM_BIN)
    `uvm_field_array_int(timestamps, UVM_NOCOMPARE | UVM_DEC)
  `uvm_object_utils_end


  //  Group: Helper functions

  function void extract_data(axis_config cfg);
    p_data = new[transfers.size()];
    p_keep = new[transfers.size()];
    p_strb = new[transfers.size()];
    timestamps = new[transfers.size()];

    foreach (transfers[i]) begin
      transfers[i].remove_disabled_sig(cfg);
      p_data[i] = transfers[i].tdata;
      p_keep[i] = transfers[i].tkeep;
      p_strb[i] = transfers[i].tstrb;
      timestamps[i] = transfers[i].timestamp;
    end
    tid   = transfers[0].tid;
    tuser = transfers[0].tuser;
    tdest = transfers[0].tdest;

    /*
    // Get valid data in transfer
    if (cfg.TDATA_ENABLE) begin
      if (cfg.TKEEP_ENABLE) begin
        if (cfg.TSTRB_ENABLE) begin
          // remove null && position bytes
        end else begin
          // remove null bytes
        end
      end else if (cfg.TSTRB_ENABLE) begin
        // extract position bytes
      end
      // all bytes are valid
    end
    */

  endfunction : extract_data

  function void get_valid_data();
  endfunction : get_valid_data

  function void get_stream_type();
  endfunction : get_stream_type

  function void set_stream_type();
  endfunction : set_stream_type


  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    axis_packet rhs_;
    do_compare = 1;
    if (!$cast(rhs_, rhs))
      `uvm_fatal($sformatf("%s.do_compare", get_full_name()), "Unable to cast rhs.")

    foreach (transfers[i]) begin
      do_compare &= transfers[i].compare(rhs_.transfers[i]);
      this.miscompares = {
        this.miscompares, $sformatf("transfers[%0d]", i), rhs_.transfers[i].miscompares
      };
    end

  endfunction


  //  Group: Constructor
  function new(string name = "axis_packet");
    super.new(name);
  endfunction

endclass

`endif
