module tb_qlearn_5x5;
    reg clk;
    reg reset;
    wire done;

    // Instantiate the Q-learning module
    qlearn_5x5 uut (
        .clk(clk),
        .reset(reset),
        .done(done)
    );

    // Clock: 100 MHz (period = 10 ns)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    integer i, j;
    initial begin
        // Apply reset
        reset = 1'b1;
        #10;
        reset = 1'b0;

        // Wait for training to complete
        wait (done == 1'b1);
        @(posedge clk);

        // Print final Q-values for each grid state (x,y) and action
        $display("Training completed. Final Q-values:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $display("State (%0d,%0d): Q_UP=%0d, Q_DOWN=%0d, Q_LEFT=%0d, Q_RIGHT=%0d",
                    i, j, 
                    uut.Q[i][j][0], 
                    uut.Q[i][j][1], 
                    uut.Q[i][j][2], 
                    uut.Q[i][j][3]);
            end
        end

        $finish;
    end
endmodule

