
`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_test extends uvm_test;
  `uvm_component_utils(uart_test)

  uart_env env;


  basic_transmission_config basic_transmission_cfg_h;

  parity_test_config parity_test_cfg_h;

  random_test_config random_test_cfg_h;

  edge_case_test_config edge_case_test_cfg_h;


  function new(string name = "uart_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = uart_env::type_id::create("env", this);

    // Create and scope config(s) to the sequencer

    basic_transmission_cfg_h = basic_transmission_config::type_id::create("basic_transmission_cfg_h");
    uvm_config_db#(basic_transmission_config)::set(this, "env.agent.sequencer", "basic_transmission_config", basic_transmission_cfg_h);

    parity_test_cfg_h = parity_test_config::type_id::create("parity_test_cfg_h");
    uvm_config_db#(parity_test_config)::set(this, "env.agent.sequencer", "parity_test_config", parity_test_cfg_h);

    random_test_cfg_h = random_test_config::type_id::create("random_test_cfg_h");
    uvm_config_db#(random_test_config)::set(this, "env.agent.sequencer", "random_test_config", random_test_cfg_h);

    edge_case_test_cfg_h = edge_case_test_config::type_id::create("edge_case_test_cfg_h");
    uvm_config_db#(edge_case_test_config)::set(this, "env.agent.sequencer", "edge_case_test_config", edge_case_test_cfg_h);

  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Start all sequences on the real sequencer

    basic_transmission_seq::type_id::create("basic_transmission_seq_h").start(env.agent.sequencer);

    parity_test_seq::type_id::create("parity_test_seq_h").start(env.agent.sequencer);

    random_test_seq::type_id::create("random_test_seq_h").start(env.agent.sequencer);

    edge_case_test_seq::type_id::create("edge_case_test_seq_h").start(env.agent.sequencer);


    phase.drop_objection(this);
  endtask
endclass