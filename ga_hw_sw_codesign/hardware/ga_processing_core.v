module ga_processing_core #(
    parameter POPULATION_SIZE = 100,
    parameter CHROMOSOME_LENGTH = 19,
    parameter NUM_FITNESS_UNITS = 4
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire reset_proc,
    input wire [7:0] mutation_rate,
    input wire [7:0] crossover_rate,
    input wire [7:0] elite_percentage,
    input wire [CHROMOSOME_LENGTH*8-1:0] target_string,
    
    // Population memory interface
    output reg [7:0] pop_mem_addr,
    output reg [7:0] pop_mem_wdata,
    output reg pop_mem_we,
    input wire [7:0] pop_mem_rdata,
    
    output reg [15:0] best_fitness,
    output reg processing_done,
    output reg processing_busy
);

    // State machine states
    localparam IDLE = 3'b000;
    localparam FITNESS_CALC = 3'b001;
    localparam SELECTION = 3'b010;
    localparam CROSSOVER = 3'b011;
    localparam MUTATION = 3'b100;
    localparam DONE = 3'b101;
    
    reg [2:0] state;
    reg [7:0] individual_counter;
    reg [7:0] gene_counter;
    
    // Fitness calculation units
    wire [15:0] fitness_results [NUM_FITNESS_UNITS-1:0];
    wire fitness_valid [NUM_FITNESS_UNITS-1:0];
    
    genvar i;
    generate
        for (i = 0; i < NUM_FITNESS_UNITS; i = i + 1) begin : fitness_units
            fitness_calculator #(
                .CHROMOSOME_LENGTH(CHROMOSOME_LENGTH)
            ) fitness_calc_inst (
                .clk(clk),
                .rst_n(rst_n),
                .start(fitness_start[i]),
                .chromosome(fitness_chromosome[i]),
                .target(target_string),
                .fitness(fitness_results[i]),
                .valid(fitness_valid[i])
            );
        end
    endgenerate
    
    reg fitness_start [NUM_FITNESS_UNITS-1:0];
    reg [CHROMOSOME_LENGTH*8-1:0] fitness_chromosome [NUM_FITNESS_UNITS-1:0];
    
    // LFSR for random number generation
    wire [31:0] random_value;
    lfsr_32bit lfsr_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .random_out(random_value)
    );
    
    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            processing_done <= 1'b0;
            processing_busy <= 1'b0;
            individual_counter <= 8'h0;
            gene_counter <= 8'h0;
            best_fitness <= 16'hFFFF;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= FITNESS_CALC;
                        processing_busy <= 1'b1;
                        processing_done <= 1'b0;
                        individual_counter <= 8'h0;
                        best_fitness <= 16'hFFFF;
                    end
                end
                
                FITNESS_CALC: begin
                    // Parallel fitness calculation logic
                    if (individual_counter < POPULATION_SIZE) begin
                        // Load chromosomes into fitness units
                        // Process NUM_FITNESS_UNITS individuals in parallel
                        individual_counter <= individual_counter + NUM_FITNESS_UNITS;
                    end else begin
                        state <= SELECTION;
                        individual_counter <= 8'h0;
                    end
                end
                
                SELECTION: begin
                    // Selection and sorting logic
                    state <= CROSSOVER;
                end
                
                CROSSOVER: begin
                    // Crossover operation
                    if (individual_counter < POPULATION_SIZE) begin
                        // Perform crossover for pairs of individuals
                        individual_counter <= individual_counter + 2;
                    end else begin
                        state <= MUTATION;
                        individual_counter <= 8'h0;
                    end
                end
                
                MUTATION: begin
                    // Mutation operation
                    if (individual_counter < POPULATION_SIZE) begin
                        // Apply mutation to each individual
                        individual_counter <= individual_counter + 1;
                    end else begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    processing_done <= 1'b1;
                    processing_busy <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule