
`include "uvm_macros.svh"
import uvm_pkg::*;

class adder_transaction extends uvm_sequence_item;

  // Port-backed fields





  rand logic [7:0] a;





  rand logic [7:0] b;





  logic [7:0] sum;





  logic carry;




  // Extra non-port constrained fields


  // Boolean knobs


  `uvm_object_utils(adder_transaction)

  function new(string name = "adder_transaction");
    super.new(name);
  endfunction
endclass