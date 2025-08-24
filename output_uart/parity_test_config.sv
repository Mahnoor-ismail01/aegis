
`include "uvm_macros.svh"
import uvm_pkg::*;

class parity_test_config extends uvm_object;
  // data_width kept for convenience
  rand int data_width = 8;

  // Ranged fields (both port-backed and extras)

  rand int baud_rate_min = 19200;
  rand int baud_rate_max = 19200;

  rand int tx_data_min = 0;
  rand int tx_data_max = 255;


  // Boolean fields

  rand bit enable_parity = 1'b1;


  `uvm_object_utils(parity_test_config)
  function new(string name = "parity_test_config");
    super.new(name);
  endfunction
endclass