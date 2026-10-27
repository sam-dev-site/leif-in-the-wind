# Status

Updated: 2026-10-27

## Where we are

Godot scaffold is in `game/`. One **seed-generated** `coastal_north` chunk: shore on the south, caribou trail inland, fir/spruce/bakeapple/blueberry placeholders. Walk with WASD. Press R for a new seed. Chop / pick / campfire / night are not in yet.

## What exists

- Knowledge harness (mission, decisions, review, biome research)
- `game/` Godot 4.7 project: World, Biome resources, ChunkGenerator, Player, HUD
- Four biome resources; only `coastal_north` has spawn tables
- Headless tests in `game/tests/run.gd`
- GitHub Actions: knowledge files + Godot tests

## Blocked / next

1. Owner installs Godot 4.7.2 Standard, opens the `game` folder, presses Play
2. Slice 0 verbs: pick bakeapple/blueberry, chop fir/spruce, campfire, night
3. PixelLab art from the research list (placeholders are colored rectangles)
4. Owner playtest notes in this file

## Local machine

Surface Pro 6. Install **Godot 4.7.2 Standard** (not .NET) from https://godotengine.org/download/windows/ — Import → select the `game` folder, not the repo root. Do not install Unity.

## Checks

Godot job added. Last local run: not run on this PC; CI is the check.
