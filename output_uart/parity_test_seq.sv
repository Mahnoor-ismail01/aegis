
`include "uvm_macros.svh"
import uvm_pkg::*;

class parity_test_seq extends uvm_sequence#(uart_transaction);
  parity_test_config cfg;
  `uvm_object_utils(parity_test_seq)

  function new(string name = "parity_test_seq");
    super.new(name);
  endfunction

  task body();
    uart_transaction tx;

    // Get config from the sequencer scope
    if (!uvm_config_db#(parity_test_config)::get(m_sequencer, "", "parity_test_config", cfg))
      `uvm_fatal("NO_CFG", "Config not found for parity_test_seq")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (5) begin
      tx = uart_transaction::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
        // Apply ranges to ALL constrained fields (including input ports)

        tx.baud_rate inside { [ cfg.baud_rate_min : cfg.baud_rate_max ] };

        tx.tx_data inside { [ cfg.tx_data_min : cfg.tx_data_max ] };

        // Apply boolean knobs

        tx.enable_parity == cfg.enable_parity;

      }) begin
        `uvm_error("RAND_FAIL","Randomization failed in parity_test_seq")
      end
      finish_item(tx);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass