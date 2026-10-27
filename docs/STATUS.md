# Status

Updated: 2026-10-27

## Where we are

Godot scaffold is in `game/`. One **seed-generated** `coastal_north` chunk: shore on the south, caribou trail inland, fir/spruce/bakeapple/blueberry placeholders. Hold WASD/arrows to walk; double-tap the same key and hold to jog. Leif has 8-direction idle **and walk** (jog plays the walk cycle faster). **Space** picks bakeapple/blueberry or chops fir/spruce (stone axe already in hand). **F** spends 3 wood to light a campfire. Night falls on its own with a dusk fade; dawn eases back to day so it is not a hard cut. The fire is the warm light; hearts are not spent. Press R for a new seed (wood and forage stay).

How this helps him inland: food in hand and a fire so he can keep walking the trail after dark. The camp is not the goal.

PixelLab trial: **14 / 40** generations left. Then 5/day (stack to 20). Paid floor is Pixel Apprentice **$12/mo for 2,000 gens**.

## What exists

- Knowledge harness (mission, decisions, review, biome research)
- `game/` Godot 4.7 project: World, Biome resources, ChunkGenerator, Player, HUD
- Four biome resources; only `coastal_north` has spawn tables
- Headless tests in `game/tests/run.gd` (seed, species, pick, chop, campfire, night, HUD)
- GitHub Actions: knowledge files + Godot tests
- PixelLab Leif: character `327ed41b-0289-49cb-bcd8-787b17f963ea`, 8 idle rotations + 8-dir walk in `game/art/leif/`
- PixelLab coastal props: fir, spruce, bakeapple, blueberry in `game/art/coastal_north/` (chunk uses the PNGs; ColorRect fallback if a file is missing)
- Slice 0 verbs: `game/world/supplies.gd`, `interact.gd`, `campfire.gd`, `day_clock.gd`

## Blocked / next

Two lanes (see `AGENTS.md`). Play signed off. Walk, plants, dawn fade, and the bigger window land on `main` from this PC. PR #1 closes from here — the cloud verbs agent should not merge.

1. **This PC / art:** Walk 8/8 and four plants are in. Next: wire the Wang tiles onto the chunk, then a stump sprite if chop looks empty. Spend trial gens until empty, then owner upgrades.
2. **Cloud / verbs:** Done. Do not start more verb work until this PC pushes and the PR is closed.
3. **Cloud + PR / research (optional, later):** `river_valley` with sources. Owner skims before spawn tables.

## Local machine

Surface Pro 6. **Godot 4.7.2 Standard is installed** via winget (`GodotEngine.GodotEngine`). Open the `game` folder, not the repo root. Do not install Unity.

## Checks

CI green on the verbs PR. Owner Play: pick/chop/fire/night felt good; dawn fade in; plants excellent; asked for a bigger play window (now fills this screen’s 16:9).
