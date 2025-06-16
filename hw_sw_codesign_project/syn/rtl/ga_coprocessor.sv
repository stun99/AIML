module ga_coprocessor (
    input clk,
    input rst_n,
    
    // Control signals
    input start,
    input [1:0] operation,  // 00: fitness, 01: crossover, 10: mutation
    
    // Fitness operation inputs
    input [151:0] chromosome_in,
    input [151:0] target_string,
    
    // Crossover operation inputs  
    input [151:0] parent1,
    input [151:0] parent2,
    input [31:0] crossover_seed,  // Random seed for crossover
    
    // Mutation operation inputs
    input [151:0] chromosome_to_mutate,
    input [31:0] mutation_seed,
    input [7:0] mutation_rate,  // 0-255 (255 = 100% mutation rate)
    
    input operation_valid,
    
    // Outputs
    output reg [15:0] fitness_out,
    output reg [151:0] offspring_out,
    output reg [151:0] mutated_out,
    output reg result_valid,
    output reg processing_done,
    output reg processing_busy
);

// Operation codes
localparam OP_FITNESS = 2'b00;
localparam OP_CROSSOVER = 2'b01;
localparam OP_MUTATION = 2'b10;

// States
localparam IDLE = 3'b000;
localparam FITNESS_CALC = 3'b001;
localparam CROSSOVER_EXEC = 3'b010;
localparam MUTATION_EXEC = 3'b011;
localparam DONE = 3'b100;

reg [2:0] state;
reg [1:0] current_operation;

// Storage registers
reg [151:0] stored_chromosome;
reg [151:0] stored_target;
reg [151:0] stored_parent1;
reg [151:0] stored_parent2;
reg [151:0] stored_mutate_chromosome;
reg [31:0] stored_crossover_seed;
reg [31:0] stored_mutation_seed;
reg [7:0] stored_mutation_rate;

// Fitness calculation registers
reg [7:0] char_counter;
reg [15:0] mismatch_count;

// Crossover registers
reg [7:0] cross_counter;
reg [151:0] offspring_temp;

// Mutation registers  
reg [7:0] mut_counter;
reg [151:0] mutated_temp;

// LFSR for random number generation
reg [31:0] lfsr_reg;
wire [31:0] random_value;

// LFSR implementation
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lfsr_reg <= 32'hACEDBEEF;  // Non-zero seed
    end else if (processing_busy) begin
        lfsr_reg <= {lfsr_reg[30:0], lfsr_reg[31] ^ lfsr_reg[21] ^ lfsr_reg[1] ^ lfsr_reg[0]};
    end
end

assign random_value = lfsr_reg;

// Generate random printable character (A-Z, a-z, 0-9, space)
function [7:0] random_char;
    input [7:0] seed;
    begin
        case (seed % 63)
            0,1,2,3,4,5,6,7,8,9: random_char = 8'h30 + (seed % 10); // 0-9
            10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35: 
                random_char = 8'h41 + (seed % 26); // A-Z
            36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61: 
                random_char = 8'h61 + (seed % 26); // a-z
            default: random_char = 8'h20; // space
        endcase
    end
endfunction

// Main state machine
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        current_operation <= 2'b00;
        fitness_out <= 0;
        offspring_out <= 0;
        mutated_out <= 0;
        result_valid <= 0;
        processing_done <= 0;
        processing_busy <= 0;
        char_counter <= 0;
        cross_counter <= 0;
        mut_counter <= 0;
        mismatch_count <= 0;
        offspring_temp <= 0;
        mutated_temp <= 0;
        stored_chromosome <= 0;
        stored_target <= 0;
        stored_parent1 <= 0;
        stored_parent2 <= 0;
        stored_mutate_chromosome <= 0;
        stored_crossover_seed <= 0;
        stored_mutation_seed <= 0;
        stored_mutation_rate <= 0;
    end else begin
        case (state)
            IDLE: begin
                result_valid <= 0;
                processing_done <= 0;
                
                if (start && operation_valid) begin
                    current_operation <= operation;
                    processing_busy <= 1;
                    
                    case (operation)
                        OP_FITNESS: begin
                            stored_chromosome <= chromosome_in;
                            stored_target <= target_string;
                            char_counter <= 0;
                            mismatch_count <= 0;
                            state <= FITNESS_CALC;
                        end
                        
                        OP_CROSSOVER: begin
                            stored_parent1 <= parent1;
                            stored_parent2 <= parent2;
                            stored_crossover_seed <= crossover_seed;
                            cross_counter <= 0;
                            offspring_temp <= 0;
                            state <= CROSSOVER_EXEC;
                        end
                        
                        OP_MUTATION: begin
                            stored_mutate_chromosome <= chromosome_to_mutate;
                            stored_mutation_seed <= mutation_seed;
                            stored_mutation_rate <= mutation_rate;
                            mut_counter <= 0;
                            mutated_temp <= chromosome_to_mutate;
                            state <= MUTATION_EXEC;
                        end
                        
                        default: state <= IDLE;
                    endcase
                end else begin
                    processing_busy <= 0;
                end
            end
            
            FITNESS_CALC: begin
                if (char_counter < 19) begin
                    // Compare current character
                    if (stored_chromosome[char_counter*8 +: 8] != stored_target[char_counter*8 +: 8]) begin
                        mismatch_count <= mismatch_count + 1;
                    end
                    char_counter <= char_counter + 1;
                end else begin
                    // Finished fitness calculation
                    fitness_out <= mismatch_count;
                    result_valid <= 1;
                    processing_done <= 1;
                    processing_busy <= 0;
                    state <= DONE;
                end
            end
            
            CROSSOVER_EXEC: begin
                if (cross_counter < 19) begin
                    // Crossover logic: use random value to choose parent
                    if (random_value[cross_counter % 32] == 1'b0) begin
                        // Choose from parent1
                        offspring_temp[cross_counter*8 +: 8] <= stored_parent1[cross_counter*8 +: 8];
                    end else begin
                        // Choose from parent2
                        offspring_temp[cross_counter*8 +: 8] <= stored_parent2[cross_counter*8 +: 8];
                    end
                    cross_counter <= cross_counter + 1;
                end else begin
                    // Finished crossover
                    offspring_out <= offspring_temp;
                    result_valid <= 1;
                    processing_done <= 1;
                    processing_busy <= 0;
                    state <= DONE;
                end
            end
            
            MUTATION_EXEC: begin
                if (mut_counter < 19) begin
                    // Mutation logic: check if this character should mutate
                    if ((random_value[7:0] + mut_counter) < stored_mutation_rate) begin
                        // Mutate this character
                        mutated_temp[mut_counter*8 +: 8] <= random_char(random_value[15:8] + mut_counter);
                    end
                    // If no mutation, keep original character (already in mutated_temp)
                    mut_counter <= mut_counter + 1;
                end else begin
                    // Finished mutation
                    mutated_out <= mutated_temp;
                    result_valid <= 1;
                    processing_done <= 1;
                    processing_busy <= 0;
                    state <= DONE;
                end
            end
            
            DONE: begin
                // Stay in done state until start is released
                if (!start) begin
                    state <= IDLE;
                    processing_done <= 0;
                    result_valid <= 0;
                end
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule
