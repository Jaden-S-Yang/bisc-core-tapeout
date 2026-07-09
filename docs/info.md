<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This chip is a physical hardware acceleration core for a Brain-Implantable System-on-Chip (BISC). It calculates Spike-Timing-Dependent Plasticity (STDP) in zero-latency, fixed-point digital logic. 

Traditional neuro-implants stream raw data to external software CPUs, introducing unpredictable timing jitter and massive thermal output. This core bypasses software entirely, hardwiring the synaptic update equation into silicon. It maintains a biological "time window" using countdown registers. 
* If a `pre_spike` occurs before a `post_spike` within the window, the 8-bit synaptic weight undergoes Long-Term Potentiation (LTP) and increases. 
* If a `post_spike` precedes a `pre_spike`, it undergoes Long-Term Depression (LTD) and decreases.

## How to test

1. Apply a base 8-bit synaptic weight to the input pins (`ui_in`).
2. Provide a clock signal (`clk`) and hold reset high (`rst_n = 1`).
3. Toggle the `pre_spike` (`uio_in[0]`) and `post_spike` (`uio_in[1]`) pins high for a single clock cycle at different intervals.
4. Observe the `uo_out` pins. If `pre_spike` fired right before `post_spike`, the output weight will be higher than the input weight. If the order is reversed, the output weight will be lower. The maximum saturation is 255, and the floor is 0.

## External hardware

To test this physically once manufactured, you will need a logic analyzer or a microcontroller (like a Raspberry Pi Pico) capable of generating nanosecond-level pulse timings on the `uio_in` pins to simulate biological action potentials.
