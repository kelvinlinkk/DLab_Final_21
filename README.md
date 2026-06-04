# Digital Lab Final Project: 21 Card Game (Blackjack)

This repository contains the Verilog source code and associated files for an FPGA-based implementation of the classic casino game Blackjack (21). The project supports multiplayer functionality over UART and features a complete hardware-based UI utilizing the seven-segment display, RGB LEDs, buttons, and an external speaker for audio feedback.

## Features

- **Multiplayer Support**: Host up to 4 players via UART communication between multiple FPGA boards.
- **Hardware Game Logic**: Complete game logic implemented in hardware including card shuffling, drawing, betting, insurance, and win/loss evaluations (including Blackjack and 5-Card Charlie rules).
- **Seven-Segment Display UI**: Dynamic UI rendering game state, scores, bets, and cards on the board's 7-segment display.
- **Audio Feedback**: PWM-based audio output for game events such as dealing cards, betting, winning, losing, and tying.
- **RGB LED Indicators**: Visual game state indicators via RGB LEDs.
- **Hardware RNG**: A randomized card serving mechanism for fair play.

## Project Structure

The project is divided into the core game logic/UI in the `start_ui/` directory and testbenches/resources in the `data/` directory.

### `start_ui/` (Source Code)

This directory contains all the synthesisable Verilog modules for the FPGA implementation.

*   **Top Level**:
    *   `start_ui_top.v`: The top-level module that integrates the game logic, UI components, UART communication, audio, and I/O handling.
*   **Game Logic & FSM**:
    *   `start_ui_host.v`: The main state machine for the host, managing the overall game flow, player turns, dealer actions, and multi-board synchronization.
    *   `game_play.v`: The core game logic for individual players (betting, hitting, standing).
    *   `serve.v`: Random card generator and shuffling mechanism.
*   **Communication**:
    *   `rx.v`, `tx.v`: UART Receiver and Transmitter modules for cross-board communication.
*   **User Interface (UI)**:
    *   `before_sevenseg.v`: Logic to decode game states into seven-segment display data.
    *   `segment_decoder.v`: Multiplexed driver for the 8-digit seven-segment display.
    *   `color_fsm.v`: FSM controlling the RGB LEDs based on game events.
*   **Audio**:
    *   `audio_ctl.v`: Controls which sound effects to play based on game state changes.
    *   `tone.v`, `pwn_generator.v`: Generates PWM audio signals for sound playback.
*   **Utilities**:
    *   `clk_divider.v`: Clock dividers for scan rates and slow game logic ticks.
    *   `press_button.v`: Button debouncer and pulse generator.
*   **Constraints**:
    *   `final_project_constraint.xdc`: Xilinx constraint file mapping logical ports to physical FPGA pins.

### `data/` (Testbenches and Resources)

Contains simulation testbenches and visual resources.

*   `tb_system.v`: Full system simulation testbench.
*   `tb_start_ui_host.v`: Testbench focusing on the host state machine.
*   `tb_start_ui_player.v`: Testbench for player interactions.
*   Screenshots demonstrating gameplay states.

## Nexys 4 DDR Hardware Setup Guide

This project is configured specifically for the **Digilent Nexys 4 DDR** FPGA board. The XDC constraint file (`final_project_constraint.xdc`) maps the physical pins to the Verilog top-level module. 

### Basic Controls

| Control | Nexys 4 DDR Component | Description |
| :--- | :--- | :--- |
| **Reset** | **CPU RESET (C12)** | System Reset (Active Low). Press to completely reset the game. |
| **Host/Player Mode** | **SW15 (V10)** | Set High (`1`) to become the Host. Set Low (`0`) to join as a Player. |
| **Up** | **BTN U (M18)** | Used to Hit (draw a card), adjust bet amount, or navigate options. |
| **Down** | **BTN D (P18)** | Used to Stand (end turn), shuffle, or adjust options. |
| **Center** | **BTN C (N17)** | Select/Confirm action, or start the game. |
| **Left / Right** | **BTN L (P17) / BTN R (M17)** | Used to scroll through pages (like viewing drawn cards). |

### Output Displays

- **Seven-Segment Display**: Used to show the game state, current bets, drawn cards, and dealer cards.
- **RGB LED 16**: Visual indicator for game state (Winning/Losing/Tying).
    - **Red**: `N15`
    - **Green**: `M16`
    - **Blue**: `R12`

### External Hardware Interfaces (PMODs)

The game requires external PMOD connections for the multiplayer UART communication and the audio output.

#### Audio Output
- **PMOD JD (Pin 4 / G3)**: Connect your PWM Audio Amplifier PMOD or speaker to **Pin 4 on PMOD JD** to hear the game's sound effects.

#### Multiplayer UART Setup (Cross-wiring)
If you are connecting multiple Nexys 4 DDR boards, use jumper wires to connect the TX of the host to the RX of the player, and vice versa.

- **Host Player Connection (PMOD JA)**:
    - **RX (signal_in_p)**: Pin 3 (E18)
    - **TX (signal_out_p)**: Pin 4 (G17)
- **Player 1 Connection (PMOD JA)**:
    - **RX (signal_in_p1)**: Pin 1 (C17)
    - **TX (signal_out_p1)**: Pin 2 (D18)
- **Player 2 Connection (PMOD JB)**:
    - **RX (signal_in_p2)**: Pin 1 (D14)
    - **TX (signal_out_p2)**: Pin 2 (F16)
- **Player 3 Connection (PMOD JC)**:
    - **RX (signal_in_p3)**: Pin 1 (K1)
    - **TX (signal_out_p3)**: Pin 2 (F6)
- **Player 4 Connection (PMOD JD)**:
    - **RX (signal_in_p4)**: Pin 1 (H4)
    - **TX (signal_out_p4)**: Pin 2 (H1)

**Note:** Ensure that all connected boards share a common ground (GND pin on the PMOD headers) when playing in multiplayer mode.

## Setup and Synthesis (Vivado)

1.  Create a new project in Xilinx Vivado and select the **Nexys 4 DDR (xc7a100tcsg324-1)** part.
2.  Add all Verilog (`.v`) files from the `start_ui/` directory as Design Sources.
3.  Add `start_ui/final_project_constraint.xdc` as the Constraints file.
4.  Set `start_ui_top.v` as the Top Module.
5.  Run Synthesis, Implementation, and Generate Bitstream.
6.  Open Hardware Manager and program your Nexys 4 DDR board.