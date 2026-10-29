# Status

Updated: 2026-10-28

## Where we are

Godot scaffold is in `game/`. Play opens on a title. The coastal still fills the screen. A green box on top of it offers **New Game** and **Continue**. Buttons light only while the pointer is on them. Continue is three boxes. An empty one says “No save file” and does nothing. A file shows the name and the Costa Rica time. **New Game** claims the first empty box, fades the menu, turns Leif away from the camera, and he walks inland while that coast is built. Nothing is written until the two bars in the top right. The first click asks for a name. Continue on a real file leaves the same way, and he is where he saved. Chopped trees grow back from the seed. A fire that was still burning comes back with the time it had left. If all three files exist, New Game asks which one to overwrite. The old file stays until that run’s first save. A filled box has a small **x** that asks before it deletes that file. Then you are in the **seed-generated** `coastal_north` woods: shore on the south, caribou trail inland, a prebuilt strip north. Hold WASD/arrows to walk; double-tap the same key and hold to jog. Leif has 8-direction idle **and walk** (jog plays the walk cycle faster). **Space** picks bakeapple/blueberry or chops fir/spruce (stone axe already in hand; a smaller ringed stump stays). **E** spends 3 forage to heal **half a heart**. A pick still grants 1. Fewer than 3 refuse, and those berries stay. Full hearts refuse, and a bite never goes past max. There is no hunger bar. **F** spends 3 wood to light a campfire that lasts **one night**, then burns out. Night is **60 seconds** of cold (six hearts if you stand it). Away from a fire, hearts drop **half every 5 seconds**; they heal **half every 10 seconds** when he is warm or it is day. The last half-heart stays. **C** by a fire at dusk or night fades to black, then wakes at dawn — the fire may be ash. Fallen logs block their full length. A **tiny bottom-left minimap** opens a small circle around him, and the trail stays clear. Press R for a new seed (wood and forage stay; the walk on the map does not).

How this serves the mission: the trail does not end at a fake wall, and the corner map is the shore he has learned (discovery). The save keeps that shore, the berries and hearts he is carrying, and a fire that was still burning (discovery, submission). Three berries buy half a heart back, and a fire is so he can sit the night or keep walking (submission, fantasy). The camp is a rest, not the win. Inland is still the spine; “Leif moved” is not the whole point.

PixelLab trial: **7 / 40** generations left. Then 5/day (stack to 20). Paid floor is Pixel Apprentice **$12/mo for 2,000 gens**.

## What exists

- Knowledge harness (mission names MDA fun: sensation / fantasy / discovery / submission now; expression and challenge later)
- Sign-off language runs git in that turn (`.cursor/rules/commit-signoff.mdc`): `commit`, `save`, `all set`, `good`, `done`, `push`
- `docs/research/biomes/river_valley.md` is on `main` (Saint John and inner Miramichi). Owner said it looks right. No spawn tables or art.
- `docs/research/journey.md` is a schematic world map (Newfoundland → rivers south → west). Not in the game.
- `game/` Godot 4.7 project: World, Biome resources, ChunkGenerator, Player, HUD
- Four biome resources; only `coastal_north` has spawn tables. `river_valley.tres` stays empty.
- Headless tests in `game/tests/run.gd` (seed, species, pick, chop, campfire, night, HUD, fog / minimap)
- GitHub Actions: knowledge files + Godot tests
- PixelLab Leif: character `327ed41b-0289-49cb-bcd8-787b17f963ea`, 8 idle rotations + 8-dir walk in `game/art/leif/`
- PixelLab coastal props: fir, spruce, bakeapple, blueberry, stump_fir, stump_spruce in `game/art/coastal_north/` (chunk uses the PNGs; ColorRect fallback if a file is missing). Chop leftover is the 32×32 ringed stump drawn at 0.6. Sphagnum stays the 32×32 cushion, stamped at half size onto one tile.
- Tiny fog-of-war minimap (bottom-left): a 6-tile circle around him, and the trail stays clear; `game/world/fog_map.gd`
- PixelLab Wang floor: water/shore/moss/trail (granite is no longer a floor tile)
- Ground props: granite rocks, sphagnum/needle/branch clutter, fallen fir/spruce (wood; logs block their full length)
- Slice 0 verbs: `game/world/supplies.gd`, `interact.gd`, `campfire.gd`, `day_clock.gd` (E spends 3 forage for half a heart)
- Launch menu: `game/title/title.gd` is the main scene. The coast fills the screen. A green box holds New Game and Continue. New Game fades the box, then Leif walks inland while the strip loads in slices. Three save files live in Godot’s user folder. The save mark is two bars, `game/art/ui/save_floppy.png`, top right. Escape closes the name box when it is open. Otherwise Escape in the woods is not bound (pause is an idea in `docs/IDEAS.md`)
- Bug backlog: `docs/BUGS.md` has no open bugs. Minimap shows too much is fixed: a look opens a 6-tile circle, and the trail stays clear. Sphagnum is larger than Leif is fixed: the cushion is stamped at half size. Shrubs are missing the bottom-right corner is fixed: the next ground tile no longer covers the cushion. Running on a diagonal is choppy is passing and kept for later: the view follows Leif from outside the tree stack.
- Coastal bed: `The First Grove` loops on `coastal_north` (`game/art/coastal_north/the_first_grove.mp3`)

## Blocked / next

Two lanes (see `AGENTS.md`). The minimap circle is signed off. Ringed stumps at 0.6 and the fir/spruce pairing stay signed off.

1. **Next:** press Play on spending 3 forage for half a heart. Not signed off yet. The three save files are signed off: the two bars take the click, the name and Costa Rica time show on Continue, and a fire that was still burning comes back with the time it had left. Chopped trees grow back.
2. **Ideas:** one line each in `docs/IDEAS.md`. Dig in when asked. Not in build.
3. **Cloud + PR:** `river_valley` research is on `main`. Do not start another biome. No spawn tables or art until you ask.
4. **Bug backlog:** no open bugs. Minimap shows too much is fixed: a look opens a 6-tile circle, and the trail stays clear. Sphagnum is larger than Leif is fixed: the cushion is stamped at half size. Shrubs are missing the bottom right corner is fixed. Running on a diagonal is choppy is passing and stays on the list for a later pass.

## Local machine

Surface Pro 6. **Godot 4.7.2 Standard is installed** via winget (`GodotEngine.GodotEngine`). Open the `game` folder, not the repo root. Do not install Unity.

## Checks

Headless tests cover the title menu (New Game, Continue’s three boxes, Escape stepping back), the save (name, Costa Rica time, the walk, a chopped tree growing back, a lit fire coming back with time left, overwrite, delete), eat / refuse-when-full / refuse-when-empty, half-heart cold/heal, 60s night / 6 hearts, log span, fire lifetime, sleep-to-dawn, blocking, the coastal grove track, view-sized fog, scaled ringed stumps, and sphagnum stamped at half size. Owner Play: sleep blink signed off. Corner map signed off. Stumps signed off after a fir/spruce swap. Sphagnum size signed off. Diagonal jog is good enough and kept on the bug list for later. Eating one berry was signed off; spending 3 forage for half a heart is not signed off in Play yet. The title menu and the three save files are signed off in Play. The two bars take the click. A fire that was still burning comes back with the time it had left.
