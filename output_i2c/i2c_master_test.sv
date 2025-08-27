
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_master_test extends uvm_test;
  `uvm_component_utils(i2c_master_test)

  i2c_master_env env;


  single_write_config single_write_cfg_h;

  single_read_config single_read_cfg_h;

  multiple_write_config multiple_write_cfg_h;

  multiple_read_config multiple_read_cfg_h;

  edge_case_config edge_case_cfg_h;


  function new(string name = "i2c_master_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = i2c_master_env::type_id::create("env", this);


    single_write_cfg_h = single_write_config::type_id::create("single_write_cfg_h");
    uvm_config_db#(single_write_config)::set(this, "env.agent.sequencer", "single_write_config", single_write_cfg_h);

    single_read_cfg_h = single_read_config::type_id::create("single_read_cfg_h");
    uvm_config_db#(single_read_config)::set(this, "env.agent.sequencer", "single_read_config", single_read_cfg_h);

    multiple_write_cfg_h = multiple_write_config::type_id::create("multiple_write_cfg_h");
    uvm_config_db#(multiple_write_config)::set(this, "env.agent.sequencer", "multiple_write_config", multiple_write_cfg_h);

    multiple_read_cfg_h = multiple_read_config::type_id::create("multiple_read_cfg_h");
    uvm_config_db#(multiple_read_config)::set(this, "env.agent.sequencer", "multiple_read_config", multiple_read_cfg_h);

    edge_case_cfg_h = edge_case_config::type_id::create("edge_case_cfg_h");
    uvm_config_db#(edge_case_config)::set(this, "env.agent.sequencer", "edge_case_config", edge_case_cfg_h);

  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);


    single_write_seq::type_id::create("single_write_seq_h").start(env.agent.sequencer);

    single_read_seq::type_id::create("single_read_seq_h").start(env.agent.sequencer);

    multiple_write_seq::type_id::create("multiple_write_seq_h").start(env.agent.sequencer);

    multiple_read_seq::type_id::create("multiple_read_seq_h").start(env.agent.sequencer);

    edge_case_seq::type_id::create("edge_case_seq_h").start(env.agent.sequencer);


    phase.drop_objection(this);
  endtask
endclass