module spi_slave (
    input  wire sclk,
    input  wire mosi,  
    output reg  miso,
    input  wire cs_n
);

    reg [7:0] rx_data;
    reg [7:0] tx_data;
    reg [2:0] bit_count;
    
    // Memory with test data
    reg [7:0] memory = 8'hAA;
    
    always @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            bit_count <= 0;
            miso <= 0;
            tx_data <= memory;  // Load data to send
        end
        else begin
            // Shift in received bit
            rx_data <= {rx_data[6:0], mosi};
            
            // Shift out transmit bit
            miso <= tx_data[7];
            tx_data <= {tx_data[6:0], 1'b0};
            
            bit_count <= bit_count + 1;
        end
    end

endmodule
