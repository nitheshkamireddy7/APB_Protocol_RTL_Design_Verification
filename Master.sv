module APB_master_tb;
    logic clk;
    logic resetn;
    logic pwrite;
    logic [4:0] addr;
    logic psel;
    logic penable;
    logic [31:0] pwdata;
    logic [2:0] prot;  // Added protection bits
    logic pready;
    logic pslverr;
    logic [31:0] prdata;

    // Instantiate APB Slave
    APB_slave uut (
        .clk(clk),
        .resetn(resetn),
        .pwrite(pwrite),
        .addr(addr),
        .psel(psel),
        .penable(penable),
        .pwdata(pwdata),
        .prot(prot),  // Connect prot to the slave
        .pready(pready),
        .pslverr(pslverr),
        .prdata(prdata)
    );

    // Clock Generation
    always #10 clk = ~clk;

    // Test tasks
    task reset_and_initialization;
        begin
            resetn = 0;
            #5;
            @(posedge clk);
            resetn = 1;
            psel = 0;
            penable = 0;
            pwrite = 0;
            addr = 0;
            prot = 3'b000;  // Initialize protection bits
        end
    endtask

    task read_transfer_unsecured;
        begin
            psel = 1;
            pwrite = 0;
            addr = 5'b00001;
            prot = 3'b010;  // Set prot value for testing
            @(posedge clk);
            penable = 1;
            @(posedge clk);

            wait (pready == 1);
            @(posedge clk);
            @(posedge clk);
            penable = 0;
            psel = 0;

            $strobe("Reading data: data_rd=%0d, address_rd=%0d", prdata, addr);
        end
    endtask
    
   task read_transfer_secured;
        begin
            psel = 1;
            pwrite = 0;
            addr = 5'b00001;
            prot = 3'b000;  // Set prot value for testing
            @(posedge clk);
            penable = 1;
            @(posedge clk);

            wait (pready == 1);
            @(posedge clk);
            @(posedge clk);
            penable = 0;
            psel = 0;

            $strobe("Reading data: data_rd=%0d, address_rd=%0d", prdata, addr);
        end
    endtask

    task write_transfer;
        begin
            psel = 1;
            pwrite = 1;
            pwdata = $random;
            addr = 5'b00001;
            prot = 3'b000;  // Set prot value for testing
            @(posedge clk);
            penable = 1;
            @(posedge clk);

            wait (pready == 1);
            @(posedge clk);
            @(posedge clk);
            penable = 0;

            $strobe("Writing data: data_wr=%0d, address_wr=%0d", pwdata, addr);
        end
    endtask

    task read_write_transfer;
        begin
            repeat (1) begin
                write_transfer;
                read_transfer_secured;
            end
        end
    endtask
     
    task read_write_transfer_unsecured;
        begin
            repeat (1) begin
                write_transfer;
                read_transfer_unsecured;
            end
        end
    endtask



    initial begin
        clk = 0;
        reset_and_initialization;
        read_write_transfer;
        read_write_transfer_unsecured;
        #80;
        $finish;
    end
endmodule
