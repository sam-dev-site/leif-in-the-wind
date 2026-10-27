# Status

Updated: 2026-10-27

## Where we are

Godot scaffold is in `game/`. One **seed-generated** `coastal_north` chunk: shore on the south, caribou trail inland, fir/spruce/bakeapple/blueberry placeholders. Hold WASD/arrows to walk; double-tap the same key and hold to jog. Press R for a new seed. Leif is an 8-direction PixelLab sprite from the friend photo (idle stills; no walk cycle yet). Chop / pick / campfire / night are not in yet.

PixelLab trial: **28 / 40** generations left (Leif 10 + two tilesets). Then 5/day (stack to 20). Paid floor is Pixel Apprentice **$12/mo for 2,000 gens**.

## What exists

- Knowledge harness (mission, decisions, review, biome research)
- `game/` Godot 4.7 project: World, Biome resources, ChunkGenerator, Player, HUD
- Four biome resources; only `coastal_north` has spawn tables
- Headless tests in `game/tests/run.gd`
- GitHub Actions: knowledge files + Godot tests
- PixelLab Leif: character `327ed41b-0289-49cb-bcd8-787b17f963ea`, 8 idle rotations in `game/art/leif/`

## Blocked / next

Two lanes (see `AGENTS.md`). Push this PC first so a cloud agent is not on stale `main`.

1. **This PC / art:** Owner look at Leif vs `art-inspo/viking-inspo.jpeg`. Then walk cycle (8 gens), remaining tiles, fir/spruce, bakeapple/blueberry, swap ColorRects.
2. **Cloud + PR / verbs:** Pick, chop, campfire, night, HUD counts — against current boxes and `species` meta. Do not call PixelLab.
3. **Cloud + PR / research (optional, later):** `river_valley` with sources. Owner skims before spawn tables.

## Local machine

Surface Pro 6. **Godot 4.7.2 Standard is installed** via winget (`GodotEngine.GodotEngine`). Open the `game` folder, not the repo root. Do not install Unity.

## Checks

CI green on the scaffold commit. Godot 4.7.2 launched locally in a play window (`Leif in the Wind (DEBUG)`).
