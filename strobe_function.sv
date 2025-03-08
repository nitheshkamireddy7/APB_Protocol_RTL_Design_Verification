function logic [31:0] update_memory(
    input logic [31:0] pwdata, 
    input logic [3:0]  strobe, 
    input logic [31:0] memory_data
);
    begin
        if (strobe[0]) memory_data[7:0]   = pwdata[7:0];   
        if (strobe[1]) memory_data[15:8]  = pwdata[15:8];  
        if (strobe[2]) memory_data[23:16] = pwdata[23:16]; 
        if (strobe[3]) memory_data[31:24] = pwdata[31:24]; 
        update_memory = memory_data;
    end
endfunction
