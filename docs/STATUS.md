# Status

Updated: 2026-10-27

## Where we are

Godot scaffold is in `game/`. A **seed-generated** `coastal_north` coast: shore on the south, caribou trail inland, a prebuilt strip north. Hold WASD/arrows to walk; double-tap the same key and hold to jog. Leif has 8-direction idle **and walk** (jog plays the walk cycle faster). **Space** picks bakeapple/blueberry or chops fir/spruce (stone axe already in hand). **F** spends 3 wood to light a campfire that lasts **one night**, then burns out. Night is **60 seconds** of cold (six hearts if you stand it). Away from a fire, hearts drop **half every 5 seconds**; they heal **half every 10 seconds** when he is warm or it is day. The last half-heart stays. **C** by a fire at dusk or night fades to black, then wakes at dawn — the fire may be ash. Fallen logs block their full length. Press R for a new seed (wood and forage stay).

How this serves the mission: the trail does not end at a fake wall (discovery). Food and a fire are so he can sit the night or keep walking (sensation, submission). The camp is a rest, not the win. Inland is still the spine; “Leif moved” is not the whole point. `docs/SFX.md` is the sensation list for sounds still to record. Play still has only the grove bed.

PixelLab trial: **9 / 40** generations left. Then 5/day (stack to 20). Paid floor is Pixel Apprentice **$12/mo for 2,000 gens**.

## What exists

- Knowledge harness (mission names MDA fun: sensation / fantasy / discovery / submission now; expression and challenge later)
- `docs/research/biomes/river_valley.md` is on `main` (Saint John and inner Miramichi). Owner said it looks right. No spawn tables or art.
- `docs/research/journey.md` is a schematic world map (Newfoundland → rivers south → west). Not in the game.
- `game/` Godot 4.7 project: World, Biome resources, ChunkGenerator, Player, HUD
- Four biome resources; only `coastal_north` has spawn tables. `river_valley.tres` stays empty.
- Headless tests in `game/tests/run.gd` (seed, species, pick, chop, campfire, night, HUD)
- GitHub Actions: knowledge files + Godot tests
- PixelLab Leif: character `327ed41b-0289-49cb-bcd8-787b17f963ea`, 8 idle rotations + 8-dir walk in `game/art/leif/`
- PixelLab coastal props: fir, spruce, bakeapple, blueberry in `game/art/coastal_north/` (chunk uses the PNGs; ColorRect fallback if a file is missing)
- PixelLab Wang floor: water/shore/moss/trail (granite is no longer a floor tile)
- Ground props: granite rocks, sphagnum/needle/branch clutter, fallen fir/spruce (wood; logs block their full length)
- Slice 0 verbs: `game/world/supplies.gd`, `interact.gd`, `campfire.gd`, `day_clock.gd`
- Coastal bed: `The First Grove` loops on `coastal_north` (`game/art/coastal_north/the_first_grove.mp3`)
- Sound plan, not in Play yet: `docs/SFX.md` (steps, pick, chop, branch, campfire, night wind, sleep blink, shore wind). The grove stays the only music.

## Blocked / next

Two lanes (see `AGENTS.md`). Play cut is on `main`: longer night, log spans, fires that burn out, sleep blink, half-hearts.

1. **This PC / play:** Reload from disk, F5. The First Grove should start with the woods and loop. Confirm night, log ends, and a fire dying after one night.
2. **This PC / art:** Stump sprite if chop looks empty. Trial gens until empty, then owner upgrades.
3. **Later / enhancements:** Grow the strip past the quiet edge. Push rocks. Seasonality. A world map he can hold. More hearts. Skills: see `docs/SKILLS.md`.
4. **Cloud + PR:** `river_valley` research is on `main`. Do not start another biome. No spawn tables or art until you ask.
5. **Sounds:** Record or find the files named in `docs/SFX.md`. Leave The First Grove looping. No second music track. Wire them in a later pass.

## Local machine

Surface Pro 6. **Godot 4.7.2 Standard is installed** via winget (`GodotEngine.GodotEngine`). Open the `game` folder, not the repo root. Do not install Unity.

## Checks

Headless tests cover half-heart cold/heal, 60s night / 6 hearts, log span, fire lifetime, sleep-to-dawn, blocking, and the coastal grove track. Owner Play: sleep blink signed off; they asked for a longer night, log ends that block, and fires that burn out. The sound list is docs only; this pass adds no audio and does not change `game/`.
