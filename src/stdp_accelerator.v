`default_nettype none
`timescale 1ns / 1ps

module stdp_accelerator (
    input  wire       clk,           // System clock
    input  wire       rst_n,         // Active-low reset
    input  wire       pre_spike,     // Flag: 1 when pre-synaptic neuron fires
    input  wire       post_spike,    // Flag: 1 when post-synaptic neuron fires
    input  wire [7:0] weight_in,     // Current synaptic weight (0 to 255)
    output reg  [7:0] weight_out     // Updated synaptic weight
);

    // Internal timing registers to track the delta between spikes
    reg [7:0] pre_timer;
    reg [7:0] post_timer;

    // Hardcoded STDP parameters (acting as our Fixed-Point 'A' and 'tau')
    // In a final design, these could be configurable via SPI
    localparam [7:0] LTP_REWARD = 8'd16; // Long-Term Potentiation (Weight Increase)
    localparam [7:0] LTD_PENALTY = 8'd8; // Long-Term Depression (Weight Decrease)
    localparam [7:0] TIME_WINDOW = 8'd50; // Max clock cycles to consider a correlation

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight_out <= 8'd0;
            pre_timer  <= 8'd0;
            post_timer <= 8'd0;
        end else begin
            // Default: hold the current weight unless a spike occurs
            weight_out <= weight_in;

            // 1. Timer Management (Decay over time)
            if (pre_timer > 0)  pre_timer  <= pre_timer - 1;
            if (post_timer > 0) post_timer <= post_timer - 1;

            // 2. Pre-Synaptic Spike Logic (Checks for LTD)
            if (pre_spike) begin
                pre_timer <= TIME_WINDOW; // Reset timer
                // If a post_spike happened recently, this is out of order (Post before Pre) -> Weaken synapse
                if (post_timer > 0) begin
                    if (weight_in > LTD_PENALTY) 
                        weight_out <= weight_in - LTD_PENALTY;
                    else 
                        weight_out <= 8'd0; // Floor saturation (prevent underflow)
                end
            end

            // 3. Post-Synaptic Spike Logic (Checks for LTP)
            if (post_spike) begin
                post_timer <= TIME_WINDOW; // Reset timer
                // If a pre_spike happened recently, this is correct order (Pre before Post) -> Strengthen synapse
                if (pre_timer > 0) begin
                    if (weight_in < (8'd255 - LTP_REWARD)) 
                        weight_out <= weight_in + LTP_REWARD;
                    else 
                        weight_out <= 8'd255; // Ceiling saturation (prevent overflow)
                end
            end
        end
    end

endmodule
