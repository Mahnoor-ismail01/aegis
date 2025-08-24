
`include "uvm_macros.svh"
import uvm_pkg::*;

class edge_case_test_seq extends uvm_sequence#(adder_transaction);
  edge_case_test_config cfg;
  `uvm_object_utils(edge_case_test_seq)

  function new(string name = "edge_case_test_seq");
    super.new(name);
  endfunction

  task body();
    adder_transaction tx;

    // Get config from the sequencer scope
    if (!uvm_config_db#(edge_case_test_config)::get(m_sequencer, "", "edge_case_test_config", cfg))
      `uvm_fatal("NO_CFG", "Config not found for edge_case_test_seq")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (8) begin
      tx = adder_transaction::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
        // Apply ranges to ALL constrained fields (including input ports)

        tx.a inside { [ cfg.a_min : cfg.a_max ] };

        tx.b inside { [ cfg.b_min : cfg.b_max ] };

        // Apply boolean knobs

      }) begin
        `uvm_error("RAND_FAIL","Randomization failed in edge_case_test_seq")
      end
      finish_item(tx);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass