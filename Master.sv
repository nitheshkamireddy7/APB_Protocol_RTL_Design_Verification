module APB_master_tb;
    logic clk;
    logic resetn;
    logic pwrite;
    logic [4:0] addr;
    logic psel;
    logic penable;
    //logic [2:0] Prot;
    logic [31:0] pwdata;
    logic pready;
    logic pslverr;
    logic [31:0] prdata;

    // Instantiate APB Master
    APB_slave uut (
        .clk(clk),
        .resetn(resetn),
        .pwrite(pwrite),
        .addr(addr),
        .psel(psel),
        .penable(penable),
        .pwdata(pwdata),
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
        end
    endtask

    task read_transfer;
        begin
            psel = 1;
            pwrite = 0;
            @(posedge clk);
            penable = 1;

            wait (pready == 1);

            @(posedge clk);
            penable = 0;
            psel = 0;

            $strobe("reading data from memory data_rd=%0d address_rd=%0d", prdata, addr);
        end
    endtask

    task write_transfer;
        begin
            psel = 1;
            pwrite = 1;
            pwdata = $random;
            addr = $random;

            @(posedge clk);
            penable = 1;

            wait (pready == 1);

            @(posedge clk);
            penable = 0;

            $strobe("writing data into memory data_wr=%0d address_rd=%0d", pwdata, addr);
        end
    endtask

    task read_write_transfer;
        begin
            repeat (1) begin
                write_transfer;
                read_transfer;
            end
        end
    endtask

    initial begin
        clk = 0;
        reset_and_initialization;
        read_write_transfer;
        #80;
        $finish;
    end

    
endmodule
