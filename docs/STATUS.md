# Status

Updated: 2026-10-27

## Where we are

Godot scaffold is in `game/`. One **seed-generated** `coastal_north` chunk: shore on the south, caribou trail inland, fir/spruce/bakeapple/blueberry placeholders. Walk with WASD; hold a direction ~0.3s to jog. Press R for a new seed. Chop / pick / campfire / night are not in yet.

## What exists

- Knowledge harness (mission, decisions, review, biome research)
- `game/` Godot 4.7 project: World, Biome resources, ChunkGenerator, Player, HUD
- Four biome resources; only `coastal_north` has spawn tables
- Headless tests in `game/tests/run.gd`
- GitHub Actions: knowledge files + Godot tests

## Blocked / next

1. Owner: fully quit and reopen Cursor so PixelLab MCP loads (token is on this PC, not in git)
2. Generate Leif + coastal_north tiles via MCP; swap the colored boxes
3. Slice 0 verbs: pick bakeapple/blueberry, chop fir/spruce, campfire, night

## Local machine

Surface Pro 6. **Godot 4.7.2 Standard is installed** via winget (`GodotEngine.GodotEngine`). Open the `game` folder, not the repo root. Do not install Unity.

## Checks

CI green on the scaffold commit. Godot 4.7.2 launched locally in a play window (`Leif in the Wind (DEBUG)`).
