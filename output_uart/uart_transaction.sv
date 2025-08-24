
`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_transaction extends uvm_sequence_item;

  // Port-backed fields







  rand logic [7:0] tx_data;





  rand logic tx_start;





  logic tx;





  logic tx_done;




  // Extra non-port constrained fields

  rand int baud_rate;


  // Boolean knobs

  rand bit enable_parity;


  `uvm_object_utils(uart_transaction)

  function new(string name = "uart_transaction");
    super.new(name);
  endfunction
endclass