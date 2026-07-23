# Maze Game

Try it online! https://torinak.com/qaop/#l=https://keilanknight.com/speccy/mazegame.tap

A simple maze game for the ZX Spectrum, written to demonstrate how easy it is to create games with [Boriel BASIC](https://zxbasic.readthedocs.io/).

Each level generates a new random maze. Collect all the diamonds, then reach the exit to continue to the next stage.

## Controls

- `Q` — up
- `A` — down
- `O` — left
- `P` — right
- `Space` — restart

## Files

- `mazegame.bas` is the complete game, written for the Boriel BASIC compiler.
- `mazedemo.bas` is a learning aid written in pure Sinclair ZX BASIC. It shows the maze-generation algorithm working step by step, including moving forward, finding available routes and backtracking from dead ends.

## Running the programs

Compile `mazegame.bas` with the [Boriel BASIC compiler](https://zxbasic.readthedocs.io/), then load the resulting program in a ZX Spectrum emulator or on real hardware.

`mazedemo.bas` is traditional, line-numbered ZX BASIC and should not be compiled with Boriel BASIC. Upload or paste it into [Remy Sharp's Text 2 BASIC tool](https://zx.remysharp.com/bas/) and export it as a `.TAP` file. The TAP can then be loaded in an emulator or on compatible hardware.
