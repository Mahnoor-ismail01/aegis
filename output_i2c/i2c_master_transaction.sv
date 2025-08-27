
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_master_transaction extends uvm_sequence_item;

  // Port-backed fields







  rand bit enable;





  rand bit read_write;





  rand bit [7:0] mosi_data;





  rand bit [7:0] register_address;





  rand bit [6:0] device_address;





  rand bit [15:0] divider;





  bit [7:0] miso_data;





  bit busy;





  bit external_serial_data;





  bit external_serial_clock;




  // Extra non-port constrained fields


  // Boolean knobs


  `uvm_object_utils(i2c_master_transaction)

  function new(string name = "i2c_master_transaction");
    super.new(name);
  endfunction
endclass