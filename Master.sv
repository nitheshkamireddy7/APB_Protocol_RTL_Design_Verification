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

  APB_slave bus(clk,resetn,pwrite,addr,psel,penable,pstrobe,prot,pwdata,pready,pslverr,prdata);

  //clock initialization
  clk =1;
  always #10 clk = ~clk;

  task reset;
    begin 
    resetn =0;
      (@posedge clk);
    resetn=1;
    psel=1'b0;
    end

    task write;
      begin
        
        
      end
endmodule
