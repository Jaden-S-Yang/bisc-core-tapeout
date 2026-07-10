/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none
`timescale 1ns / 1ps

module tt_um_jaden_bisc_stdp (
    input  wire [7:0] ui_in,    // Dedicated inputs (Weight In)
    output wire [7:0] uo_out,   // Dedicated outputs (Weight Out)
    input  wire [7:0] uio_in,   // IOs: Input path (Spikes)
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high)
    input  wire       ena,      // Always 1 when the design is powered
    input  wire       clk,      // System clock
    input  wire       rst_n     // Reset (active low)
);

    // Tiny Tapeout Rule: All output paths must be assigned.
    // Since we are only using the uio pins as inputs (pre_spike and post_spike),
    // we must set their output drivers and enable paths to 0.
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000; // 0 = Input mode for all bidirectional pins

    // Dummy wire to prevent warnings for unused pins
    wire _unused = &{ena, 1'b0};

    // Instantiate your physical STDP engine block
    stdp_accelerator bisc_core (
        .clk        (clk),
        .rst_n      (rst_n),
        .pre_spike  (uio_in[0]), // Maps to bidirectional pin 0
        .post_spike (uio_in[1]), // Maps to bidirectional pin 1
        .weight_in  (ui_in),     // Maps to the 8 dedicated input pins
        .weight_out (uo_out)     // Maps to the 8 dedicated output pins
    );

endmodule
