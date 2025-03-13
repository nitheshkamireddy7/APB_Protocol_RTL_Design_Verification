module APB_slave (
    input logic clk,
    input logic resetn,
    input logic pwrite,
    input logic [4:0] addr,
    input logic psel,
    input logic penable,
    input logic [31:0] pwdata,
    input logic [2:0] prot,  // 3-bit protection input, but we only use prot[1]

    output logic pready,
    output logic pslverr,
    output logic [31:0] prdata
);

    // Memory declaration of APB_slave
    logic [31:0] memory[31:0];

    typedef enum logic [1:0] {
        idle,
        setup,
        access
    } APB_states;

    APB_states present, next;
    int cycle_counter;

    // State transition and pready control
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            present <= idle;
            cycle_counter <= 0;
            pready <= 0;
            // Clear error state during reset
        end else begin
            present <= next;

            if (present == access) begin
                if (cycle_counter < 2) begin
                    pready <= 1;  // Keep pready high for 2 cycles
                    cycle_counter <= cycle_counter + 1;
                end else begin
                    cycle_counter <= 0;
                    pready <= 0;  // Lower pready after 2 cycles
                end
            end else begin
                cycle_counter <= 0;
                pready <= 0;
            end
        end
    end

    // State machine logic
    always_comb begin
        next = present; // Default transition

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

            access: begin
                if (cycle_counter >= 2) begin
                    next = idle;
                end
            end
        endcase
    end

    
    always_comb begin
        prdata = 'x; // Default value for prdata

        if (psel && penable && pready) begin
            // If prot[1] == 0, proceed with normal access
            if (prot[1] == 0) begin
                if (pwrite) begin
                    // Write normally when prot[1] == 0
                    memory[addr] = pwdata;
                    pslverr = 0;  // No error
                end else begin
                    // Read normally when prot[1] == 0
                    prdata = memory[addr];
                    pslverr =0;
                end
            end else begin
                // If prot[1] == 1, this is an unsecured access
                pslverr = 1;  // Set error state for unsecured access
                prdata = 'x;  // Return unknown value for prdata
            end
        end
    end

endmodule
