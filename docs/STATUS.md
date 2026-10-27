# Status

Updated: 2026-10-27

## Where we are

Godot scaffold is in `game/`. One **seed-generated** `coastal_north` chunk: shore on the south, caribou trail inland, fir/spruce/bakeapple/blueberry placeholders. Hold WASD/arrows to walk; double-tap the same key and hold to jog. **E** picks bakeapple/blueberry or chops fir/spruce (stone axe already in hand). **F** spends 3 wood to light a campfire. Night falls on its own; the fire is the warm light; hearts are not spent. Press R for a new seed (wood and forage stay). Leif is an 8-direction PixelLab sprite from the friend photo (idle stills; no walk cycle yet).

How this helps him inland: food in hand and a fire so he can keep walking the trail after dark. The camp is not the goal.

PixelLab trial: **28 / 40** generations left (Leif 10 + two tilesets). Then 5/day (stack to 20). Paid floor is Pixel Apprentice **$12/mo for 2,000 gens**.

## What exists

- Knowledge harness (mission, decisions, review, biome research)
- `game/` Godot 4.7 project: World, Biome resources, ChunkGenerator, Player, HUD
- Four biome resources; only `coastal_north` has spawn tables
- Headless tests in `game/tests/run.gd` (seed, species, pick, chop, campfire, night, HUD)
- GitHub Actions: knowledge files + Godot tests
- PixelLab Leif: character `327ed41b-0289-49cb-bcd8-787b17f963ea`, 8 idle rotations in `game/art/leif/`
- Slice 0 verbs: `game/world/supplies.gd`, `interact.gd`, `campfire.gd`, `day_clock.gd`

## Blocked / next

Two lanes (see `AGENTS.md`). Push this PC first so a cloud agent is not on stale `main`.

1. **This PC / art:** Owner look at Leif vs `art-inspo/viking-inspo.jpeg`. Then walk cycle (8 gens), remaining tiles, fir/spruce, bakeapple/blueberry, swap ColorRects. Verbs already read `species` / `kind` on the boxes.
2. **Cloud + PR / verbs:** Pick, chop, campfire, night, and HUD counts are in this branch. Owner still needs to press Play (feel gate). Headless tests cover the counts and the night rules; the warm pool of light was not looked at in a window.
3. **Cloud + PR / research (optional, later):** `river_valley` with sources. Owner skims before spawn tables.

## Local machine

Surface Pro 6. **Godot 4.7.2 Standard is installed** via winget (`GodotEngine.GodotEngine`). Open the `game` folder, not the repo root. Do not install Unity.

## Checks

CI green on the scaffold commit. Godot 4.7.2 launched locally in a play window (`Leif in the Wind (DEBUG)`) before these verbs.

Slice 0 verbs: headless tests passed on Godot 4.7.2 (`godot --headless --path game -s res://tests/run.gd`, all checks OK). A scripted window also drew the shore, a day campfire, and the night pool. The cloud agent did not press Play, so the feel gate is not signed off. Owner: pull, open `game/`, walk inland, E a bush and a fir or spruce, F a fire, wait for night.
