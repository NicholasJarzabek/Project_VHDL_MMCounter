# Project 4: Multi-mode counter
* Autors: Nicholas Jarzabek, Vaclav Javurek, David Kevely
* [Video of functionality](https://drive.google.com/file/d/1VYxotUysiJ_GsMJ7Ut3g0ljJxdD-CJsK/view?usp=sharing) 
- [O projektu](./README.md#O-Projektu)
- [Popis funkčnosti tlačidiel](./README.md#Popis-funkčnosti-tlačidiel)
- [Blokove schema](./README.md#Blokove-schema)
- [Blokove schema generovane Vivadom](./README.md#Blokove-schema-generovane-Vivadom)
- [Implemented Design](./README.md#Implemented-design)
- [Simulace](./README.md#Simulace)
- [Video](./README.md#Video)
- [Vstupy a vystupy](./README.md#Vstupy-a-vystupy)
- [Importovane Subory](./README.md#Importovane-Subory)
- [Reference](./README.md#Reference)
## Poster 
![Simulacia](IMGs/Poster.png)
- `Switches and Buttons` => input
- `Debounce and Clock gen` => Debounce modules and clock generators
- `16-Bit Counter and Control` => contains Step size, Speed select,Run/Pause select, Mode Control, GAME (Counter+Control)
- `Display / LEDs` => Display Formatter and Display Driver
# Project Overview
- Purpose: An FPGA-based 16-bit counter controlled via buttons and switches, displaying real-time values on an 8-digit 7-segment display and 16 LEDs.
- `debounce` - Ensures reliable button presses by filtering out mechanical switch bouncing, so one physical press equals exactly one logic pulse.
- `Clock Enable` - Generates timing pulses from the main 100MHz clock to control the speed of the automatic counting.
- `MMCounter` - The top-level module that ties the inputs (buttons/switches) to the counter logic and routes the formatted data to the displays.
- `bin2seg` - Translates 4-bit binary/hexadecimal values into the specific LED segment patterns required to display characters (0-9, A-F).
- `display driver` - Handles the rapid multiplexing (switching between anodes) required to show different numbers on all 8 digits of the 7-segment display simultaneously without flickering.

## input/output 
- BTNC: Resets the entire system. It forces the counter back to 0 and resets the display mode to Decimal.
- BTNR: Cycles through the three display modes in this order: Decimal=>Hexadecimal=>text  back to Decimal.
- BTNL: Toggles the automatic counting on or off (Run/Pause).
- BTNU: Triggers a single, manual step of the counter (useful when auto-counting is paused).
- BTND: Loads an external 8-bit value directly into the counter from the upper switches.

- SW[0]: Sets the counting direction (0 = count up, 1 = count down).
- SW[3:2]: Selects the automatic counting speed. There are four speed tiers ranging from the slowest (00) to the fastest (11).
- SW[7:4]: Sets the step size for the counter (from 1 to 15). If all four switches are down (0000), the system defaults to a step size of 1.
- SW[15:8]: Acts as an 8-bit loadable data vector. When BTND is pressed, the binary value set on these switches is pushed into the counter.
  
- `clk` - clock signal  (100 Mhz)
- `AN` - anode
- `SEG` - segments
- `LED` - LED
- `DP` - Decimal Point

## Display Modes
- Mode 0 (Decimal): Converts the binary counter into a standard base-10 number, displaying values from 00000000 to 00065535.
- Mode 1 (Hexadecimal): Displays the raw 16-bit counter value in base-16, showing values from 00000000 to 0000FFFF.
- Mode 2 (Scroll text): A custom visual mode that displays a shifting "DE1" text pattern across the 7-segment display, animated by the current counter value.


## Block diagram


  
![Simulácia](IMGs/schema_new.png)

## System Architecture
- `debounce` To ensure stable operation on physical hardware, all button inputs (BTNC through BTND) pass through dedicated Debounce modules.
- `Clock Enable Generators` This module is made of Clock Enable generators chosen with switches (1s,0.5s, 0.25s, 0.1s)
- `Mode Control` Processes button presses to toggle between different operational modes
- `Step Size` controls step size via switches and run/pause of counting counter
- `Speed Select Logic` depending on state of switches SW[3:2] controls 4:1 MUX
- `Run/Pause Toggle`  acts as the "Start/Stop" switch for the counter via button.
- `4:1 MUX (Multiplexer)` selects one Clock Enable Generator via switches
- `GAME (Counter + Control)` brain, holds all the information and combines for function
- `Display Formatter` prepares data for 7-segment display depends on mode chosen
- `Display Driver` Sends corresponding segment patterns on display

## Signals
## External signals
- `clk` Master system clock,keeps the entire system synchronized.
- `BTNX` un_debaunced electrical signals from buttons
- `SW[15:0]` The raw 16-bit bus representing all 16 physical slide switches split up and routed to the Step Size module, Speed Select module, Clock Enable Generators, and directly into the GAME module.
## Debounce signals
These modules take the raw button inputs and output clean digital signals
- `rst_state & rst_press` from BTNC:`rst_state` reset if button held(to first mode), `rst_press` zeroes display
- `mode_state & mode_press` holds information about current mode state and with press of BTNR changes mode
- `run_press` toggle switch for Run/Pause=> BTNL
- `step_state & step_press`  BTNU=> The state and pulse signals for the manual step button
- `load_state & load_press` BTND=> Loads set number and holds information about set ammount via SW[15:7]
## User Interface signals
- `mode_reg[1:0]` holds current mode(Dec/Hex/Text/)
- `run_reg` run/pause for counting
- `step_size[15:0]` step size chosen with SW[7:4]
- `sw_s[1:0]` choice of speed pulse let through 4:1 MUX
## Timing Generation signal
-  `ce0, ce1, ce2, ce3` Clock enable generators
-  `tick` single chosen timing from Clock enable generator
##  GAME Module signals
-  `count_val[15:0]` mathematical value of current count
-  `led[15:0]` output for LEDs (High/Low)
##  Display signals
-  `digits_8x4[31:0]` A 32-bit bus containing eight individual 4-bit numbers
-  `seg[6:0]` lights up the A through G segments on the  7-segment display.
-  `an[7:0]` The 8 hardware pins (anodes) that quickly turn the individual 8 digits on and off for multiplexing.
-  `dp` Controls decimal point on display
## Implemented Design
  
![Simulácia](IMGs/ImplementedDesign.png)

## Simulations
![Simulácia](IMGs/simulace.png)

- `Simulation 2`
- A correctly generated clock signal (`clk`) with a regular periodic waveform is visible on the simulation chart.

- The input bus `SW[15:0]` changes during the simulation (e.g., `0000` → `0004` → `0008` → `000E` → `002C` → `AA2C`), with individual bits toggling as expected.

- The button signals (`BTNC`, `BTNR`, `BTNL`, `BTNU`, `BTND`) contain short pulses.

- Outputs:
- `AN` = FE – Only one display digit is active.
- `SEG` = 01 – Constant segment pattern.
- `LED` = 0000 – No change throughout the entire simulation.
- `DP` = 1 – The decimal point is turned off.

![Simulácia](IMGs/simulacia2.png)

- `Simulation 3`

A stable clock signal (`clk`) with a regular periodic waveform is visible on the waveform. The button signals (`BTNL`, `BTNU`, `BTND`) contain short pulses occurring at various points in time.

Display Outputs:

`AN` = FE – Only one display digit is active.

`SEG` – Switches dynamically (segment multiplexing), with individual bits changing rapidly.

LED Output (`LED[15:0]`) displays the binary value of the counter:

Primarily the lower bits change (`LED(0)` through `LED(4)`).

The higher bits remain zero.

![Simulácia](IMGs/simulacia3.png)

## [Video of Functionality](https://drive.google.com/file/d/1VYxotUysiJ_GsMJ7Ut3g0ljJxdD-CJsK/view?usp=sharing) 




## Imported files 
- clk_en.vhd
- counter.vhd
- debounce.vhd
- display_driver.vhd

## Reference
- ChatGPT / Claude AI for code optimization, troubleshooting, and implementation assistance when we were stuck, gemini used for general structure of poster.
- [Online VHDL Testbench Template Generator](https://vhdl.lapinoo.net/)
- [Nexys A7 Digilent Reference](https://digilent.com/reference/programmable-logic/nexys-a7/start)
