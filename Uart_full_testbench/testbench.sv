`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

//======================================================================
// Transaction
//======================================================================

class uart_transaction extends uvm_sequence_item;








  rand logic [7:0] tx_data;





  rand logic [0:0] tx_start;





  logic [0:0] tx;





  logic [0:0] tx_done;





  rand int baud_rate;



  rand bit enable_parity;


  `uvm_object_utils(uart_transaction)

  function new(string name = "uart_transaction");
    super.new(name);
  endfunction
endclass
//======================================================================
// Config + Sequences
//======================================================================
class basic_transmission_config extends uvm_object;
  rand int       data_width    = 8;
  rand int       tx_data_min   = 0;
  rand int       tx_data_max   = 255;
  rand int       baud_rate_min = 9600;
  rand int       baud_rate_max = 9600;
  rand bit       enable_parity = 1'b0;

  `uvm_object_utils(basic_transmission_config)
  function new(string name="basic_transmission_config");
    super.new(name);
  endfunction
endclass

class basic_transmission_seq extends uvm_sequence#(uart_transaction);
  basic_transmission_config cfg;
  `uvm_object_utils(basic_transmission_seq)

  function new(string name = "basic_transmission_seq");
    super.new(name);
  endfunction

  task body();
    uart_transaction tx;

    if (!uvm_config_db#(basic_transmission_config)::get(m_sequencer, "", "basic_transmission_config", cfg))
      `uvm_fatal("NO_CFG", "Config not found for basic_transmission_seq")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (10) begin
      tx = uart_transaction::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {

        tx.baud_rate inside {[cfg.baud_rate_min : cfg.baud_rate_max]};


        tx.enable_parity == cfg.enable_parity;

      }) begin
        `uvm_error("RAND_FAIL","Randomization failed in basic_transmission_seq")
      end
      finish_item(tx);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

class parity_test_config extends uvm_object;
  rand int       data_width    = 8;
  rand int       tx_data_min   = 0;
  rand int       tx_data_max   = 255;
  rand int       baud_rate_min = 19200;
  rand int       baud_rate_max = 19200;
  rand bit       enable_parity = 1'b1;

  `uvm_object_utils(parity_test_config)
  function new(string name="parity_test_config");
    super.new(name);
  endfunction
endclass

class parity_test_seq extends uvm_sequence#(uart_transaction);
  parity_test_config cfg;
  `uvm_object_utils(parity_test_seq)

  function new(string name="parity_test_seq");
    super.new(name);
  endfunction

  task body();
    uart_transaction tx;
    if (!uvm_config_db#(parity_test_config)::get(m_sequencer, "", "parity_test_config", cfg))
      `uvm_fatal("NO_CFG","Config not found for parity_test_seq")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (5) begin
      tx = uart_transaction::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
            tx.tx_data   inside {[cfg.tx_data_min : cfg.tx_data_max]};
            tx.baud_rate inside {[cfg.baud_rate_min : cfg.baud_rate_max]};
            tx.enable_parity == cfg.enable_parity;
            tx.tx_start == 1;
          }) begin
        `uvm_error("RAND_FAIL","Randomization failed in parity_test_seq")
      end
      finish_item(tx);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

class random_test_config extends uvm_object;
  rand int       data_width    = 8;
  rand int       tx_data_min   = 0;
  rand int       tx_data_max   = 255;
  rand int       baud_rate_min = 9600;
  rand int       baud_rate_max = 115200;
  rand bit       enable_parity = 1'b0;

  `uvm_object_utils(random_test_config)
  function new(string name="random_test_config");
    super.new(name);
  endfunction
endclass

class random_test_seq extends uvm_sequence#(uart_transaction);
  random_test_config cfg;
  `uvm_object_utils(random_test_seq)

  function new(string name="random_test_seq");
    super.new(name);
  endfunction

  task body();
    uart_transaction tx;
    if (!uvm_config_db#(random_test_config)::get(m_sequencer, "", "random_test_config", cfg))
      `uvm_fatal("NO_CFG","Config not found for random_test_seq")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (15) begin
      tx = uart_transaction::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
            tx.tx_data   inside {[cfg.tx_data_min : cfg.tx_data_max]};
            tx.baud_rate inside {[cfg.baud_rate_min : cfg.baud_rate_max]};
            tx.enable_parity == cfg.enable_parity;
            tx.tx_start == 1;
          }) begin
        `uvm_error("RAND_FAIL","Randomization failed in random_test_seq")
      end
      finish_item(tx);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

class edge_case_test_config extends uvm_object;
  rand int       data_width    = 8;
  rand int       tx_data_min   = 0;
  rand int       tx_data_max   = 255;
  rand int       baud_rate_min = 4800;
  rand int       baud_rate_max = 115200;
  rand bit       enable_parity = 1'b1;

  `uvm_object_utils(edge_case_test_config)
  function new(string name="edge_case_test_config");
    super.new(name);
  endfunction
endclass

class edge_case_test_seq extends uvm_sequence#(uart_transaction);
  edge_case_test_config cfg;
  `uvm_object_utils(edge_case_test_seq)

  function new(string name="edge_case_test_seq");
    super.new(name);
  endfunction

  task body();
    uart_transaction tx;
    if (!uvm_config_db#(edge_case_test_config)::get(m_sequencer, "", "edge_case_test_config", cfg))
      `uvm_fatal("NO_CFG","Config not found for edge_case_test_seq")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat (8) begin
      tx = uart_transaction::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
            tx.tx_data   inside {[cfg.tx_data_min : cfg.tx_data_max]};
            tx.baud_rate inside {[cfg.baud_rate_min : cfg.baud_rate_max]};
            tx.enable_parity == cfg.enable_parity;
            tx.tx_start == 1;
          }) begin
        `uvm_error("RAND_FAIL","Randomization failed in edge_case_test_seq")
      end
      finish_item(tx);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

//======================================================================
// Interface
//======================================================================
interface uart_if (input logic clk, input logic reset_n);
  logic [7:0] tx_data;
  logic       tx_start;
  logic       tx;
  logic       tx_done;

  // Driver clocking block - outputs from driver (to DUT)
  clocking cb @(posedge clk);
    input  reset_n;
    output tx_data, tx_start;
    input  tx, tx_done;
  endclocking

  modport dut (input clk, reset_n, tx_data, tx_start,
               output tx, tx_done);
endinterface

//======================================================================
// Driver
//======================================================================
class uart_driver extends uvm_driver#(uart_transaction);
  `uvm_component_utils(uart_driver)
  virtual uart_if vif;
  int baud_rate;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_if", vif))
      `uvm_fatal("NO_VIF","Virtual interface not found");
  endfunction

  task run_phase(uvm_phase phase);
    // drive safe defaults on clocking block
    vif.cb.tx_data  <= '0;
    vif.cb.tx_start <= '0;

    forever begin
      uart_transaction tx;
      @(vif.cb); // sample / drive at clocking-block boundary

      if (!vif.reset_n) begin
        vif.cb.tx_data  <= '0;
        vif.cb.tx_start <= '0;
        continue;
      end

      seq_item_port.get_next_item(tx);

      // drive the DUT inputs via clocking block outputs
      vif.cb.tx_data <= tx.tx_data;

      // pulse tx_start one cycle
      if (tx.tx_start) begin
        vif.cb.tx_start <= 1'b1;
        @(vif.cb);
        vif.cb.tx_start <= 1'b0;
      end

      baud_rate = tx.baud_rate; // keep for debug/logging

      seq_item_port.item_done();

      // wait for tx_done asserted by DUT (reading clocking-block inputs is fine)
      while (!vif.cb.tx_done) @(vif.cb);
    end
  endtask
endclass

//======================================================================
// Monitor
//======================================================================
class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)
  virtual uart_if vif;
  uvm_analysis_port#(uart_transaction) ap;

  function new(string name, uvm_component parent);
    super.new(name,parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_if", vif))
      `uvm_fatal("NO_VIF","Virtual interface not found");
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      uart_transaction tx;
      @(posedge vif.clk);
      if (vif.reset_n && vif.tx_start) begin
        tx = uart_transaction::type_id::create("tx");
        tx.tx_data  = vif.tx_data;
        tx.tx_start = vif.tx_start;
        // wait until DUT asserts done
        while (!vif.tx_done) @(posedge vif.clk);
        tx.tx_done = 1'b1;
        ap.write(tx);
      end
    end
  endtask
endclass

//======================================================================
// Scoreboard
//======================================================================
class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  // analysis imp implementing write(uart_transaction)
  uvm_analysis_imp#(uart_transaction, uart_scoreboard) ap;

  // internal store of seen transactions
  uart_transaction seen_tx[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  // Called by monitor via analysis connection
 function void write(uart_transaction t);
   uart_transaction exp_t;        // ✅ declare first
   $display("Got transaction");
endfunction


endclass

//======================================================================
// Agent
//======================================================================
class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)
  uvm_sequencer#(uart_transaction) sequencer;
  uart_driver   driver;
  uart_monitor  monitor;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    sequencer = uvm_sequencer#(uart_transaction)::type_id::create("sequencer", this);
    driver    = uart_driver::type_id::create("driver", this);
    monitor   = uart_monitor::type_id::create("monitor", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass

//======================================================================
// Environment
//======================================================================
class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)
  uart_agent      agent;
  uart_scoreboard scoreboard;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    agent      = uart_agent::type_id::create("agent", this);
    scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    // connect monitor -> scoreboard
    agent.monitor.ap.connect(scoreboard.ap);
  endfunction
endclass

//======================================================================
// Test
//======================================================================
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

    basic_transmission_seq::type_id::create("basic_transmission_seq_h").start(env.agent.sequencer);

    parity_test_seq::type_id::create("parity_test_seq_h").start(env.agent.sequencer);

    random_test_seq::type_id::create("random_test_seq_h").start(env.agent.sequencer);

    edge_case_test_seq::type_id::create("edge_case_test_seq_h").start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask
endclass
//======================================================================
// DUT (simplified UART TX)
//======================================================================
module uart_dut (
  input  wire        clk,
  input  wire        reset_n,
  input  wire [7:0]  tx_data,
  input  wire        tx_start,
  output reg         tx,
  output reg         tx_done
);
  // DUT uses BAUD_RATE parameter for timing in simulation; sequences pass baud_rate only for logging
  parameter  CLK_FREQ  = 100_000_000;
  parameter  BAUD_RATE = 9600;
  localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;

  reg [7:0]  shift_reg;
  reg [31:0] baud_counter;
  reg [3:0]  bit_counter;
  reg [1:0]  state;
  localparam IDLE=2'b00, START=2'b01, DATA=2'b10, STOP=2'b11;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      tx <= 1;
      tx_done <= 0;
      shift_reg <= 0;
      baud_counter <= 0;
      bit_counter <= 0;
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          tx <= 1; tx_done <= 0;
          if (tx_start) begin
            shift_reg <= tx_data;
            state <= START;
            baud_counter <= 0;
          end
        end
        START: begin
          tx <= 0;
          if (baud_counter >= BAUD_TICK - 1) begin
            baud_counter <= 0;
            state <= DATA;
            bit_counter <= 0;
          end else baud_counter <= baud_counter + 1;
        end
        DATA: begin
          tx <= shift_reg[0];
          if (baud_counter >= BAUD_TICK - 1) begin
            baud_counter <= 0;
            shift_reg <= {1'b0, shift_reg[7:1]};
            bit_counter <= bit_counter + 1;
            if (bit_counter == 4'd7) state <= STOP;
          end else baud_counter <= baud_counter + 1;
        end
        STOP: begin
          tx <= 1;
          if (baud_counter >= BAUD_TICK - 1) begin
            baud_counter <= 0;
            tx_done <= 1;
            state <= IDLE;
          end else baud_counter <= baud_counter + 1;
        end
      endcase
    end
  end
endmodule

//======================================================================
// Top TB
//======================================================================
module tb_top;
  logic clk;
  logic reset_n;

  uart_if vif(.clk(clk), .reset_n(reset_n));
  uart_dut dut(
    .clk(clk),
    .reset_n(reset_n),
    .tx_data(vif.tx_data),
    .tx_start(vif.tx_start),
    .tx(vif.tx),
    .tx_done(vif.tx_done)
  );

  initial begin clk = 0; forever #5 clk = ~clk; end

  initial begin
    reset_n = 0;
    #20 reset_n = 1;
  end

  initial begin
    // publish virtual interface for components
    uvm_config_db#(virtual uart_if)::set(null, "*", "uart_if", vif);
    run_test("uart_test");
  end

  // Safety timeout
  initial begin
    #500000;
    $display("TIMEOUT: stopping simulation");
    $finish;
  end
endmodule
