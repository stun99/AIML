module qlearn(
    input clk,
    input reset,
    output reg done
);
    // Q-learning parameters
    parameter EPISODES = 10000;
    // Dimensions: 5x5 grid, 4 actions (up=0, down=1, left=2, right=3)
    // Q-table: indexed by [x][y][action], 16-bit signed
    logic signed [15:0] Q [0:4][0:4][0:3];

    // State coordinates
    logic [2:0] cur_x, cur_y;
    logic [2:0] new_x, new_y;

    // Epsilon-greedy action selection
    logic [1:0] action;
    // 8-bit LFSR for random number generation
    logic [7:0] lfsr;

    // Episode counter
    logic [15:0] episode_count;
    // Temporary registers for computation
    logic signed [15:0] reward, max_next, diff;
    logic is_terminal;

    // FSM state encoding
    logic [2:0] state;
    localparam STATE_INIT    = 3'd0,
               STATE_START   = 3'd1,
               STATE_CHOOSE  = 3'd2,
               STATE_EXECUTE = 3'd3,
               STATE_UPDATE  = 3'd4,
               STATE_NEXT_EP = 3'd5,
               STATE_DONE    = 3'd6;

    integer i, j, k;

    // Main sequential process: reset and state transitions
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset internal variables
            done          <= 1'b0;
            episode_count <= 16'd0;
            cur_x <= 3'd0; cur_y <= 3'd0;
            new_x <= 3'd0; new_y <= 3'd0;
            action  <= 2'd0;
            reward  <= 16'sd0;
            is_terminal <= 1'b0;
            state   <= STATE_INIT;
            // Initialize LFSR with non-zero seed
            lfsr <= 8'hA5;
            // Initialize all Q-values to 0
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    for (k = 0; k < 4; k = k + 1) begin
                        Q[i][j][k] <= 16'sd0;
                    end
                end
            end
        end else begin
            case (state)
                STATE_INIT: begin
                    // Move to the first episode start
                    state <= STATE_START;
                end

                STATE_START: begin
                    // Begin new episode: reset agent to (0,0)
                    cur_x <= 3'd0;
                    cur_y <= 3'd0;
                    state <= STATE_CHOOSE;
                end

                STATE_CHOOSE: begin
                    // Generate new random value via LFSR
                    reg [7:0] rand_val;
                    rand_val = {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
                    lfsr <= rand_val;
                    // Epsilon-greedy action selection (epsilon ~ 0.1)
                    if (rand_val < 8'd26) begin
                        // Exploration: choose random action
                        action <= rand_val[1:0];
                    end else begin
                        // Exploitation: pick action with highest Q at (cur_x, cur_y)
                        reg signed [15:0] best_val;
                        reg [1:0] best_action;
                        best_val = Q[cur_x][cur_y][0];
                        best_action = 2'd0;
                        for (i = 1; i < 4; i = i + 1) begin
                            if (Q[cur_x][cur_y][i] > best_val) begin
                                best_val = Q[cur_x][cur_y][i];
                                best_action = i;
                            end
                        end
                        action <= best_action;
                    end
                    state <= STATE_EXECUTE;
                end

                STATE_EXECUTE: begin
                    // Apply action to compute new state (with boundary checks)
                    new_x <= cur_x;
                    new_y <= cur_y;
                    case (action)
                        2'd0: if (cur_y < 3'd4) new_y <= cur_y + 1; // UP
                        2'd1: if (cur_y > 3'd0) new_y <= cur_y - 1; // DOWN
                        2'd2: if (cur_x > 3'd0) new_x <= cur_x - 1; // LEFT
                        2'd3: if (cur_x < 3'd4) new_x <= cur_x + 1; // RIGHT
                    endcase
                    // Determine reward and terminality
                    if (new_x == 3'd4 && new_y == 3'd4) begin
                        // Goal state
                        reward      <= 16'sd1;
                        is_terminal <= 1'b1;
                    end else if ((new_x == 3'd1 && new_y == 3'd0) ||
                                 (new_x == 3'd3 && new_y == 3'd1) ||
                                 (new_x == 3'd4 && new_y == 3'd2) ||
                                 (new_x == 3'd1 && new_y == 3'd3)) begin
                        // Hole states
                        reward      <= -16'sd5;
                        is_terminal <= 1'b1;
                    end else begin
                        // Non-terminal move
                        reward      <= -16'sd1;
                        is_terminal <= 1'b0;
                    end
                    state <= STATE_UPDATE;
                end

                STATE_UPDATE: begin
                    // Compute Q-learning update
                    if (is_terminal) begin
                        // Terminal: only immediate reward
                        diff = reward - Q[cur_x][cur_y][action];
                    end else begin
                        // Non-terminal: include discounted future reward
                        max_next = Q[new_x][new_y][0];
                        for (i = 1; i < 4; i = i + 1) begin
                            if (Q[new_x][new_y][i] > max_next) begin
                                max_next = Q[new_x][new_y][i];
                            end
                        end
                        // Compute diff = (reward + 0.9*max_next) - Q
                        // Here 0.9 is approximated by (9*max_next)/10
                        diff = (reward + (max_next * 9) / 10) - Q[cur_x][cur_y][action];
                    end
                    // Update Q: alpha=0.5 -> add half of diff (signed shift right 1)
                    Q[cur_x][cur_y][action] <= Q[cur_x][cur_y][action] + (diff >>> 1);

                    if (is_terminal) begin
                        // End of episode if goal or hole reached
                        state <= STATE_NEXT_EP;
                    end else begin
                        // Move to next state and continue episode
                        cur_x <= new_x;
                        cur_y <= new_y;
                        state <= STATE_CHOOSE;
                    end
                end

                STATE_NEXT_EP: begin
                    // Episode finished; increment count
                    episode_count <= episode_count + 1;
                    if (episode_count == EPISODES - 1) begin
                        // Training done
                        done  <= 1'b1;
                        state <= STATE_DONE;
                    end else begin
                        // Start next episode
                        state <= STATE_START;
                    end
                end

                STATE_DONE: begin
                    // Training complete; hold final Q-values
                    state <= STATE_DONE;
                end
            endcase
        end
    end
endmodule

