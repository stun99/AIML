module lif_neuron #(
    parameter CURRENT_WIDTH = 10,
    parameter POTENTIAL_WIDTH = 16,
    parameter REFRACTORY_PERIOD = 8
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire [CURRENT_WIDTH-1:0]     current_in,
    input  wire [POTENTIAL_WIDTH-1:0]   leak_value,
    input  wire [POTENTIAL_WIDTH-1:0]   threshold,
    output reg                          spike_out
);

    reg [POTENTIAL_WIDTH-1:0] membrane_potential;
    reg [REFRACTORY_PERIOD-1:0] refractory_counter;
    reg [POTENTIAL_WIDTH-1:0] next_potential;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            membrane_potential  <= '0;
            refractory_counter  <= '0;
            spike_out           <= '0;
        end else begin
            if (refractory_counter > 0) begin
                refractory_counter <= refractory_counter - 1'b1;
                spike_out <= 1'b0;
            end else begin
                // Integrate and leak
                next_potential = membrane_potential + current_in;
                if (next_potential > leak_value)
                    next_potential = next_potential - leak_value;
                else
                    next_potential = '0;

                // Fire condition
                if (next_potential >= threshold) begin
                    spike_out           <= 1'b1;
                    membrane_potential  <= '0;
                    refractory_counter  <= REFRACTORY_PERIOD;
                end else begin
                    spike_out           <= 1'b0;
                    membrane_potential  <= next_potential;
                end
            end
        end
    end
endmodule
