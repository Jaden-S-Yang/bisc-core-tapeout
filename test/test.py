# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_stdp_core(dut):
    dut._log.info("Starting BISC STDP Hardware Simulation...")

    # 1. Start the 50 MHz System Clock
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())

    # 2. Initialize and Reset the Chip
    dut.ena.value = 1
    dut.ui_in.value = 0   # Base Weight
    dut.uio_in.value = 0  # Spikes (Bit 0: Pre, Bit 1: Post)
    
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    dut._log.info("Chip reset successful.")

    # ----------------------------------------------------
    # TEST 1: Long-Term Potentiation (LTP)
    # ----------------------------------------------------
    dut._log.info("Initiating LTP Test (Pre -> Post)...")
    base_weight = 100
    dut.ui_in.value = base_weight
    await ClockCycles(dut.clk, 2)

    # Fire Pre-Spike (Bit 0 = 1)
    dut.uio_in.value = 1 
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0 # Turn off
    
    # Wait 5 clock cycles
    await ClockCycles(dut.clk, 5)

    # Fire Post-Spike (Bit 1 = 1) -> Binary 2
    dut.uio_in.value = 2 
    await ClockCycles(dut.clk, 1) # During this cycle, the chip calculates 100 + 16 = 116
    
    # CHECK IMMEDIATELY! The output is valid for exactly one clock cycle
    assert dut.uo_out.value == 116, f"LTP FAILED! Expected 116, Got {dut.uo_out.value}"
    dut._log.info("SUCCESS: LTP verified. Weight strengthened.")
    
    # Turn off spike and let logic settle
    dut.uio_in.value = 0 
    await ClockCycles(dut.clk, 2) 

    # ----------------------------------------------------
    # TEST 2: Long-Term Depression (LTD)
    # ----------------------------------------------------
    dut._log.info("Initiating LTD Test (Post -> Pre)...")
    await ClockCycles(dut.clk, 60) # Wait for timers to fully reset
    
    # Fire Post-Spike first
    dut.uio_in.value = 2
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0
    
    # Wait 10 clock cycles
    await ClockCycles(dut.clk, 10)

    # Fire Pre-Spike second
    dut.uio_in.value = 1
    await ClockCycles(dut.clk, 1) # During this cycle, it calculates 100 - 8 = 92
    
    # CHECK IMMEDIATELY!
    assert dut.uo_out.value == 92, f"LTD FAILED! Expected 92, Got {dut.uo_out.value}"
    dut._log.info("SUCCESS: LTD verified. Weight weakened.")
    
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 2)

    dut._log.info("BISC Core Simulation Complete. Ready for Foundry.")
