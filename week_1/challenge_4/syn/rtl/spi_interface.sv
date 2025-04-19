module spi_interface #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input  wire               clk,
    input  wire               rst_n,
    // SPI Interface
    input  wire               spi_clk,
    input  wire               spi_mosi,
    output wire               spi_miso,
    input  wire               spi_cs_n,
    // Register Interface
    output reg [ADDR_WIDTH-1:0] reg_addr,
    output reg [DATA_WIDTH-1:0] reg_wdata,
    output reg                reg_write,
    input  wire [DATA_WIDTH-1:0] reg_rdata
);

    typedef enum logic [2:0] {
        IDLE      = 3'b000,
        CMD       = 3'b001,
        ADDR      = 3'b010,
        WRITE     = 3'b011,
        READ      = 3'b100
    } state_t;

    state_t current_state;
    reg [2:0] bit_counter;
    reg [DATA_WIDTH-1:0] shift_reg;
    reg cmd_type;

    always @(posedge spi_clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            reg_addr      <= '0;
            reg_wdata     <= '0;
            reg_write     <= 1'b0;
            shift_reg     <= '0;
            bit_counter   <= '0;
            cmd_type      <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    reg_write <= 1'b0;
                    if (!spi_cs_n) begin
                        current_state <= CMD;
                        bit_counter   <= 3'd7;
                    end
                end

                CMD: begin
                    shift_reg <= {shift_reg[DATA_WIDTH-2:0], spi_mosi};
                    if (bit_counter == 0) begin
                        cmd_type      <= shift_reg[7];
                        current_state <= ADDR;
                        bit_counter   <= ADDR_WIDTH - 1;
                    end else begin
                        bit_counter <= bit_counter - 1'b1;
                    end
                end

                ADDR: begin
                    shift_reg <= {shift_reg[DATA_WIDTH-2:0], spi_mosi};
                    if (bit_counter == 0) begin
                        reg_addr <= shift_reg[ADDR_WIDTH-1:0];
                        current_state <= cmd_type ? READ : WRITE;
                        bit_counter <= DATA_WIDTH - 1;
                    end else begin
                        bit_counter <= bit_counter - 1'b1;
                    end
                end

                WRITE: begin
                    shift_reg <= {shift_reg[DATA_WIDTH-2:0], spi_mosi};
                    if (bit_counter == 0) begin
                        reg_wdata <= shift_reg;
                        reg_write <= 1'b1;
                        current_state <= IDLE;
                    end else begin
                        bit_counter <= bit_counter - 1'b1;
                    end
                end

                READ: begin
                    if (bit_counter == 0)
                        current_state <= IDLE;
                    else
                        bit_counter <= bit_counter - 1'b1;
                end

                default: current_state <= IDLE;
            endcase
        end
    end

    assign spi_miso = (!spi_cs_n && (current_state == READ)) ? 
                     reg_rdata[bit_counter] : 1'bz;
endmodule

