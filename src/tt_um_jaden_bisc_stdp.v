/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns / 1ps

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 8'b00000000;
  assign uio_oe  = 8'b00000000;

    // Instantiate your physical STDP engine block
    stdp_accelerator bisc_core (
        .clk        (clk),
        .rst_n      (rst_n),
        .pre_spike  (uio_in[0]), // Maps to bidirectional pin 0
        .post_spike (uio_in[1]), // Maps to bidirectional pin 1
        .weight_in  (ui_in),     // Maps to the 8 dedicated input pins
        .weight_out (uo_out)     // Maps to the 8 dedicated output pins
    );

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule
