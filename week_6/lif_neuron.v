// lif_neuron.v
// 16-bit Leaky Integrate-and-Fire (LIF) neuron with dual thresholds

module lif_neuron (
    input  wire        clk,             // clock input
    input  wire        rst,             // asynchronous reset (active high)
    input  wire [15:0] in,              // binary input (can be 0 or positive value)
    input  wire        threshold_select,// 0 = lower threshold, 1 = higher threshold
    output reg         spike,           // output spike (neuron state S(t))
    output reg [15:0]  potential        // internal membrane potential
);

    // Threshold values
    parameter [15:0] LOWER_THRESHOLD  = 16'd50;
    parameter [15:0] HIGHER_THRESHOLD = 16'd200;

    // Combinatorial wire for the selected threshold
    wire [15:0] threshold_val = threshold_select ? HIGHER_THRESHOLD : LOWER_THRESHOLD;

    reg [15:0] newP; // intermediate potential for calculation

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset state
            potential <= 16'd0;
            spike     <= 1'b0;
        end else begin
            // Compute new potential: apply leak (>>1) then add input
            newP = (potential >> 1) + in;

            // Check threshold
            if (newP >= threshold_val) begin
                spike     <= 1'b1;
                potential <= 16'd0;    // reset potential on spike
            end else begin
                spike     <= 1'b0;
                potential <= newP;     // update potential
            end
        end
    end
endmodule

