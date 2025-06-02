// lfsr_32bit.v - 32-bit Linear Feedback Shift Register
module lfsr_32bit (
    input wire clk,
    input wire rst_n,
    input wire enable,
    output wire [31:0] random_out
);

    reg [31:0] lfsr_reg;
    wire feedback;
    
    assign feedback = lfsr_reg[31] ^ lfsr_reg[21] ^ lfsr_reg[1] ^ lfsr_reg[0];
    assign random_out = lfsr_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_reg <= 32'hACEDBEEF; // Non-zero seed
        end else if (enable) begin
            lfsr_reg <= {lfsr_reg[30:0], feedback};
        end
    end

endmodule
