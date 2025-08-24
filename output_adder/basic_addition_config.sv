
`include "uvm_macros.svh"
import uvm_pkg::*;

class basic_addition_config extends uvm_object;
  // data_width kept for convenience
  rand int data_width = 8;

  // Ranged fields (both port-backed and extras)

  rand int a_min = 0;
  rand int a_max = 100;

  rand int b_min = 0;
  rand int b_max = 100;


  // Boolean fields


  `uvm_object_utils(basic_addition_config)
  function new(string name = "basic_addition_config");
    super.new(name);
  endfunction
endclass