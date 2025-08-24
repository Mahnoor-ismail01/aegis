
`include "uvm_macros.svh"
import uvm_pkg::*;

class basic_addition_seq extends uvm_sequence#(adder_transaction);
  basic_addition_config cfg;
  `uvm_object_utils(basic_addition_seq)

  function new(string name = "basic_addition_seq");
    super.new(name);
  endfunction

  task body();
    adder_transaction tx;

    // Get config from the sequencer scope
    if (!uvm_config_db#(basic_addition_config)::get(m_sequencer, "", "basic_addition_config", cfg))
      `uvm_fatal("NO_CFG", "Config not found for basic_addition_seq")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (10) begin
      tx = adder_transaction::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
        // Apply ranges to ALL constrained fields (including input ports)

        tx.a inside { [ cfg.a_min : cfg.a_max ] };

        tx.b inside { [ cfg.b_min : cfg.b_max ] };

        // Apply boolean knobs

      }) begin
        `uvm_error("RAND_FAIL","Randomization failed in basic_addition_seq")
      end
      finish_item(tx);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass