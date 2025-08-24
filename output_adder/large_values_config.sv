
`include "uvm_macros.svh"
import uvm_pkg::*;

class large_values_config extends uvm_object;
  // data_width kept for convenience
  rand int data_width = 8;

  // Ranged fields (both port-backed and extras)

  rand int a_min = 200;
  rand int a_max = 255;

  rand int b_min = 200;
  rand int b_max = 255;


  // Boolean fields


  `uvm_object_utils(large_values_config)
  function new(string name = "large_values_config");
    super.new(name);
  endfunction
endclass