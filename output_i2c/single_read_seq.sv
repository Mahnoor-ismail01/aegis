
`include "uvm_macros.svh"
import uvm_pkg::*;

class single_read_seq extends uvm_sequence#(i2c_master_transaction);
  single_read_config cfg;
  `uvm_object_utils(single_read_seq)

  function new(string name = "single_read_seq");
    super.new(name);
  endfunction

  task body();
    i2c_master_transaction tx;

    if (!uvm_config_db#(single_read_config)::get(m_sequencer, "", "single_read_config", cfg))
      `uvm_fatal("NO_CFG", "Config not found for single_read_seq")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (10) begin
      tx = i2c_master_transaction::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {

        tx.device_address inside { [ cfg.device_address_min : cfg.device_address_max ] };

        tx.divider inside { [ cfg.divider_min : cfg.divider_max ] };

        tx.mosi_data inside { [ cfg.mosi_data_min : cfg.mosi_data_max ] };

        tx.register_address inside { [ cfg.register_address_min : cfg.register_address_max ] };


      }) begin
        `uvm_error("RAND_FAIL","Randomization failed in single_read_seq")
      end
      finish_item(tx);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass