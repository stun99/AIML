module spi_slave (
    input  wire clk,
    input  wire mosi,
    output reg  miso,
    input  wire cs_n
);
    reg [7:0] data_reg;
    reg [2:0] bit_cnt;
    reg [7:0] memory = 8'hAA;
    
    always @(posedge clk) begin
        if (cs_n) begin
            bit_cnt <= 0;
            miso <= 0;
        end else begin
            data_reg <= {data_reg[6:0], mosi};
            miso <= memory[7 - bit_cnt];
            bit_cnt <= bit_cnt + 1;
        end
    end
endmodule