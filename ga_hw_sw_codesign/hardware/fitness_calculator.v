module fitness_calculator #(
    parameter CHROMOSOME_LENGTH = 19
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [CHROMOSOME_LENGTH*8-1:0] chromosome,
    input wire [CHROMOSOME_LENGTH*8-1:0] target,
    output reg [15:0] fitness,
    output reg valid
);

    reg [7:0] char_counter;
    reg [15:0] mismatch_count;
    reg calculating;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fitness <= 16'h0;
            valid <= 1'b0;
            char_counter <= 8'h0;
            mismatch_count <= 16'h0;
            calculating <= 1'b0;
        end else if (start && !calculating) begin
            calculating <= 1'b1;
            char_counter <= 8'h0;
            mismatch_count <= 16'h0;
            valid <= 1'b0;
        end else if (calculating) begin
            if (char_counter < CHROMOSOME_LENGTH) begin
                // Compare character at current position
                if (chromosome[char_counter*8 +: 8] != target[char_counter*8 +: 8]) begin
                    mismatch_count <= mismatch_count + 1;
                end
                char_counter <= char_counter + 1;
            end else begin
                // Calculation complete
                fitness <= mismatch_count;
                valid <= 1'b1;
                calculating <= 1'b0;
            end
        end else begin
            valid <= 1'b0;
        end
    end

endmodule

// 32-bit LFSR for random number generation
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
