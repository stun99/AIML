module axi4_lite_slave #(
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    
    // AXI4-Lite interface
    input wire [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output reg s_axi_awready,
    input wire [AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input wire [AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output reg s_axi_wready,
    output reg [1:0] s_axi_bresp,
    output reg s_axi_bvalid,
    input wire s_axi_bready,
    input wire [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output reg s_axi_arready,
    output reg [AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output reg [1:0] s_axi_rresp,
    output reg s_axi_rvalid,
    input wire s_axi_rready,
    
    // Register interface
    output reg reg_write_en,
    output reg [AXI_ADDR_WIDTH-1:0] reg_write_addr,
    output reg [AXI_DATA_WIDTH-1:0] reg_write_data,
    output reg reg_read_en,
    output reg [AXI_ADDR_WIDTH-1:0] reg_read_addr,
    input wire [AXI_DATA_WIDTH-1:0] reg_read_data
);

    // Write transaction handling
    reg aw_ready, w_ready, b_valid;
    reg [AXI_ADDR_WIDTH-1:0] write_addr;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b0;
            s_axi_wready <= 1'b0;
            s_axi_bvalid <= 1'b0;
            s_axi_bresp <= 2'b00;
            reg_write_en <= 1'b0;
        end else begin
            // Write address ready
            if (s_axi_awvalid && !s_axi_awready) begin
                s_axi_awready <= 1'b1;
                write_addr <= s_axi_awaddr;
            end else begin
                s_axi_awready <= 1'b0;
            end
            
            // Write data ready
            if (s_axi_wvalid && !s_axi_wready) begin
                s_axi_wready <= 1'b1;
                reg_write_en <= 1'b1;
                reg_write_addr <= write_addr;
                reg_write_data <= s_axi_wdata;
            end else begin
                s_axi_wready <= 1'b0;
                reg_write_en <= 1'b0;
            end
            
            // Write response
            if (reg_write_en && !s_axi_bvalid) begin
                s_axi_bvalid <= 1'b1;
                s_axi_bresp <= 2'b00; // OKAY
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end
    
    // Read transaction handling
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_arready <= 1'b0;
            s_axi_rvalid <= 1'b0;
            s_axi_rresp <= 2'b00;
            s_axi_rdata <= 32'h0;
            reg_read_en <= 1'b0;
        end else begin
            // Read address ready
            if (s_axi_arvalid && !s_axi_arready) begin
                s_axi_arready <= 1'b1;
                reg_read_en <= 1'b1;
                reg_read_addr <= s_axi_araddr;
            end else begin
                s_axi_arready <= 1'b0;
                reg_read_en <= 1'b0;
            end
            
            // Read data valid
            if (reg_read_en && !s_axi_rvalid) begin
                s_axi_rvalid <= 1'b1;
                s_axi_rdata <= reg_read_data;
                s_axi_rresp <= 2'b00; // OKAY
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule