// fifo_uvm_tb.sv — corrected complete UVM testbench (fixed timing + safe sequences)
`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

//======================================================================
// Transaction
//======================================================================
class fifo_item extends uvm_sequence_item;
  rand bit        wr_en;
  rand bit        rd_en;
  rand bit [7:0]  din;
       bit [7:0]  dout; // captured by monitor

  `uvm_object_utils_begin(fifo_item)
    `uvm_field_int(wr_en, UVM_ALL_ON)
    `uvm_field_int(rd_en, UVM_ALL_ON)
    `uvm_field_int(din,   UVM_ALL_ON)
    `uvm_field_int(dout,  UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "fifo_item");
    super.new(name);
  endfunction
endclass

//======================================================================
// Virtual Interface (clocking for aligned sampling/driving)
//======================================================================
interface fifo_if(input bit clk);
  bit rst_n;
  bit wr_en;
  bit rd_en;
  bit [7:0] din;
  bit [7:0] dout;

  // clocking block: outputs are driven at posedge, inputs sampled at posedge
  clocking cb @(posedge clk);
    output rst_n, wr_en, rd_en, din;
    input  dout;
  endclocking

  // modport for DUT using signals directly
  modport DUT (input clk, rst_n, wr_en, rd_en, din, output dout);
endinterface

//======================================================================
// DRIVER (drives aligned to clock, holds strobes for one cycle)
//======================================================================
class fifo_driver extends uvm_driver#(fifo_item);
  `uvm_component_utils(fifo_driver)
  virtual fifo_if vif;

  function new(string name = "fifo_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_if)::get(this, "", "fifo_if", vif))
      `uvm_fatal("NOVIF", "No virtual interface for fifo_driver");
  endfunction

  task run_phase(uvm_phase phase);
    fifo_item tr;
    // initialize (drive via clocking to align)
    @(posedge vif.clk);
    vif.cb.wr_en <= 0;
    vif.cb.rd_en <= 0;
    vif.cb.din   <= '0;
    // rst_n set by TB; ensure known
    @(posedge vif.clk);

    forever begin
      seq_item_port.get_next_item(tr);

      // apply transaction at posedge and keep for one cycle
      @(posedge vif.clk);
      vif.cb.wr_en <= tr.wr_en;
      vif.cb.rd_en <= tr.rd_en;
      vif.cb.din   <= tr.din;

      // hold for exactly one cycle so DUT and monitor see it
      @(posedge vif.clk);
      // deassert strobes
      vif.cb.wr_en <= 0;
      vif.cb.rd_en <= 0;
      vif.cb.din   <= '0;

      seq_item_port.item_done();
    end
  endtask
endclass

//======================================================================
// MONITOR (samples aligned to same clocking block)
//======================================================================
class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)
  virtual fifo_if vif;
  uvm_analysis_port#(fifo_item) ap;

  function new(string name = "fifo_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_if)::get(this, "", "fifo_if", vif))
      `uvm_fatal("NOVIF", "No virtual interface for fifo_monitor");
  endfunction

  task run_phase(uvm_phase phase);
    fifo_item it;
    forever begin
      // sample on posedge via clocking block for alignment
      @(vif.cb);
      it = fifo_item::type_id::create("mon_it");
      it.wr_en = vif.cb.wr_en;
      it.rd_en = vif.cb.rd_en;
      it.din   = vif.cb.din;

      // If read asserted, DUT will update dout synchronously on that posedge.
      // Capture dout on the next posedge to get the DUT-updated value.
      if (it.rd_en) begin
        @(vif.cb);
        it.dout = vif.cb.dout;
      end else begin
        it.dout = vif.cb.dout;
      end

      if (it.wr_en || it.rd_en) begin
        `uvm_info("MON", $sformatf("MON: wr=%0b rd=%0b din=%0d dout=%0d", it.wr_en, it.rd_en, it.din, it.dout), UVM_LOW)
        ap.write(it);
      end
    end
  endtask
endclass

//======================================================================
// SCOREBOARD
//======================================================================
class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)
  uvm_analysis_imp#(fifo_item, fifo_scoreboard) ap;

  bit [7:0] expected_q[$];

  function new(string name = "fifo_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void write(fifo_item t);
    // On write, push expected data
    if (t.wr_en) begin
      expected_q.push_back(t.din);
      `uvm_info("SCOREBOARD", $sformatf("SCOREBOARD: queued %0d (size=%0d)", t.din, expected_q.size()), UVM_LOW)
    end

    // On read, compare to front of expected queue if available
    if (t.rd_en) begin
      if (expected_q.size() == 0) begin
        `uvm_warning("UNDERFLOW", "Read occurred but expected queue empty")
      end else begin
        bit [7:0] exp = expected_q.pop_front();
        if (exp !== t.dout) begin
          `uvm_error("MISMATCH", $sformatf("exp=%0d got=%0d", exp, t.dout));
        end else begin
          `uvm_info("MATCH", $sformatf("READ MATCH %0d", t.dout), UVM_LOW);
        end
      end
    end
  endfunction
endclass

//======================================================================
// AGENT + ENV
//======================================================================
typedef uvm_sequencer#(fifo_item) fifo_sequencer;

class fifo_agent extends uvm_agent;
  `uvm_component_utils(fifo_agent)
  fifo_sequencer sequencer;
  fifo_driver    driver;
  fifo_monitor   monitor;

  function new(string name = "fifo_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer = fifo_sequencer::type_id::create("sequencer", this);
    driver    = fifo_driver   ::type_id::create("driver",    this);
    monitor   = fifo_monitor  ::type_id::create("monitor",   this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass

class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)
  fifo_agent      agent;
  fifo_scoreboard scoreboard;

  function new(string name = "fifo_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent      = fifo_agent     ::type_id::create("agent",      this);
    scoreboard = fifo_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.ap.connect(scoreboard.ap);
  endfunction
endclass

//======================================================================
// CONFIG CLASSES
//======================================================================
class basic_rw_config extends uvm_object;
  `uvm_object_utils(basic_rw_config)
  int num_ops = 8;
  int din_min = 0;
  int din_max = 255;
  function new(string name="basic_rw_config"); super.new(name); endfunction
endclass

class write_only_config extends uvm_object;
  `uvm_object_utils(write_only_config)
  int num_ops = 16;
  int din_min = 0;
  int din_max = 255;
  function new(string name="write_only_config"); super.new(name); endfunction
endclass

class read_only_config extends uvm_object;
  `uvm_object_utils(read_only_config)
  int num_ops = 8;
  function new(string name="read_only_config"); super.new(name); endfunction
endclass

class overflow_bias_config extends uvm_object;
  `uvm_object_utils(overflow_bias_config)
  int num_ops = 40;
  int din_min = 0;
  int din_max = 255;
  int wr_pct = 80;
  function new(string name="overflow_bias_config"); super.new(name); endfunction
endclass

class random_rw_config extends uvm_object;
  `uvm_object_utils(random_rw_config)
  int num_ops = 80;
  int din_min = 0;
  int din_max = 255;
  function new(string name="random_rw_config"); super.new(name); endfunction
endclass

//======================================================================
// SEQUENCES (seed reads to avoid underflow; hold objections)
//======================================================================
class basic_rw_seq extends uvm_sequence#(fifo_item);
  `uvm_object_utils(basic_rw_seq)
  basic_rw_config cfg;
  function new(string name="basic_rw_seq"); super.new(name); endfunction

  task body();
    int i;
    fifo_item tr;
    if (!uvm_config_db#(basic_rw_config)::get(m_sequencer, "", "basic_rw_config", cfg))
      `uvm_fatal("NOCFG", "basic_rw_config not set");

    if (starting_phase != null) starting_phase.raise_objection(this);

    
    // write N items
    for (i = 0; i < cfg.num_ops; i++) begin
      tr = fifo_item::type_id::create($sformatf("wr_%0d", i));
      start_item(tr);
      assert(tr.randomize() with { din inside {[cfg.din_min:cfg.din_max]}; wr_en == 1; rd_en == 0; })
        else `uvm_error("RAND_FAIL", "basic_rw_seq write randomize failed");
      finish_item(tr);
    end

    // read N items
    for (i = 0; i < cfg.num_ops; i++) begin
      tr = fifo_item::type_id::create($sformatf("rd_%0d", i));
      tr.wr_en = 0; tr.rd_en = 1; tr.din = '0;
      start_item(tr); finish_item(tr);
    end

    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

class write_only_seq extends uvm_sequence#(fifo_item);
  `uvm_object_utils(write_only_seq)
  write_only_config cfg;
  function new(string name="write_only_seq"); super.new(name); endfunction

  task body();
    int i;
    fifo_item tr;
    if (!uvm_config_db#(write_only_config)::get(m_sequencer, "", "write_only_config", cfg))
      `uvm_fatal("NOCFG", "write_only_config not set");

    if (starting_phase != null) starting_phase.raise_objection(this);
    
    for (i = 0; i < cfg.num_ops; i++) begin
      tr = fifo_item::type_id::create($sformatf("wonly_%0d", i));
      start_item(tr);
      assert(tr.randomize() with { din inside {[cfg.din_min:cfg.din_max]}; wr_en == 1; rd_en == 0; })
        else `uvm_error("RAND_FAIL", "write_only_seq randomize failed");
      finish_item(tr);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

class read_only_seq extends uvm_sequence#(fifo_item);
  `uvm_object_utils(read_only_seq)
  read_only_config cfg;
  function new(string name="read_only_seq"); super.new(name); endfunction

  task body();
    int i;
    fifo_item tr;
    if (!uvm_config_db#(read_only_config)::get(m_sequencer, "", "read_only_config", cfg))
      `uvm_fatal("NOCFG", "read_only_config not set");

    if (starting_phase != null) starting_phase.raise_objection(this);

    
    // pre-seed a few writes to avoid immediate underflow
    for (i = 0; i < (cfg.num_ops/4 + 1); i++) begin
      tr = fifo_item::type_id::create($sformatf("pre_wr_%0d", i));
      start_item(tr);
      assert(tr.randomize() with { din inside {[0:255]}; wr_en == 1; rd_en == 0; });
      finish_item(tr);
    end

    // then reads
    for (i = 0; i < cfg.num_ops; i++) begin
      tr = fifo_item::type_id::create($sformatf("rd_%0d", i));
      tr.wr_en = 0; tr.rd_en = 1; tr.din = '0;
      start_item(tr); finish_item(tr);
    end

    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

class overflow_bias_seq extends uvm_sequence#(fifo_item);
  `uvm_object_utils(overflow_bias_seq)

  overflow_bias_config cfg;

  function new(string name="overflow_bias_seq");
    super.new(name);
  endfunction

  task body();
    int i;
    int coin;                // ✅ moved here
    fifo_item tr;

    if (!uvm_config_db#(overflow_bias_config)::get(m_sequencer, "", "overflow_bias_config", cfg))
      `uvm_fatal("NOCFG", "overflow_bias_config not set");

    if (starting_phase != null) starting_phase.raise_objection(this);

    // seed some writes
    for (i = 0; i < 4; i++) begin
      tr = fifo_item::type_id::create($sformatf("seed_wr_%0d", i));
      start_item(tr);
      assert(tr.randomize() with { din inside {[cfg.din_min:cfg.din_max]}; wr_en == 1; rd_en == 0; });
      finish_item(tr);
    end

    for (i = 0; i < cfg.num_ops; i++) begin
      tr = fifo_item::type_id::create($sformatf("op_%0d", i));
      coin = $urandom_range(0,99);   // ✅ assignment only
      start_item(tr);
      if (coin < cfg.wr_pct) begin
        assert(tr.randomize() with { din inside {[cfg.din_min:cfg.din_max]}; wr_en == 1; rd_en == 0; });
      end else begin
        tr.wr_en = 0;
        tr.rd_en = 1;
        tr.din   = '0;
      end
      finish_item(tr);
    end

    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

class random_rw_seq extends uvm_sequence#(fifo_item);
  `uvm_object_utils(random_rw_seq)
  random_rw_config cfg;
  function new(string name="random_rw_seq"); super.new(name); endfunction

  task body();
    int i;
    fifo_item tr;
    if (!uvm_config_db#(random_rw_config)::get(m_sequencer, "", "random_rw_config", cfg))
      `uvm_fatal("NOCFG", "random_rw_config not set");

    if (starting_phase != null) starting_phase.raise_objection(this);

    
    // seed writes
    for (i = 0; i < 5; i++) begin
      tr = fifo_item::type_id::create($sformatf("seed_wr_%0d", i));
      start_item(tr);
      assert(tr.randomize() with { din inside {[cfg.din_min:cfg.din_max]}; wr_en == 1; rd_en == 0; });
      finish_item(tr);
    end

    for (i = 0; i < cfg.num_ops; i++) begin
      tr = fifo_item::type_id::create($sformatf("rand_%0d", i));
      start_item(tr);
      if ($urandom_range(0,1) == 0) begin
        assert(tr.randomize() with { din inside {[cfg.din_min:cfg.din_max]}; wr_en == 1; rd_en == 0; });
      end else begin
        tr.wr_en = 0; tr.rd_en = 1; tr.din = '0;
      end
      finish_item(tr);
    end

    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass

//======================================================================
// TEST
//======================================================================
class fifo_test extends uvm_test;
  `uvm_component_utils(fifo_test)
  fifo_env env;

  basic_rw_config        basic_cfg_h;
  write_only_config      wonly_cfg_h;
  read_only_config       ronly_cfg_h;
  overflow_bias_config   obias_cfg_h;
  random_rw_config       rrw_cfg_h;

  function new(string name = "fifo_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);

    basic_cfg_h  = basic_rw_config::type_id::create("basic_cfg_h");
    basic_cfg_h.num_ops = 8;
    wonly_cfg_h  = write_only_config::type_id::create("wonly_cfg_h");
    wonly_cfg_h.num_ops = 16;
    ronly_cfg_h  = read_only_config::type_id::create("ronly_cfg_h");
    ronly_cfg_h.num_ops = 8;
    obias_cfg_h  = overflow_bias_config::type_id::create("obias_cfg_h");
    obias_cfg_h.num_ops = 40;
    rrw_cfg_h    = random_rw_config::type_id::create("rrw_cfg_h");
    rrw_cfg_h.num_ops = 80;

    uvm_config_db#(basic_rw_config     )::set(this, "env.agent.sequencer", "basic_rw_config",      basic_cfg_h);
    uvm_config_db#(write_only_config   )::set(this, "env.agent.sequencer", "write_only_config",    wonly_cfg_h);
    uvm_config_db#(read_only_config    )::set(this, "env.agent.sequencer", "read_only_config",     ronly_cfg_h);
    uvm_config_db#(overflow_bias_config)::set(this, "env.agent.sequencer", "overflow_bias_config", obias_cfg_h);
    uvm_config_db#(random_rw_config    )::set(this, "env.agent.sequencer", "random_rw_config",     rrw_cfg_h);
  endfunction

  task run_phase(uvm_phase phase);
    basic_rw_seq      basic_seq_h;
    write_only_seq    write_seq_h;
    read_only_seq     read_seq_h;
    overflow_bias_seq obias_seq_h;
    random_rw_seq     rrw_seq_h;

    phase.raise_objection(this);

    // run sequences serially so the single sequencer executes them one-by-one
    basic_seq_h  = basic_rw_seq::type_id::create("basic_seq_h"); basic_seq_h.start(env.agent.sequencer);
    write_seq_h  = write_only_seq::type_id::create("write_seq_h"); write_seq_h.start(env.agent.sequencer);
    read_seq_h   = read_only_seq::type_id::create("read_seq_h");  read_seq_h.start(env.agent.sequencer);
    obias_seq_h  = overflow_bias_seq::type_id::create("obias_seq_h"); obias_seq_h.start(env.agent.sequencer);
    rrw_seq_h    = random_rw_seq::type_id::create("rrw_seq_h"); rrw_seq_h.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask
endclass

//======================================================================
// DUT: Simple synchronous FIFO (16x8)
// Implemented so a read gets the earliest written value. When both
// wr and rd asserted same cycle, behavior returns oldest available entry.
//======================================================================
module fifo(
  input  logic       clk,
  input  logic       rst_n,
  input  logic       wr_en,
  input  logic       rd_en,
  input  logic [7:0] din,
  output logic [7:0] dout
);
  logic [7:0] mem[0:15];
  int unsigned wr_ptr, rd_ptr, count;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= 0; rd_ptr <= 0; count <= 0; dout <= '0;
    end else begin
      // Handle write (store)
      if (wr_en && (count < 16)) begin
        mem[wr_ptr] <= din;
        wr_ptr <= (wr_ptr + 1) % 16;
        count <= count + 1;
      end

      // Handle read (output oldest)
      if (rd_en && (count > 0)) begin
        dout <= mem[rd_ptr];
        rd_ptr <= (rd_ptr + 1) % 16;
        count <= count - 1;
      end
    end
  end
endmodule

//======================================================================
// Top TB
//======================================================================
module tb_top;
  bit clk;
  fifo_if vif(.clk(clk));
  fifo dut(.clk(clk), .rst_n(vif.rst_n), .wr_en(vif.wr_en), .rd_en(vif.rd_en),
           .din(vif.din), .dout(vif.dout));

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    // reset
    vif.rst_n = 0; vif.wr_en = 0; vif.rd_en = 0; vif.din = '0;
    #40; vif.rst_n = 1;
  end

  initial begin
    // publish virtual interface and run UVM test
    uvm_config_db#(virtual fifo_if)::set(null, "*", "fifo_if", vif);
    run_test("fifo_test");
  end

  initial begin
    #200000; $finish;
  end
endmodule
