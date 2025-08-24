
`include "uvm_macros.svh"
import uvm_pkg::*;

class adder_test extends uvm_test;
  `uvm_component_utils(adder_test)

  adder_env env;


  basic_addition_config basic_addition_cfg_h;

  edge_case_test_config edge_case_test_cfg_h;

  large_values_config large_values_cfg_h;

  random_test_config random_test_cfg_h;


  function new(string name = "adder_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = adder_env::type_id::create("env", this);

    // Create and scope config(s) to the sequencer

    basic_addition_cfg_h = basic_addition_config::type_id::create("basic_addition_cfg_h");
    uvm_config_db#(basic_addition_config)::set(this, "env.agent.sequencer", "basic_addition_config", basic_addition_cfg_h);

    edge_case_test_cfg_h = edge_case_test_config::type_id::create("edge_case_test_cfg_h");
    uvm_config_db#(edge_case_test_config)::set(this, "env.agent.sequencer", "edge_case_test_config", edge_case_test_cfg_h);

    large_values_cfg_h = large_values_config::type_id::create("large_values_cfg_h");
    uvm_config_db#(large_values_config)::set(this, "env.agent.sequencer", "large_values_config", large_values_cfg_h);

    random_test_cfg_h = random_test_config::type_id::create("random_test_cfg_h");
    uvm_config_db#(random_test_config)::set(this, "env.agent.sequencer", "random_test_config", random_test_cfg_h);

  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Start all sequences on the real sequencer

    basic_addition_seq::type_id::create("basic_addition_seq_h").start(env.agent.sequencer);

    edge_case_test_seq::type_id::create("edge_case_test_seq_h").start(env.agent.sequencer);

    large_values_seq::type_id::create("large_values_seq_h").start(env.agent.sequencer);

    random_test_seq::type_id::create("random_test_seq_h").start(env.agent.sequencer);


    phase.drop_objection(this);
  endtask
endclass