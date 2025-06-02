module population_memory #(
    parameter POPULATION_SIZE = 100,
    parameter CHROMOSOME_LENGTH = 19
)(
    input wire clk,
    input wire rst_n,
    
    // Port A (AXI interface)
    input wire [7:0] addr_a,
    input wire [7:0] data_a,
    input wire we_a,
    output reg [7:0] q_a,
    
    // Port B (GA core)
    input wire [7:0] addr_b,
    input wire [7:0] data_b,
    input wire we_b,
    output reg [7:0] q_b
);

    reg [7:0] memory [0:POPULATION_SIZE*CHROMOSOME_LENGTH-1];
    
    // Port A
    always @(posedge clk) begin
        if (we_a) begin
            memory[addr_a] <= data_a;
        end
        q_a <= memory[addr_a];
    end
    
    // Port B
    always @(posedge clk) begin
        if (we_b) begin
            memory[addr_b] <= data_b;
        end
        q_b <= memory[addr_b];
    end

endmodule