module APB_slave (
    // Inputs from APB_Master to APB_slave
    input logic clk,
    input logic resetn, // Asynchronous active low reset
    input logic pwrite,
    input logic [4:0] addr,
    input logic psel,
    input logic penable,
    input logic [31:0] pwdata,

    // Outputs from APB_slave
    output logic pready,
    output logic pslverr,
    output logic [31:0] prdata
);

    // Memory declaration of APB_slave
    logic [31:0] memory[31:0];

    typedef enum logic [2:0] {
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
                // Secured access
                if (pwrite) begin
                    memory[addr] = pwdata;
                    pslverr = 0;
                end else if (!pwrite) begin
                    prdata = memory[addr];
                end
            end
        endcase
    end

endmodule
