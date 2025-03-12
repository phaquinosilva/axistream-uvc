class alu_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(alu_scoreboard)

  `uvm_analysis_imp_decl(_active)
  `uvm_analysis_imp_decl(_passive)

  uvm_analysis_imp_active #(alu_item, alu_scoreboard) imp_active;
  uvm_analysis_imp_passive #(alu_item, alu_scoreboard) imp_passive;


  function void build_phase(uvm_phase phase);
    imp_active  = new("imp_active", this);
    imp_passive = new("imp_passive", this);
  endfunction : build_phase

  function void write_active(alu_item m_item);
    `uvm_info("active_scbd", "Received item in active.", UVM_NONE)
    active_items_q.push_back(m_item);
    `uvm_info("active_scbd", $sformatf("%s", m_item.sprint()), UVM_DEBUG)
  endfunction : write_active

  function void write_passive(alu_item m_item);
    passive_items_q.push_back(m_item);
    `uvm_info("passive_scbd", "Received item in passive.", UVM_NONE)
    `uvm_info("passive_scbd", $sformatf("%s", m_item.sprint()), UVM_DEBUG)
  endfunction : write_passive

  task run_phase(uvm_phase phase);
    alu_item act_item, pas_item;
    forever begin
      wait(active_items_q > 0);
      act_item = 
    end
  endtask : run_phase

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("Number of active items received", $sformatf("%0d", active_items_q.size()), UVM_NONE)
    `uvm_info("Number of passive items received", $sformatf("%0d", passive_items_q.size()),
              UVM_NONE)
  endfunction : report_phase

  function alu_ref(alu_item pas_item, alu_item act_item);
    case (act_item.sel)
      2'b00:   pas_item.item.data_o = act_item.data_1 + act_item.data_2;
      2'b01:   pas_item.item.data_o = act_item.data_1 - act_item.data_2;
      2'b00:   pas_item.item.data_o = act_item.data_1 + 'd1;
      default: pas_item.item.data_o = '0;
    endcase
  endfunction

  function new(string name = "alu_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
