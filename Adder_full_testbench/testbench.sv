`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

//======================================================================
// Transaction
//======================================================================
class adder_transaction extends uvm_sequence_item;
  rand logic [7:0] a;
  rand logic [7:0] b;

  logic [7:0] sum;
  logic       carry;

  `uvm_object_utils(adder_transaction)

  function new(string name="adder_transaction");
    super.new(name);
  endfunction
endclass

//======================================================================
// Configs + Sequences
//======================================================================
class basic_addition_config extends uvm_object;
  rand int a_min = 0;
  rand int a_max = 100;
  rand int b_min = 0;
  rand int b_max = 100;

  `uvm_object_utils(basic_addition_config)
  function new(string name="basic_addition_config"); super.new(name); endfunction
endclass

class basic_addition_seq extends uvm_sequence#(adder_transaction);
  basic_addition_config cfg;
  `uvm_object_utils(basic_addition_seq)
  function new(string name="basic_addition_seq"); super.new(name); endfunction

  task body();
    adder_transaction tr;
    if (!uvm_config_db#(basic_addition_config)::get(m_sequencer, "", "basic_addition_config", cfg))
      `uvm_fatal("NO_CFG","basic_addition_config not found")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (10) begin
      tr = adder_transaction::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with { tr.a inside {[cfg.a_min:cfg.a_max]}; tr.b inside {[cfg.b_min:cfg.b_max]}; })
        `uvm_error("RAND_FAIL","Randomization failed in basic_addition_seq")
      finish_item(tr);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

//----------------- Edge Case -----------------
class edge_case_test_config extends uvm_object;
  rand int a_min = 0;
  rand int a_max = 255;
  rand int b_min = 0;
  rand int b_max = 255;
  `uvm_object_utils(edge_case_test_config)
  function new(string name="edge_case_test_config"); super.new(name); endfunction
endclass

class edge_case_test_seq extends uvm_sequence#(adder_transaction);
  edge_case_test_config cfg;
  `uvm_object_utils(edge_case_test_seq)
  function new(string name="edge_case_test_seq"); super.new(name); endfunction

  task body();
    adder_transaction tr;
    if (!uvm_config_db#(edge_case_test_config)::get(m_sequencer,"","edge_case_test_config",cfg))
      `uvm_fatal("NO_CFG","edge_case_test_config not found")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (8) begin
      tr = adder_transaction::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with { tr.a inside {[cfg.a_min:cfg.a_max]}; tr.b inside {[cfg.b_min:cfg.b_max]}; })
        `uvm_error("RAND_FAIL","Randomization failed in edge_case_test_seq")
      finish_item(tr);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

//----------------- Large Values -----------------
class large_values_config extends uvm_object;
  rand int a_min = 200;
  rand int a_max = 255;
  rand int b_min = 200;
  rand int b_max = 255;
  `uvm_object_utils(large_values_config)
  function new(string name="large_values_config"); super.new(name); endfunction
endclass

class large_values_seq extends uvm_sequence#(adder_transaction);
  large_values_config cfg;
  `uvm_object_utils(large_values_seq)
  function new(string name="large_values_seq"); super.new(name); endfunction

  task body();
    adder_transaction tr;
    if (!uvm_config_db#(large_values_config)::get(m_sequencer,"","large_values_config",cfg))
      `uvm_fatal("NO_CFG","large_values_config not found")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (5) begin
      tr = adder_transaction::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with { tr.a inside {[cfg.a_min:cfg.a_max]}; tr.b inside {[cfg.b_min:cfg.b_max]}; })
        `uvm_error("RAND_FAIL","Randomization failed in large_values_seq")
      finish_item(tr);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

//----------------- Random -----------------
class random_test_config extends uvm_object;
  rand int a_min = 0;
  rand int a_max = 255;
  rand int b_min = 0;
  rand int b_max = 255;
  `uvm_object_utils(random_test_config)
  function new(string name="random_test_config"); super.new(name); endfunction
endclass

class random_test_seq extends uvm_sequence#(adder_transaction);
  random_test_config cfg;
  `uvm_object_utils(random_test_seq)
  function new(string name="random_test_seq"); super.new(name); endfunction

  task body();
    adder_transaction tr;
    if (!uvm_config_db#(random_test_config)::get(m_sequencer,"","random_test_config",cfg))
      `uvm_fatal("NO_CFG","random_test_config not found")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (15) begin
      tr = adder_transaction::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with { tr.a inside {[cfg.a_min:cfg.a_max]}; tr.b inside {[cfg.b_min:cfg.b_max]}; })
        `uvm_error("RAND_FAIL","Randomization failed in random_test_seq")
      finish_item(tr);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

//======================================================================
// Interface
//======================================================================
interface adder_if(input logic clk);
  logic rstn;
  logic [7:0] a;
  logic [7:0] b;
  logic [7:0] sum;
  logic       carry;

  clocking cb @(posedge clk);
    output a,b,rstn;
    input sum,carry;
  endclocking

  modport dut(input clk,rstn,a,b, output sum,carry);
endinterface

//======================================================================
// Driver
//======================================================================
class adder_driver extends uvm_driver#(adder_transaction);
  `uvm_component_utils(adder_driver)
  virtual adder_if vif;

  function new(string name,uvm_component parent); super.new(name,parent); endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual adder_if)::get(this,"","adder_if",vif))
      `uvm_fatal("NO_VIF","No vif for driver");
  endfunction

  task run_phase(uvm_phase phase);
    vif.cb.a <= 0;
    vif.cb.b <= 0;
    vif.cb.rstn <= 1;
    forever begin
      adder_transaction tr;
      seq_item_port.get_next_item(tr);
      @(vif.cb);
      vif.cb.a <= tr.a;
      vif.cb.b <= tr.b;
      seq_item_port.item_done();
    end
  endtask
endclass

//======================================================================
// Monitor
//======================================================================
class adder_monitor extends uvm_monitor;
  `uvm_component_utils(adder_monitor)
  virtual adder_if vif;
  uvm_analysis_port#(adder_transaction) ap;

  function new(string name,uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual adder_if)::get(this,"","adder_if",vif))
      `uvm_fatal("NO_VIF","No vif for monitor");
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if(vif.rstn) begin
        adder_transaction tr = adder_transaction::type_id::create("tr");
        tr.a = vif.a;
        tr.b = vif.b;
        tr.sum = vif.sum;
        tr.carry = vif.carry;
        ap.write(tr);
      end
    end
  endtask
endclass

//======================================================================
// Scoreboard
//======================================================================
class adder_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(adder_scoreboard)
  uvm_analysis_imp#(adder_transaction,adder_scoreboard) ap;

  function new(string name,uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction

  function void write(adder_transaction tr);
    bit [8:0] expected;
    expected = tr.a + tr.b;
    if (expected[7:0] !== tr.sum || expected[8] !== tr.carry)
      `uvm_error("MISMATCH",$sformatf("Expected sum=%0d carry=%0d, Got sum=%0d carry=%0d",
                   expected[7:0], expected[8], tr.sum, tr.carry))
    else
      `uvm_info("MATCH",$sformatf("a=%0d b=%0d sum=%0d carry=%0d OK",
                  tr.a,tr.b,tr.sum,tr.carry),UVM_LOW)
  endfunction
endclass

//======================================================================
// Agent
//======================================================================
class adder_agent extends uvm_agent;
  `uvm_component_utils(adder_agent)
  uvm_sequencer#(adder_transaction) sequencer;
  adder_driver driver;
  adder_monitor monitor;

  function new(string name,uvm_component parent); super.new(name,parent); endfunction

  function void build_phase(uvm_phase phase);
    sequencer = uvm_sequencer#(adder_transaction)::type_id::create("sequencer",this);
    driver    = adder_driver::type_id::create("driver",this);
    monitor   = adder_monitor::type_id::create("monitor",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass

//======================================================================
// Environment
//======================================================================
class adder_env extends uvm_env;
  `uvm_component_utils(adder_env)
  adder_agent agent;
  adder_scoreboard scoreboard;

  function new(string name,uvm_component parent); super.new(name,parent); endfunction

  function void build_phase(uvm_phase phase);
    agent      = adder_agent::type_id::create("agent",this);
    scoreboard = adder_scoreboard::type_id::create("scoreboard",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.monitor.ap.connect(scoreboard.ap);
  endfunction
endclass

//======================================================================
// Test
//======================================================================
class adder_test extends uvm_test;
  `uvm_component_utils(adder_test)
  adder_env env;

  basic_addition_config basic_cfg;
  edge_case_test_config edge_cfg;
  large_values_config large_cfg;
  random_test_config random_cfg;

  function new(string name="adder_test",uvm_component parent=null); super.new(name,parent); endfunction

  function void build_phase(uvm_phase phase);
    env = adder_env::type_id::create("env",this);

    basic_cfg = basic_addition_config::type_id::create("basic_cfg");
    uvm_config_db#(basic_addition_config)::set(this,"env.agent.sequencer","basic_addition_config",basic_cfg);

    edge_cfg = edge_case_test_config::type_id::create("edge_cfg");
    uvm_config_db#(edge_case_test_config)::set(this,"env.agent.sequencer","edge_case_test_config",edge_cfg);

    large_cfg = large_values_config::type_id::create("large_cfg");
    uvm_config_db#(large_values_config)::set(this,"env.agent.sequencer","large_values_config",large_cfg);

    random_cfg = random_test_config::type_id::create("random_cfg");
    uvm_config_db#(random_test_config)::set(this,"env.agent.sequencer","random_test_config",random_cfg);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    basic_addition_seq::type_id::create("s1").start(env.agent.sequencer);
    edge_case_test_seq::type_id::create("s2").start(env.agent.sequencer);
    large_values_seq::type_id::create("s3").start(env.agent.sequencer);
    random_test_seq::type_id::create("s4").start(env.agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass

//======================================================================
// DUT (Simple Adder)
//======================================================================
module adder (
  input  logic        rstn,
  input  logic [7:0]  a,
  input  logic [7:0]  b,
  output logic [7:0]  sum,
  output logic        carry
);
  assign {carry,sum} = (!rstn) ? 9'd0 : (a+b);
endmodule

//======================================================================
// Top TB
//======================================================================
module tb_top;
  logic clk;
  adder_if vif(.clk(clk));
  adder dut(.rstn(vif.rstn), .a(vif.a), .b(vif.b), .sum(vif.sum), .carry(vif.carry));

  initial clk=0; always #5 clk=~clk;
  initial begin
    vif.rstn=0; #20; vif.rstn=1;
  end

  initial begin
    uvm_config_db#(virtual adder_if)::set(null,"*","adder_if",vif);
    run_test("adder_test");
  end

  initial begin
    #100000; $finish;
  end
endmodule
