
`include "uvm_macros.svh"
import uvm_pkg::*;

class single_write_config extends uvm_object;
  rand int data_width = 8;

  // Ranged fields

  rand int device_address_min = 16;
  rand int device_address_max = 16;

  rand int divider_min = 100;
  rand int divider_max = 100;

  rand int mosi_data_min = 0;
  rand int mosi_data_max = 255;

  rand int register_address_min = 0;
  rand int register_address_max = 0;


  // Boolean fields


  `uvm_object_utils(single_write_config)
  function new(string name = "single_write_config");
    super.new(name);
  endfunction
endclass