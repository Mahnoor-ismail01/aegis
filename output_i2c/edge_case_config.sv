
`include "uvm_macros.svh"
import uvm_pkg::*;

class edge_case_config extends uvm_object;
  rand int data_width = 8;

  // Ranged fields

  rand int device_address_min = 0;
  rand int device_address_max = 127;

  rand int divider_min = 50;
  rand int divider_max = 65535;

  rand int mosi_data_min = 0;
  rand int mosi_data_max = 255;

  rand int register_address_min = 0;
  rand int register_address_max = 255;


  // Boolean fields


  `uvm_object_utils(edge_case_config)
  function new(string name = "edge_case_config");
    super.new(name);
  endfunction
endclass