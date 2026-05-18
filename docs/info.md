## How it works

This project implements a simple digital logic design for the Tiny Tapeout platform.
The circuit processes input signals on each clock cycle and produces output values
through the output pins.

Inputs:
- ui_in[] : control and data inputs
- clk     : system clock
- rst_n   : active-low reset

Outputs:
- uo_out[] : processed output signals

The design operates synchronously with the clock. When reset is asserted,
all internal states return to their default values.

## How to test

1. Apply a clock signal to the design.
2. Drive input values through the ui_in pins.
3. Observe output changes on uo_out.
4. Assert rst_n low to reset the design.

Simulation can be executed with:

```bash
make test