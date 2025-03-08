module APB_slave(
  //inputs from APB_Master to APB_slave
  input logic clk,
  input logic resetn, //asynchronous active low reset
  input logic pwrite,
  input logic [4:0]addr
  input logic psel,
  input logic penable,
  input logic [3:0]pstrobe,
  input logic Prot,
  input logic [31:0]pwdata,

  //outputs from APB_slave
  output logic pready,
  output logic pslverr,
  output logic [31:0]prdata
  
);

//memory declaration of APB_slave
logic [31:0] memory[31:0];

  enum logic [2:0] {
    idle,
    setup,
    access} APB_states;

  APB_states present,next;

  always_ff @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      next <= idle;
    end
    else begin
      present <= next;
    end
  end

  always_comb @(*) begin
    case(present) 
      idle : begin
        if(psel == 1) begin
        next =  setup;
      end
      else begin
        next = idle;
      end
      end
      setup : begin
        if (psel == 1 && penable == 1) begin
        next = access;
      end
      end

      access : begin
        pready = 1;
        if(pwrite) begin 
        
          memory[addr] = update_memory(pwdata, strobe, memory[addr]);
        end
      end
      
      
    endcase
  end

  

endmodule
