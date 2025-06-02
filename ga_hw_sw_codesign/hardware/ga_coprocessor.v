module ga_coprocessor #(
    parameter POPULATION_SIZE = 100,
    parameter CHROMOSOME_LENGTH = 19,
    parameter NUM_FITNESS_UNITS = 4,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    
    // AXI4-Lite Slave Interface
    input wire [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output wire s_axi_awready,
    input wire [AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input wire [AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output wire s_axi_wready,
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    input wire s_axi_bready,
    input wire [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output wire s_axi_arready,
    output wire [AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    input wire s_axi_rready,
    
    // Interrupt output
    output wire irq
);

    // Register map definitions
    localparam CTRL_REG_ADDR     = 12'h000;
    localparam STATUS_REG_ADDR   = 12'h004;
    localparam CONFIG_REG_ADDR   = 12'h008;
    localparam TARGET_REG_ADDR   = 12'h00C;
    localparam RESULT_REG_ADDR   = 12'h010;
    localparam POP_MEM_BASE_ADDR = 12'h100;

    // Control and status registers
    reg [31:0] ctrl_reg;
    reg [31:0] status_reg;
    reg [31:0] config_reg;
    reg [31:0] target_reg;
    reg [31:0] result_reg;
    
    // Control signals
    wire start_processing = ctrl_reg[0];
    wire reset_processing = ctrl_reg[1];
    wire processing_done;
    wire processing_busy;
    
    // Configuration parameters
    wire [7:0] mutation_rate = config_reg[7:0];
    wire [7:0] crossover_rate = config_reg[15:8];
    wire [7:0] elite_percentage = config_reg[23:16];
    
    // Population memory interface
    wire [7:0] pop_mem_addr;
    wire [7:0] pop_mem_wdata;
    wire pop_mem_we;
    wire [7:0] pop_mem_rdata;
    
    // AXI4-Lite slave interface
    axi4_lite_slave #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) axi_slave_inst (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .reg_write_en(reg_write_en),
        .reg_write_addr(reg_write_addr),
        .reg_write_data(reg_write_data),
        .reg_read_en(reg_read_en),
        .reg_read_addr(reg_read_addr),
        .reg_read_data(reg_read_data)
    );
    
    // Register interface signals
    wire reg_write_en;
    wire [AXI_ADDR_WIDTH-1:0] reg_write_addr;
    wire [AXI_DATA_WIDTH-1:0] reg_write_data;
    wire reg_read_en;
    wire [AXI_ADDR_WIDTH-1:0] reg_read_addr;
    wire [AXI_DATA_WIDTH-1:0] reg_read_data;
    
    // Register write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ctrl_reg <= 32'h0;
            config_reg <= 32'h0;
            target_reg <= 32'h0;
        end else if (reg_write_en) begin
            case (reg_write_addr)
                CTRL_REG_ADDR: ctrl_reg <= reg_write_data;
                CONFIG_REG_ADDR: config_reg <= reg_write_data;
                TARGET_REG_ADDR: target_reg <= reg_write_data;
            endcase
        end
    end
    
    // Status register update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            status_reg <= 32'h0;
        end else begin
            status_reg[0] <= processing_busy;
            status_reg[1] <= processing_done;
        end
    end
    
    // Register read logic
    assign reg_read_data = (reg_read_addr == CTRL_REG_ADDR)   ? ctrl_reg :
                          (reg_read_addr == STATUS_REG_ADDR) ? status_reg :
                          (reg_read_addr == CONFIG_REG_ADDR) ? config_reg :
                          (reg_read_addr == TARGET_REG_ADDR) ? target_reg :
                          (reg_read_addr == RESULT_REG_ADDR) ? result_reg :
                          32'h0;
    
    // Population memory (dual-port RAM)
    population_memory #(
        .POPULATION_SIZE(POPULATION_SIZE),
        .CHROMOSOME_LENGTH(CHROMOSOME_LENGTH)
    ) pop_mem_inst (
        .clk(clk),
        .rst_n(rst_n),
        .addr_a(pop_mem_addr),
        .data_a(pop_mem_wdata),
        .we_a(pop_mem_we),
        .q_a(pop_mem_rdata),
        .addr_b(ga_core_pop_addr),
        .data_b(ga_core_pop_wdata),
        .we_b(ga_core_pop_we),
        .q_b(ga_core_pop_rdata)
    );
    
    // GA core processing unit
    wire [7:0] ga_core_pop_addr;
    wire [7:0] ga_core_pop_wdata;
    wire ga_core_pop_we;
    wire [7:0] ga_core_pop_rdata;
    
    ga_processing_core #(
        .POPULATION_SIZE(POPULATION_SIZE),
        .CHROMOSOME_LENGTH(CHROMOSOME_LENGTH),
        .NUM_FITNESS_UNITS(NUM_FITNESS_UNITS)
    ) ga_core_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_processing),
        .reset_proc(reset_processing),
        .mutation_rate(mutation_rate),
        .crossover_rate(crossover_rate),
        .elite_percentage(elite_percentage),
        .target_string(target_reg[CHROMOSOME_LENGTH*8-1:0]),
        .pop_mem_addr(ga_core_pop_addr),
        .pop_mem_wdata(ga_core_pop_wdata),
        .pop_mem_we(ga_core_pop_we),
        .pop_mem_rdata(ga_core_pop_rdata),
        .best_fitness(best_fitness),
        .processing_done(processing_done),
        .processing_busy(processing_busy)
    );
    
    wire [15:0] best_fitness;
    
    // Update result register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_reg <= 32'h0;
        end else if (processing_done) begin
            result_reg[15:0] <= best_fitness;
        end
    end
    
    // Interrupt generation
    assign irq = processing_done;

endmodule