`ifndef axis_integ_config__sv
`define axis_integ_config__sv


class axis_integ_config extends uvm_object;

  //  Group: Variables
  protected string report_id = "";

  /* n_agts
    - Total number of agents that will be created in the env.
    - Each of the agents created receives it's own config object
      in the build_phase for the env.
  */
  protected int n_agts = 0;

  /* axis_config_obj
    - Holds all configuration object for the axis agents.
  */
  protected axis_config axis_config_obj[];

  /* has_scoreboard
    - Flag to indicate Whether scoreboard will be created or not.
  */
  bit has_scoreboard = 0;

  //  Group: Constraints
  `uvm_object_utils_begin(axis_integ_config)
    `uvm_field_array_object(axis_config_obj, UVM_DEFAULT)
    `uvm_field_int(n_agts, UVM_DEC)
    `uvm_field_int(has_scoreboard, UVM_BIN)
  `uvm_object_utils_end

  //  Group: Functions

  /* set_agt_configs
    - Sets the number of agents in the env and saves their configs.
  */
  function void set_agt_configs(int n_agts, axis_config configs[]);
    string report_id = $sformatf("%s.set_agt_configs", this.report_id);
    if (this.n_agts != 0 || this.axis_config_obj.size() != 0)
      `uvm_fatal(report_id, $sformatf(
                 "Agent config array was already initialized. \nn_agts = %d, axis_config_obj.size() = %d",
                 this.n_agts,
                 this.axis_config_obj.size()
                 ))

    if (configs.size() != n_agts)
      `uvm_fatal(report_id, "Number of agents DOES NOT match number of configs.")

    this.n_agts = n_agts;
    this.axis_config_obj = new[n_agts];

    foreach (configs[i]) begin
      this.axis_config_obj[i] = configs[i];
    end
  endfunction : set_agt_configs

  function axis_config get_config(int idx);
    if (this.n_agts == 0 || this.axis_config_obj.size() == 0)
      `uvm_fatal(report_id, "Object not initialized, cannot get idx for agent.")

    if (idx >= axis_config_obj.size())
      `uvm_fatal($sformatf("%s.get_config", this.report_id), "Invalid index for axis_config_obj.")

    get_config = this.axis_config_obj[idx];
  endfunction : get_config

  function int get_n_agts();
    if (this.n_agts == 0 || this.axis_config_obj.size() == 0)
      `uvm_fatal(report_id, "Object not initialized, cannot get number of agents")

    get_n_agts = this.n_agts;
  endfunction : get_n_agts

  //  Constructor: new
  function new(string name = "axis_integ_config");
    super.new(name);
    report_id = name;
  endfunction : new

endclass : axis_integ_config

`endif
