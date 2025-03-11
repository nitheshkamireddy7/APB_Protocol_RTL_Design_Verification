module APB_master (
  input logic clk,
  input logic resetn, // Asynchronous active low reset
  input logic pwrite,
  input logic [4:0] addr,
  input logic psel,
  input logic penable,
  //input logic [3:0] pstrobe,
  input logic [2:0] Prot,
  input logic [31:0] pwdata,

  // Outputs from APB_slave
  output logic pready,
  output logic pslverr,
  output logic [31:0] prdata
  
);

  APB_slave bus(clk,resetn,pwrite,addr,psel,penable,prot,pwdata,pready,pslverr,prdata);

  //clock initialization
  initial begin
  clk =1;
  always #10 clk = ~clk;
  end

  task reset_and_initialization;
    begin
        #5 Prst=0;
        @(posedge clk);
        resetn=1;
        Psel=1'b0;
        Penable=1'bx;
        Pwrite=1'bx;
        Paddr='bx;
    end
endtask


    task read_transfer;
    begin
        Pselx=1;
        Pwrite=0;
        @(posedge Pclk);
        Penable=1;

        wait (Pready==1) begin
            Pselx=Pselx;
            Pwrite=Pwrite;
            Penable=Penable;
            Paddr=Paddr;
            Pwdata=Pwdata;
        end

        @(posedge Pclk);
        Penable=0;
        Pselx=0;

        $strobe("reading data from memory data_rd=%0d address_rd=%0d", Prdata, Paddr);
    end
endtask
  task write_transfer;
    begin
        Pselx=1;
        Pwrite=1;
        Pwdata=$random;
        Paddr=$random;

        @(posedge Pclk);
        Penable=1;

        wait (Pready==1)
        //begin
        //Pselx=Pselx; Pwrite=Pwrite;
        //Penable=Penable;
        //Paddr=Paddr;
        //Pwdata=Pwdata; //end

        @(posedge Pclk);
        Penable=0;

        $strobe("writing data into memory data_wr=%0d address_rd=%0d", Pwdata, Paddr);
    end
endtask
task read_write_transfer;
begin
  //@(posedge Pclk);
  repeat (1)
  begin
    write_transfer;
    read_transfer;
  end
end
endtask

////////////////////////Initiate Simulation////////////////////////

initial begin
  reset_and_initialization;
  read_write_transfer;
  #80; $finish;
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
end

endmodule

        
        
