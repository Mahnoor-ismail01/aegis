
`include "uvm_macros.svh"
import uvm_pkg::*;

class edge_case_test_config extends uvm_object;
  // data_width kept for convenience
  rand int data_width = 8;

  // Ranged fields (both port-backed and extras)

  rand int baud_rate_min = 4800;
  rand int baud_rate_max = 115200;

  rand int tx_data_min = 0;
  rand int tx_data_max = 255;


  // Boolean fields

  rand bit enable_parity = 1'b1;


  `uvm_object_utils(edge_case_test_config)
  function new(string name = "edge_case_test_config");
    super.new(name);
  endfunction
endclass