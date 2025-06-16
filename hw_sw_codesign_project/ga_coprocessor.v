module ga_coprocessor (
    input clk,
    input rst_n,
    
    // Control signals
    input start,
    input [1:0] operation,  // 2'b00: fitness, 2'b01: crossover, 2'b10: mutation
    
    // Fitness operation inputs
    input [151:0] chromosome_in,
    input [151:0] target_string,
    
    // Crossover operation inputs  
    input [151:0] parent1,
    input [151:0] parent2,
    input [31:0] crossover_seed,
    
    // Mutation operation inputs
    input [151:0] chromosome_to_mutate,
    input [31:0] mutation_seed,
    input [7:0] mutation_rate,
    
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
reg [151:0] stored_chromosome, stored_target;
reg [151:0] stored_parent1, stored_parent2;
reg [151:0] stored_mutate_chromosome;
reg [31:0] stored_crossover_seed, stored_mutation_seed;
reg [7:0] stored_mutation_rate;

// Processing counters
reg [7:0] char_counter, cross_counter, mut_counter;
reg [15:0] mismatch_count;
reg [151:0] offspring_temp, mutated_temp;

// LFSR for random number generation
reg [31:0] lfsr_reg;

// LFSR with proper seeding
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lfsr_reg <= 32'hACEDBEEF;
    end else if (start && operation_valid) begin
        // Seed LFSR with external input for each operation
        case (operation)
            OP_CROSSOVER: lfsr_reg <= crossover_seed;
            OP_MUTATION: lfsr_reg <= mutation_seed;
            default: lfsr_reg <= lfsr_reg;
        endcase
    end else if (processing_busy) begin
        // Advance LFSR every cycle
        lfsr_reg <= {lfsr_reg[30:0], lfsr_reg[31] ^ lfsr_reg[21] ^ lfsr_reg[1] ^ lfsr_reg[0]};
    end
end

// EXACT SOFTWARE GENES STRING IMPLEMENTATION
// GENES = '''abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890, .-;:_!"#%&/()=?@${[]}'''
function [7:0] mutated_genes;
    input [7:0] random_index;
    reg [7:0] gene_index;
    begin
        // Map random_index to exact GENES string
        gene_index = random_index % 95;  // 95 characters in GENES string
        
        case (gene_index)
            // a-z (26 characters: 0-25)
            0: mutated_genes = 8'h61;   // 'a'
            1: mutated_genes = 8'h62;   // 'b'
            2: mutated_genes = 8'h63;   // 'c'
            3: mutated_genes = 8'h64;   // 'd'
            4: mutated_genes = 8'h65;   // 'e'
            5: mutated_genes = 8'h66;   // 'f'
            6: mutated_genes = 8'h67;   // 'g'
            7: mutated_genes = 8'h68;   // 'h'
            8: mutated_genes = 8'h69;   // 'i'
            9: mutated_genes = 8'h6A;   // 'j'
            10: mutated_genes = 8'h6B;  // 'k'
            11: mutated_genes = 8'h6C;  // 'l'
            12: mutated_genes = 8'h6D;  // 'm'
            13: mutated_genes = 8'h6E;  // 'n'
            14: mutated_genes = 8'h6F;  // 'o'
            15: mutated_genes = 8'h70;  // 'p'
            16: mutated_genes = 8'h71;  // 'q'
            17: mutated_genes = 8'h72;  // 'r'
            18: mutated_genes = 8'h73;  // 's'
            19: mutated_genes = 8'h74;  // 't'
            20: mutated_genes = 8'h75;  // 'u'
            21: mutated_genes = 8'h76;  // 'v'
            22: mutated_genes = 8'h77;  // 'w'
            23: mutated_genes = 8'h78;  // 'x'
            24: mutated_genes = 8'h79;  // 'y'
            25: mutated_genes = 8'h7A;  // 'z'
            
            // A-Z (26 characters: 26-51)
            26: mutated_genes = 8'h41;  // 'A'
            27: mutated_genes = 8'h42;  // 'B'
            28: mutated_genes = 8'h43;  // 'C'
            29: mutated_genes = 8'h44;  // 'D'
            30: mutated_genes = 8'h45;  // 'E'
            31: mutated_genes = 8'h46;  // 'F'
            32: mutated_genes = 8'h47;  // 'G'
            33: mutated_genes = 8'h48;  // 'H'
            34: mutated_genes = 8'h49;  // 'I'
            35: mutated_genes = 8'h4A;  // 'J'
            36: mutated_genes = 8'h4B;  // 'K'
            37: mutated_genes = 8'h4C;  // 'L'
            38: mutated_genes = 8'h4D;  // 'M'
            39: mutated_genes = 8'h4E;  // 'N'
            40: mutated_genes = 8'h4F;  // 'O'
            41: mutated_genes = 8'h50;  // 'P'
            42: mutated_genes = 8'h51;  // 'Q'
            43: mutated_genes = 8'h52;  // 'R'
            44: mutated_genes = 8'h53;  // 'S'
            45: mutated_genes = 8'h54;  // 'T'
            46: mutated_genes = 8'h55;  // 'U'
            47: mutated_genes = 8'h56;  // 'V'
            48: mutated_genes = 8'h57;  // 'W'
            49: mutated_genes = 8'h58;  // 'X'
            50: mutated_genes = 8'h59;  // 'Y'
            51: mutated_genes = 8'h5A;  // 'Z'
            
            // Space (1 character: 52)
            52: mutated_genes = 8'h20;  // ' '
            
            // 0-9 (10 characters: 53-62)
            53: mutated_genes = 8'h31;  // '1'
            54: mutated_genes = 8'h32;  // '2'
            55: mutated_genes = 8'h33;  // '3'
            56: mutated_genes = 8'h34;  // '4'
            57: mutated_genes = 8'h35;  // '5'
            58: mutated_genes = 8'h36;  // '6'
            59: mutated_genes = 8'h37;  // '7'
            60: mutated_genes = 8'h38;  // '8'
            61: mutated_genes = 8'h39;  // '9'
            62: mutated_genes = 8'h30;  // '0'
            
            // Special characters (32 characters: 63-94)
            63: mutated_genes = 8'h2C;  // ','
            64: mutated_genes = 8'h20;  // ' '
            65: mutated_genes = 8'h2E;  // '.'
            66: mutated_genes = 8'h2D;  // '-'
            67: mutated_genes = 8'h3B;  // ';'
            68: mutated_genes = 8'h3A;  // ':'
            69: mutated_genes = 8'h5F;  // '_'
            70: mutated_genes = 8'h21;  // '!'
            71: mutated_genes = 8'h22;  // '"'
            72: mutated_genes = 8'h23;  // '#'
            73: mutated_genes = 8'h25;  // '%'
            74: mutated_genes = 8'h26;  // '&'
            75: mutated_genes = 8'h2F;  // '/'
            76: mutated_genes = 8'h28;  // '('
            77: mutated_genes = 8'h29;  // ')'
            78: mutated_genes = 8'h3D;  // '='
            79: mutated_genes = 8'h3F;  // '?'
            80: mutated_genes = 8'h40;  // '@'
            81: mutated_genes = 8'h24;  // '$'
            82: mutated_genes = 8'h7B;  // '{'
            83: mutated_genes = 8'h5B;  // '['
            84: mutated_genes = 8'h5D;  // ']'
            85: mutated_genes = 8'h7D;  // '}'
            
            // Fill remaining with common characters
            default: mutated_genes = 8'h20;  // Default to space
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
                    if (stored_chromosome[char_counter*8 +: 8] != stored_target[char_counter*8 +: 8]) begin
                        mismatch_count <= mismatch_count + 1;
                    end
                    char_counter <= char_counter + 1;
                end else begin
                    fitness_out <= mismatch_count;
                    result_valid <= 1;
                    processing_done <= 1;
                    processing_busy <= 0;
                    state <= DONE;
                end
            end
            
            // EXACT SOFTWARE CROSSOVER LOGIC
            // if prob < 0.45: parent1, elif prob < 0.90: parent2, else: random
            CROSSOVER_EXEC: begin
                if (cross_counter < 19) begin
                    // Convert 32-bit LFSR to probability like random.random() (0.0-1.0)
                    // Use upper 16 bits for better distribution: 0-65535 maps to 0.0-1.0
                    
                    // Software: if prob < 0.45 (45%)
                    if (lfsr_reg[31:16] < 16'd29491) begin  // 0.45 * 65535 = 29491
                        offspring_temp[cross_counter*8 +: 8] <= stored_parent1[cross_counter*8 +: 8];
                    end
                    // Software: elif prob < 0.90 (45% more, total 90%)  
                    else if (lfsr_reg[31:16] < 16'd58982) begin  // 0.90 * 65535 = 58982
                        offspring_temp[cross_counter*8 +: 8] <= stored_parent2[cross_counter*8 +: 8];
                    end
                    // Software: else (10% random mutation)
                    else begin
                        offspring_temp[cross_counter*8 +: 8] <= mutated_genes(lfsr_reg[7:0]);
                    end
                    
                    cross_counter <= cross_counter + 1;
                    // Advance LFSR for next character
                    lfsr_reg <= {lfsr_reg[30:0], lfsr_reg[31] ^ lfsr_reg[21] ^ lfsr_reg[1] ^ lfsr_reg[0]};
                end else begin
                    offspring_out <= offspring_temp;
                    result_valid <= 1;
                    processing_done <= 1;
                    processing_busy <= 0;
                    state <= DONE;
                end
            end
            
            // EXACT SOFTWARE MUTATION LOGIC
            // if random.random() < mutation_rate: mutate
            MUTATION_EXEC: begin
                if (mut_counter < 19) begin
                    // Convert LFSR to probability like random.random() (0.0-1.0)
                    // Software: if random.random() < mutation_rate
                    if (lfsr_reg[31:16] < (stored_mutation_rate * 16'd257)) begin  // Scale to 16-bit
                        mutated_temp[mut_counter*8 +: 8] <= mutated_genes(lfsr_reg[7:0]);
                    end
                    // Else keep original (already in mutated_temp)
                    
                    mut_counter <= mut_counter + 1;
                    // Advance LFSR for next character
                    lfsr_reg <= {lfsr_reg[30:0], lfsr_reg[31] ^ lfsr_reg[21] ^ lfsr_reg[1] ^ lfsr_reg[0]};
                end else begin
                    mutated_out <= mutated_temp;
                    result_valid <= 1;
                    processing_done <= 1;
                    processing_busy <= 0;
                    state <= DONE;
                end
            end
            
            DONE: begin
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

