# Status

Updated: 2026-10-28

## Where we are

Godot scaffold is in `game/`. A **seed-generated** `coastal_north` coast: shore on the south, caribou trail inland, a prebuilt strip north. Hold WASD/arrows to walk; double-tap the same key and hold to jog. Leif has 8-direction idle **and walk** (jog plays the walk cycle faster). **Space** picks bakeapple/blueberry or chops fir/spruce (stone axe already in hand; a smaller ringed stump stays). **E** eats 1 forage already in hand and heals **half a heart**. Empty hands refuse. Full hearts refuse, and a bite never goes past max. There is no hunger bar. **F** spends 3 wood to light a campfire that lasts **one night**, then burns out. Night is **60 seconds** of cold (six hearts if you stand it). Away from a fire, hearts drop **half every 5 seconds**; they heal **half every 10 seconds** when he is warm or it is day. The last half-heart stays. **C** by a fire at dusk or night fades to black, then wakes at dawn — the fire may be ash. Fallen logs block their full length. A **tiny bottom-left minimap** remembers tiles that have been on screen. Press R for a new seed (wood and forage stay; the walk on the map does not).

How this serves the mission: the trail does not end at a fake wall, and the corner map is the shore he has learned (discovery). A berry in hand buys half a heart back, and a fire is so he can sit the night or keep walking (submission, fantasy). The camp is a rest, not the win. Inland is still the spine; “Leif moved” is not the whole point.

PixelLab trial: **7 / 40** generations left. Then 5/day (stack to 20). Paid floor is Pixel Apprentice **$12/mo for 2,000 gens**.

## What exists

- Knowledge harness (mission names MDA fun: sensation / fantasy / discovery / submission now; expression and challenge later)
- `docs/research/biomes/river_valley.md` is on `main` (Saint John and inner Miramichi). Owner said it looks right. No spawn tables or art.
- `docs/research/journey.md` is a schematic world map (Newfoundland → rivers south → west). Not in the game.
- `game/` Godot 4.7 project: World, Biome resources, ChunkGenerator, Player, HUD
- Four biome resources; only `coastal_north` has spawn tables. `river_valley.tres` stays empty.
- Headless tests in `game/tests/run.gd` (seed, species, pick, chop, campfire, night, HUD, fog / minimap)
- GitHub Actions: knowledge files + Godot tests
- PixelLab Leif: character `327ed41b-0289-49cb-bcd8-787b17f963ea`, 8 idle rotations + 8-dir walk in `game/art/leif/`
- PixelLab coastal props: fir, spruce, bakeapple, blueberry, stump_fir, stump_spruce in `game/art/coastal_north/` (chunk uses the PNGs; ColorRect fallback if a file is missing). Chop leftover is the 32×32 ringed stump drawn at 0.6.
- Tiny fog-of-war minimap (bottom-left): opens the 480×270 play view; `game/world/fog_map.gd`
- PixelLab Wang floor: water/shore/moss/trail (granite is no longer a floor tile)
- Ground props: granite rocks, sphagnum/needle/branch clutter, fallen fir/spruce (wood; logs block their full length)
- Slice 0 verbs: `game/world/supplies.gd`, `interact.gd`, `campfire.gd`, `day_clock.gd` (E eats one forage for half a heart)
- Coastal bed: `The First Grove` loops on `coastal_north` (`game/art/coastal_north/the_first_grove.mp3`)

## Blocked / next

Two lanes (see `AGENTS.md`). This PC cut is signed off: view-sized fog, ringed stumps at 0.6, then fir/spruce pairing swapped.

1. **Ideas, not in build:** Home screen, profile, death, skills, animals, NPCs, and a longer coast are separate open ideas in `docs/IDEAS.md`. Each one gets its own conversation before anyone builds it.
2. **Also still ideas:** Push rocks. Seasonality. More hearts. A hunger meter (eating a berry is in; a ticking bar is not). Skills sketch: `docs/SKILLS.md`.
3. **Cloud + PR:** `river_valley` research is on `main`. Do not start another biome. No spawn tables or art until you ask.

## Local machine

Surface Pro 6. **Godot 4.7.2 Standard is installed** via winget (`GodotEngine.GodotEngine`). Open the `game` folder, not the repo root. Do not install Unity.

## Checks

Headless tests cover eat / refuse-when-full / refuse-when-empty, half-heart cold/heal, 60s night / 6 hearts, log span, fire lifetime, sleep-to-dawn, blocking, the coastal grove track, view-sized fog, and scaled ringed stumps. Owner Play: sleep blink signed off. Corner map signed off. Stumps signed off after a fir/spruce swap. Eating a berry signed off (2026-10-28).
