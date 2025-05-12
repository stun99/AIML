`timescale 1ns/1ps

// tb_lif_neuron.v
module tb_lif_neuron;
    reg         clk;
    reg         rst;
    reg  [15:0] in;
    reg         threshold_select;
    wire        spike;
    wire [15:0] potential;

    // Instantiate the LIF neuron
    lif_neuron uut (
        .clk(clk),
        .rst(rst),
        .in(in),
        .threshold_select(threshold_select),
        .spike(spike),
        .potential(potential)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Monitor signals
    initial begin
        $display("Time |  in  thr_sel potential spike");
        $monitor("%4t | %3d    %b       %3d      %b", 
                 $time, in, threshold_select, potential, spike);
    end

    // Test scenarios
    initial begin
        // Initial reset
        rst = 1;
        #15;
        rst = 0;

        // Scenario 1: constant input below lower threshold (50)
        threshold_select = 0;
        in = 16'd20;  // constant input 20
        // Potential will build up but leak prevents reaching 50
        #100;

        // Scenario 2: accumulate to threshold (starting after resetting)
        // Reset the neuron before this scenario for clarity
        rst = 1;
        #10;
        rst = 0;
        threshold_select = 0;
        in = 16'd26;  // moderate input 26
        // Potential should reach >=50 after a few cycles, causing a spike
        #50;

        // Scenario 3: no input (leakage behavior)
        // Reset before demonstrating leak from zero potential
        rst = 1;
        #10;
        rst = 0;
        threshold_select = 0;
        in = 16'd0;  // no input
        // Potential should decay (stays 0 since starting from 0)
        #30;

        // Scenario 4: strong input immediate spike (higher threshold 200)
        rst = 1;
        #10;
        rst = 0;
        threshold_select = 1;
        in = 16'd200;  // strong input = 200
        // Immediate spike expected on first cycle
        #20;

        $finish;
    end
endmodule

