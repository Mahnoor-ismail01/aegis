
`include "uvm_macros.svh"
import uvm_pkg::*;

class multiple_read_config extends uvm_object;
  rand int data_width = 8;

  // Ranged fields

  rand int device_address_min = 16;
  rand int device_address_max = 16;

  rand int divider_min = 200;
  rand int divider_max = 200;

  rand int mosi_data_min = 0;
  rand int mosi_data_max = 255;

  rand int register_address_min = 0;
  rand int register_address_max = 15;


  // Boolean fields


  `uvm_object_utils(multiple_read_config)
  function new(string name = "multiple_read_config");
    super.new(name);
  endfunction
endclass