module APB_master (
  input logic clk,
  input logic resetn, // Asynchronous active low reset
  input logic pwrite,
  input logic [4:0] addr,
  input logic psel,
  input logic penable,
  input logic [3:0] pstrobe,
  input logic [2:0] Prot,
  input logic [31:0] pwdata,

  // Outputs from APB_slave
  output logic pready,
  output logic pslverr,
  output logic [31:0] prdata
  
);

  APB_slave bus(
endmodule
