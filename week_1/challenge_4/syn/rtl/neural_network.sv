`include "lif_neuron.sv"
module neural_network #(
    parameter CURRENT_WIDTH = 10,
    parameter LAYER_SIZE    = 4,
    parameter WEIGHT_WIDTH  = 8,
    parameter SYNAPSE_DEPTH = 4
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire [LAYER_SIZE-1:0]        input_spikes,
    output wire [LAYER_SIZE-1:0]        output_spikes,
    input  wire [WEIGHT_WIDTH-1:0]      weights [0:LAYER_SIZE-1][0:LAYER_SIZE-1]
);

    wire [CURRENT_WIDTH-1:0] synaptic_currents [LAYER_SIZE-1:0];

    generate
        genvar i, j;
        for (i = 0; i < LAYER_SIZE; i = i + 1) begin : neuron_layer
            // Current aggregation
            assign synaptic_currents[i] = 
                (input_spikes[0] ? {2'b00, weights[i][0]} : '0) +
                (input_spikes[1] ? {2'b00, weights[i][1]} : '0) +
                (input_spikes[2] ? {2'b00, weights[i][2]} : '0) +
                (input_spikes[3] ? {2'b00, weights[i][3]} : '0);

            lif_neuron #(
                .CURRENT_WIDTH(10),
                .POTENTIAL_WIDTH(16),
                .REFRACTORY_PERIOD(8)
            ) neuron_inst (
                .clk(clk),
                .rst_n(rst_n),
                .current_in(synaptic_currents[i]),
                .leak_value(16'd10),
                .threshold(16'd200),
                .spike_out(output_spikes[i])
            );
        end
    endgenerate
endmodule

