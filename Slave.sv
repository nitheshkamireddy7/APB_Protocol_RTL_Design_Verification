module APB_slave(
  // Inputs from APB_Master to APB_slave
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

// Memory declaration of APB_slave
logic [31:0] memory[31:0];

enum logic [2:0] {
    idle,
    setup,
    access
} APB_states;

APB_states present, next;

// State transition
always_ff @(posedge clk or negedge resetn) begin
  if (!resetn) begin
    present <= idle;
  end else begin
    present <= next;
  end
end

// State machine logic
always_comb begin
  // Default values to avoid latches
  pready = 0;
  pslverr = 0;
  prdata = 32'b0;
  next = present; // Default to current state

  case (present) 
    idle: begin
      if (psel) begin
        next = setup;
      end
    end

    setup: begin
      if (psel && penable) begin
        next = access;
      end
    end

    // APB_Slave supports only secured data access
    access: begin
      pready = 1;
      if (Prot[1] == 0) begin  // Secured access
        if (pwrite) begin 
          memory[addr] = update_memory(pwdata, pstrobe, memory[addr]);
          pslverr = 0;
        end else begin
          prdata = memory[addr];
        end
      end else begin
        // Unsecured access, no transaction allowed
        next = idle;
      end
    end
  endcase
end

// Function to update memory based on byte enable (strobe)
function logic [31:0] update_memory(
  input logic [31:0] pwdata, 
  input logic [3:0]  pstrobe, 
  input logic [31:0] memory_data
);
  begin
    if (pstrobe[0]) memory_data[7:0]   = pwdata[7:0];   
    if (pstrobe[1]) memory_data[15:8]  = pwdata[15:8];  
    if (pstrobe[2]) memory_data[23:16] = pwdata[23:16]; 
    if (pstrobe[3]) memory_data[31:24] = pwdata[31:24]; 
    update_memory = memory_data;
  end
endfunction

endmodule
