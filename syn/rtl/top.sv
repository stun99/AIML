`include "spi_interface.sv"
`include "neural_network.sv"
module top #(
    parameter LAYER_SIZE    = 4,
    parameter WEIGHT_WIDTH  = 8,
    parameter SYNAPSE_DEPTH = 4
)(
    input  wire               clk,
    input  wire               rst_n,
    // SPI Interface
    input  wire               spi_clk,
    input  wire               spi_mosi,
    output wire               spi_miso,
    input  wire               spi_cs_n,
    // I/O Ports
    input  wire [LAYER_SIZE-1:0]  sensor_inputs,
    output wire [LAYER_SIZE-1:0]  actuator_outputs
);

    // Configuration Registers
    reg [WEIGHT_WIDTH-1:0] weight_mem [0:LAYER_SIZE-1][0:LAYER_SIZE-1];
    reg [15:0] leak_value;
    reg [15:0] threshold;
    reg [7:0]  refractory_period;

    // SPI Interface Signals
    wire [7:0]  reg_addr;
    wire [31:0] reg_wdata;
    wire        reg_write;
    wire [31:0] reg_rdata;

    spi_interface spi_controller (
        .clk(clk),
        .rst_n(rst_n),
        .spi_clk(spi_clk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_cs_n(spi_cs_n),
        .reg_addr(reg_addr),
        .reg_wdata(reg_wdata),
        .reg_write(reg_write),
        .reg_rdata(reg_rdata)
    );

    neural_network network (
        .clk(clk),
        .rst_n(rst_n),
        .input_spikes(sensor_inputs),
        .output_spikes(actuator_outputs),
        .weights(weight_mem)
    );

    // Configuration Register Write
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            leak_value          <= 16'd10;
            threshold           <= 16'd200;
            refractory_period   <= 8'd8;
            for (int i = 0; i < LAYER_SIZE; i = i + 1)
                for (int j = 0; j < LAYER_SIZE; j = j + 1)
                    weight_mem[i][j] <= '0;
        end else if (reg_write) begin
            case (reg_addr)
                8'h00: leak_value        <= reg_wdata[15:0];
                8'h01: threshold         <= reg_wdata[15:0];
                8'h02: refractory_period <= reg_wdata[7:0];
                default: if (reg_addr >= 8'h10) begin
                    automatic int idx = reg_addr - 8'h10;
                    weight_mem[idx/LAYER_SIZE][idx%LAYER_SIZE] <= reg_wdata[WEIGHT_WIDTH-1:0];
                end
            endcase
        end
    end

    // Configuration Register Read
    assign reg_rdata = 
        (reg_addr == 8'h00) ? leak_value :
        (reg_addr == 8'h01) ? threshold :
        (reg_addr == 8'h02) ? {24'b0, refractory_period} :
        (reg_addr >= 8'h10) ? {24'b0, weight_mem[(reg_addr-8'h10)/LAYER_SIZE][(reg_addr-8'h10)%LAYER_SIZE]} :
        32'b0;

endmodule

