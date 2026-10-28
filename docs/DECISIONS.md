# Decision log

Append only. Newest at the top. Date, decision, why, what we rejected.

## 2026-10-27 — Hunger is planned; it stays off this Play

**Decision:** Hunger has a plan in `docs/HUNGER.md` and stays later. Slice 0 forage is still carried, not eaten: bakeapple and blueberry only. Cranberry stays in the research file and off the ground. When hunger comes, it must not spend the same night cold or sleep already paid for. Sitting by a fire stays valid play.

**Why:** Cold, sleep, and fires that burn one night just signed off. Another drain now would hide which change hurt. The plan is written so a later cut does not invent a hunger spreadsheet, death, or plants from another biome.

**Rejected:** Implementing hunger in this slice. A bar that punishes lingering. Eating as the unlock for the river valley. Death at 0. Grapes, butternut, or cranberry as food on this coast.

## 2026-10-27 — First grove loops on coastal_north

**Decision:** The first biome bed is `The First Grove` (`game/art/coastal_north/the_first_grove.mp3`), about three minutes, **looped**. It lives on the `Biome` resource as `music_path`, not hardcoded to World, so a later biome can bring its own track. Pressing R does not restart it. Sleep does not stop it.

**Why:** Owner brought the soundtrack for the first woods. Sensation is a current aesthetic. Music as biome data keeps the continent from becoming a one-off Level1 playlist.

**Rejected:** A global playlist. Restarting the track on every new seed. Silence during sleep.

## 2026-10-27 — Longer night, log spans, fires burn out

**Decision:** The cold night is **60 seconds** (~6 hearts at ½ / 5s). Dawn is still 10 seconds after that. A 3-heart newbie cannot stand the night; more hearts come later. Fallen logs block their full length (the 64px fir log is five tiles, not one). A campfire burns **one night** of wood and goes out. Sleeping to dawn spends that same time, so a fire you slept through is ash.

**Why:** Owner could almost stand the old night. They asked for ~1.5× / six hearts of cold, ends of logs that actually stop you, and fires that do not last forever. Sleep blink stays as signed off.

**Rejected:** Death at 0 this slice. Fires that persist across seeds. Changing the log art.

## 2026-10-27 — Half-heart cold and heal; sleep blinks; occupancy cache

**Decision:** Night away from a fire spends **half a heart every 5 seconds**. Day or fire warmth heals **half a heart every 10 seconds**. The last half-heart stays (no death this slice). **C** sleep fades to black, holds a blink, then fades in on dawn so the woods lighten as he wakes. Walk-block, occupancy, usable props, and campfires are occupancy maps — not a child scan every footstep or Space.

**Why:** 18 seconds per full heart was too generous. Owner asked for slow natural heal and a lights-out blink on sleep. Run + Space-spam felt like the camera lagged the player because each move frame walked every sprite in the chunk.

**Rejected:** Death at 0. Camera smoothing (that would sit further behind). Skills in this cut.

## 2026-10-27 — Rocks and logs block; night is cold; C sleeps at a fire. Skills wait.

**Decision:** Standing trees, granite rocks, fallen logs, and campfires **block walking**. Berry bushes and loose branches do not. Night away from a fire spends a heart every 18 seconds; the last heart stays (no death this slice). Within about 3.5 tiles of a campfire he is warm. **C** at dusk or night by a fire skips to dawn. Woodcutting and fire-making **skills** are planned in `docs/SKILLS.md` and stay off this Play. Today’s 1-tap / 3 wood / sure fire is the future mid-skill feel.

**Why:** Owner signed off the three next steps and asked when skills should land. Challenge is a later aesthetic. Mixing fail-chance and multi-tap with cold and blocking would hide which change hurt.

**Rejected:** Hunger that ticks while exploring. Dying at 0 hearts. Adding woodcutting XP in the same cut. Pushing rocks (still later).

## 2026-10-27 — Prebuild a coastal strip; bake the floor; do not generate while walking

**Decision:** Slice 0 is a **prebuilt** `coastal_north` strip (3 chunks east-west, 4 north from the landing). It is still seed-generated. It is not generated while Leif walks. Each chunk’s moss/shore/trail and the sphagnum/needle litter are **one baked image**. Only trees, forage, rocks, fallen logs, and clearable branches stay as nodes. Far chunks hide. Crossing a seam only reparents him. The far north of the strip is a quiet edge until we grow the continent later.

**Why:** Owner Play: streaming one chunk per frame made the whole walk choppy; the big window hitching on every footstep; Space lagged; the seam still hitched. They asked for a seamless forest, not live generation.

**Rejected:** Building woods during the walk. Redrawing 2,300 Wang tiles every frame. Keeping moss cushions as nodes.

## 2026-10-27 — Fun is sensation, fantasy, discovery, submission — not only inland motion

**Decision:** The mission now names Hunicke / LeBlanc / Zubek’s MDA aesthetics. Current fun: **sensation**, **fantasy**, **discovery**, **submission**. Later: **expression** (house, town, crafting) and **challenge** (skill trees that raise efficiency or unlock better output). Narrative-as-plot and fellowship stay out. Features are judged by whether the woods are worth being in, not by whether Leif’s coordinate changed. Sitting by a fire is valid play. The continent and inland pull stay; they are the discovery/fantasy spine, not the only pass.

**Why:** Owner: the goal is not simply “get Leif moving.” They want exploration and chilling out. The old review question (*how does this help Leif go inland?*) treated motion as the win and made lingering look like waste.

**Rejected:** Treating inland travel as the only mission test. Adding town-building or mastery trees in this slice. Turning the camp into a win condition. Authored plot or multiplayer as the hook.

## 2026-10-27 — Stream chunks ahead; fill the Game view by keeping aspect

**Decision:** Neighbor woods generate **ahead of the walk**, one chunk per frame, tiles first, then a few props per frame. Wang sheets and plant textures load once and are reused. Crossing a seam does not build a 3×3 of sprites on the spot. Walk-blocking uses a cheap ground peek if that chunk is not ready. The editor Game view for this project is **Keep Aspect Ratio** so the 480×270 picture fills the panel instead of sitting at Fixed Size in a black frame.

**Why:** Owner Play: 2–3 second hitch at the chunk line, and the live view was a postage stamp at 1.0× speed in a 1368×770 Game tab.

**Rejected:** Building the whole next ring when he steps over the line. Making the viewport itself bigger (that shows more world, not a bigger picture).

## 2026-10-27 — The coast is a strip of chunks; walking north loads more woods

**Decision:** Slice 0 is still `coastal_north`, but it is no longer one boxed chunk. The world keeps a 3×3 of seed-generated chunks around Leif. Sea is south of the whole shore (`chunk_y > 0` is water; every `chunk_y == 0` has a south beach). The caribou trail continues on `chunk_x == 0` into the north woods. Distant chunks unload; fires on them go with the old ground, same as **R**. Player stays a child of the chunk he stands on so trees still Y-sort. No new biome.

**Why:** The trail said inland, then the north edge counted as water. That fought the mission. Streaming more coastal woods is how he actually goes inland.

**Rejected:** A second painted level. Loading `river_valley`. Keeping the camera locked to chunk (0,0). Treating east/west of the landing as more ocean.

## 2026-10-27 — Long aim is west; world map is a later artifact, not a new biome pass

**Decision:** Slice 0 stays `coastal_north`. The long walk is: leave Newfoundland, go south using the rivers, then across the later United States toward the Pacific. That is compressed journey length, same as the mission already says. A **world map** (even a schematic one) is on the enhancement list so the continent stays visible. It is not baked into the chunk. Do not research more biomes until this shore is the game we mean to keep playing.

**Why:** Owner Play: river-valley research is right, but they do not want more-more-more biomes right now. They still want the west-coast aim written down so later work has a spine.

**Rejected:** Starting `inland_plains` or west-coast species lists. Painting a Level1 overworld. Treating the river-valley draft as the next playable land.

## 2026-10-27 — Fallen branches clear for 0.5 wood; the trail is a game path

**Decision:** Space on a piney fallen branch (`kind=branch`, species `fir_branch`) removes it and adds **0.5 wood**. Standing trees and fallen logs still add **3**. Sphagnum and needles stay scenery. Wood is a tenth-rounded float so two branches make one fire-log. The caribou trail is **one tile wide**, with moss gaps, so it reads as an animal path and not a road.

**Why:** Owner Play: the woods felt cluttered, and those branches should be clearable firewood. The two-tile trail looked too established.

**Rejected:** Making moss or needles firewood. Changing tree/log pay. Widening the trail. Blocking walk with branches.

## 2026-10-27 — Granite is a rock object; floor clutter is boreal; obstacles later

**Decision:** Big rocks are no longer painted into Wang tiles. The generator scatters **granite** props (`kind=rock`) on moss/peat. They occupy a tile (no fire there) but do **not** block walking and do **not** react to Space. Forest-floor clutter is sphagnum cushions, fir/spruce needles, and short fallen branches — not deciduous leaves. Clutter does not occupy. Rare **fallen** fir/spruce logs are choppable for the same wood as a standing tree and leave no stump. Player collision, pushing rocks, and seasonality are later work.

**Why:** Owner Play: baked granite looked like something you should move; repeating moss dots felt sterile; they asked for biome-fitting litter and named fallen trees as wood sources.

**Rejected:** Maple/oak leaves. Making rocks or fallen logs block the player in this pass. Baking boulders back into the moss sheet. Seasonality now.

## 2026-10-27 — Wire the PixelLab Wang sheets; do not buy an itch floor yet

**Decision:** The chunk draws the four existing PixelLab tileset15 sheets (`water_shore`, `shore_moss`, `moss_trail`, `moss_granite`) with 4-corner Wang matching. Peat uses the moss tiles. Off-map south is water; north stays moss so the inland edge is not a fake beach. ColorRects stay as fallback. Recolor later with `pixelart_workbench` if Play says a sheet is too muddy. Itch packs stay a backup.

**Why:** Owner asked to wire what we have. Those sheets already say moss, peat, granite, trail, and shore. A new generate or an itch grass pack would spend gens or fight Vinland ground.

**Rejected:** Regenerating the floor. Downloading an itch pack first. Treating off-map as water on every edge.

## 2026-10-27 — `river_valley` is the Saint John and inner Miramichi, not a generic oak wood

**Decision:** The inland river-valley biome is the temperate deciduous valley of the Saint John River and the inner Southwest Miramichi (about 46–47°N), in the 11th century. Signature plants are the hardwoods coastal North saved for inland: butternut, riverbank grape, basswood, elm, beech, ash, plus maple, oak, and hemlock. The ground is intervale silt over clay and clay loam, not peat and granite. The main river is a barrier (raft or timber bridge). Intervale trails are white-tailed deer. Moose are native here. Coyote is not. Caribou stay the coastal trail, not this one. Full list and sources: `docs/research/biomes/river_valley.md`. No spawn table, art, or PixelLab prompt until the owner skims that file.

**Why:** Mission row 2 is this valley. Wallace’s butternuts and grapes from L’Anse aux Meadows point here, not at the Newfoundland shore. Copying the coastal species list, or inventing a generic forest, would erase the first biome change.

**Rejected:** A generic oak-maple-birch list with no sources. Treating New Brunswick moose like Newfoundland’s introduced moose. Letting coyote or caribou define the valley. Filling `river_valley.tres` in the same pass as the research.

## 2026-10-27 — Play window fills the largest 16:9 that fits; F11 fullscreen

**Decision:** The game stays **480×270**. The play window is resized at launch to the largest 16:9 rectangle on the usable screen, with `viewport` stretch, `aspect=keep`, and **fractional** scale. **F11** toggles fullscreen. This Surface’s desktop is 1368×912; integer 3× needs 1440×810, so integer scale was stuck at 2× (960×540) with black bars in a 1280×720 window.

**Why:** Owner Play: plants look excellent; dragging the window only grew black bars.

**Rejected:** Changing the viewport. Camera zoom (that shows less woods). Non-uniform stretch. Leaving integer scale as the playtest default on this 3:2 laptop.

## 2026-10-27 — Slice 0 plants are PixelLab map objects, one generation each

**Decision:** Fir, spruce, bakeapple, and blueberry are still sprites from `create_map_object` (high top-down, transparent background). Files are species-named: `tree_fir.png`, `tree_spruce.png`, `forage_bakeapple.png`, `forage_blueberry.png` in `art/biomes/coastal_north/` and `game/art/coastal_north/`. Chunk loads those PNGs and keeps ColorRect fallback. Stumps stay boxes for now.

**Why:** Owner said go on the art lane. Pro Flash objects quote 5 generations for one 32×48 still. Map objects cost 1. Trial had 18 left; these four used 4.

**Rejected:** Pro Flash objects for still plants. Generic `tree1` filenames. Regenerating the first fir because it reads a bit like a Christmas tree — owner Play decides.

## 2026-10-27 — Dawn fades like dusk; night does not snap to day

**Decision:** Night still lasts 40 seconds. The last 10 of those are **dawn**: darkness eases from 1 to 0, and the campfire pool eases out with it. Dusk already eases in over the last 10 seconds of day. A new walk still starts in full daylight.

**Why:** Owner Play: pick/chop/fire felt good; night-to-day was a hard cutoff.

**Rejected:** Keeping the wrap from full night to full day. Adding extra cycle time. Starting the game in dawn.

## 2026-10-27 — Space picks and chops; F still lights the fire

**Decision:** The main action is **Space**. It picks bakeapple/blueberry and chops fir/spruce, same reach and facing as before. **F** still spends wood to light a campfire. **R** still reseeds.

**Why:** The owner asked for Space as the gather/chop button while playing. F already reads as fire, so that key stays.

**Rejected:** Keeping E. Using Space for the campfire too.

## 2026-10-27 — Slice 0 verbs: E picks or chops, F lights a fire, night does not freeze

**Decision:** Press **E** on the tile Leif is standing on, or a neighboring tile he is facing. Forage on the biome resource (`bakeapple`, `blueberry`) adds 1 forage and the bush is removed. Trees on that resource (`fir`, `spruce`) add 3 wood, the tree node is removed, and a stump marks the spot. The stone axe is already in hand: no crafting, no durability. Press **F** to spend 3 wood and place a lit campfire one tile ahead (not on water, not on a prop). One fir or spruce pays for one fire. More wood can light more fires along the trail. A day is 50 seconds, the last 10 of them dusk, then 40 seconds of night, then dawn. Night is a cold `CanvasModulate`. Each campfire is a warm `PointLight2D` that is off in full daylight and fades in with the dark, so the day ground stays readable and the fire is the night light. The camera stays inside the chunk, because the window clear color is not shaded by that night tint. Hearts stay at 3. Forage is carried, not eaten. **R** reseeds the coast and keeps wood, forage, and the clock; fires were on the old ground and go with it. Verbs read `Biome.tree_species` / `forage_species` and prop meta `kind` / `species`. They do not live on the player script.

**Why:** Berries in hand and a fire on the ground let Leif see the caribou trail and keep walking inland after dark. The camp is a light along the way, not the destination. Hunger and freezing would stop the walk before those systems are the slice. A later biome adds species on its resource; the player script stays the walk.

**Rejected:** Eating berries in slice 0. Freezing damage. Crafting the axe. A free campfire. E placing a fire whenever the tile ahead is empty (too easy to mis-light). A fire halo that washes out the day. Hard-coding coastal species inside the verb instead of the biome list. Cranberry and tamarack in the verb — they are in the research doc and stay off the slice 0 spawn list until that list changes. PixelLab props. Editing walk/run.

## 2026-10-27 — Two lanes: this PC does PixelLab; cloud does verbs/research

**Decision:** We do not back up. The world exists; art is replacing placeholders, not starting the game. While this PC generates Leif/tiles/props, a **cloud agent + PR** builds pick/chop/campfire/night against the colored boxes and `species` metadata. A second cloud PR can research `river_valley`. Lanes are in `AGENTS.md`. Push local work before the cloud agent branches.

**Why:** Owner asked for this harness. PixelLab’s token only lives here. Verbs do not need finished sprites. Research never needed this laptop.

**Rejected:** Pausing the continent until the forest looks pretty. One chat doing art and verbs in series. A cloud agent calling PixelLab (it cannot).

## 2026-10-27 — Double-tap a move key to run; hold is always walk

**Decision:** Hold WASD/arrows = walk (70). Double-tap the **same** key within 0.3s and keep holding it = jog (100). Releasing that key returns to walk. Diagonals stay a run only while the double-tapped key is still down.

**Why:** Owner clarified the first playtest request: hold-without-double-tap must never speed up.

**Rejected:** Hold-to-jog after 0.28s (the previous rule). Toggle run. Sprint-scale speed.

## 2026-10-27 — PixelLab for generated sprites; Cursor for the world

**Decision:** Keep PixelLab for characters, Wang tiles, and animations. Cursor writes Godot, biomes, and tests. `pixelart_workbench` (free, no generations) is how we poke individual pixels after a generate. Do not ask a Cursor agent to invent 8-dir sheets or autotiles from scratch.

**Why:** Photo-to-8-dir and chained tilesets are PixelLab’s job. A Cursor agent drawing pixels by hand is slow, inconsistent, and would burn chat tokens on this Surface Pro. World/seed/chunk is already ours.

**Rejected:** Replacing PixelLab with Cursor image tools. Paying Architect ($50) before we have outgrown Apprentice.

## 2026-10-27 — Leif is the friend in viking clothes, PixelLab Pro 8-dir

**Decision:** First Leif sprite is PixelLab `create_character` mode=pro, 64px, high top-down, 8 directions, from `art-inspo/viking-inspo.jpeg` (head crop uploaded as `upload:a56525a8-...`). Character id `327ed41b-0289-49cb-bcd8-787b17f963ea`. PNGs live in `art/characters/leif/` and `game/art/leif/`. Godot draws him at 0.5 scale so he is about two tiles tall.

**Why:** Owner asked for the character based on that photo. Pro is the mode that takes a concept photo. 64px was too tall on 16px tiles, so we scale in-engine rather than regenerating.

**Rejected:** Ignoring the photo and inventing a generic Norseman. Sending the full 1600px JPEG as inline base64 (MCP truncates it). Regenerating before the owner sees the first pass.

## 2026-10-27 — PixelLab MCP in the project, token stays on the PC

**Decision:** `.cursor/mcp.json` points at `https://api.pixellab.ai/mcp` with `Authorization: Bearer ${env:PIXELLAB_API_TOKEN}`. The owner sets that env var locally. Setup notes live in `docs/PIXELAB.md`.

**Why:** We generate Leif and tiles from Cursor against researched species, without putting a secret in GitHub.

**Rejected:** Committing a real token. Calling PixelLab’s REST API from scripts as the default. Blender/Meshy.

## 2026-10-27 — Hold a direction to jog, do not sprint

**Decision:** First moment of WASD/arrows is a walk (70). After holding any move key ~0.28s, speed becomes a jog (100). Releasing resets to walk. Same in every direction.

**Why:** First playtest: walk felt a bit slow. Owner asked for `w-wwwwww` hold-to-run, “a bit” faster not a sprint.

**Rejected:** Toggle run. Double-tap. A large speed boost.

## 2026-10-27 — Tiny headless test runner, not GUT (yet)

**Decision:** Tests are `game/tests/run.gd` run with `godot --headless -s res://tests/run.gd`. GitHub Actions installs Godot 4.7.2 and runs them. GUT is not in the repo yet.

**Why:** Zero addons, works in CI, enough for seed/biome/species checks. We can switch to GUT when tests get awkward.

**Rejected:** Making this Surface Pro run the tests. Shipping a Level1.tscn with no generator.

## 2026-10-27 — World / chunk / biome data from day one

**Decision:** Playable land is `ChunkGenerator` + `Biome` resources. Slice 0 loads chunk (0,0) as `coastal_north`. Other biomes exist as empty resources. Water is south; inland is −Y (north).

**Why:** The continent dies if the first map is a unique painted scene.

**Rejected:** Hand-placed clearing. GUT addon on day one.

## 2026-10-27 — Coastal North trails are caribou, not white-tailed deer

**Decision:** On `coastal_north`, “deer trails” in the mission are **woodland caribou** trails. White-tailed deer, moose, coyote, and snowshoe hare stay out of this biome.

**Why:** Insular Newfoundland’s native ungulate is caribou. Moose (1878/1904) and coyote (1985) are later. Accuracy is a pillar.

**Rejected:** Generic Stardew deer as the Vinland path-makers.

## 2026-10-27 — CI checks knowledge files only until Godot exists

**Decision:** GitHub Actions `check` verifies the knowledge harness files. Headless Godot/GUT is not in CI until `game/project.godot` exists.

**Why:** First run failed with zero jobs (job-level `hashFiles` is a bad fit). An empty Godot job should not break the harness.

**Rejected:** Skipping CI until a game binary exists. Running Godot on this Surface Pro as the test machine.

## 2026-10-27 — GitHub is home; this PC is a thin client

**Decision:** Canonical repo is https://github.com/sam-dev-site/leif-in-the-wind. Cloud agents, hooks, and Actions do research, code, tests, and review. The Surface Pro is for `git pull` and Play.

**Why:** 8 GB Intel UHD 620 cannot be the factory. Chat memory compresses; GitHub does not.

**Rejected:** Keeping the only copy in `Projects-Local/vikings`. Creating a second Cursor-hosted repo. Unity/Unreal on this laptop.

**Note:** The GitHub repo was created empty and **public**. We did not change visibility. Switch to private if that was accidental.

## 2026-10-27 — Knowledge harness over chat memory

**Decision:** `AGENTS.md`, `docs/MISSION.md`, this log, `docs/STATUS.md`, biome research files, Cursor rules, and project hooks are the source of truth. Lasting choices must be written here in the same session.

**Why:** Context compaction loses decisions. The owner already uses this pattern on Just Keep Talking.

**Rejected:** Treating a slice spec as the whole game. Treating this conversation as the archive.

## 2026-10-27 — Godot 4, not Unity; 2D pixel, not Blender/Meshy

**Decision:** Engine is Godot 4.7.x Standard (GDScript, Compatibility renderer). Art is 16×16 pixel, PixelLab then Aseprite. No Unity, Unreal, Blender, or Meshy.

**Why:** Top-down 16-bit survival matches the forest screenshot. This laptop cannot carry Unity/Unreal. 3D tools do not serve a 2D pixel game.

**Rejected:** Phaser/browser-first (browser was only “can I open it in Chrome,” not the game). RuneScape click-to-move / MMO.

## 2026-10-27 — Single-player generated world

**Decision:** Single-player only. World is seed + chunks + biome-at-position. Slice 0 is one generated `coastal_north` chunk, not a unique Level1 scene.

**Why:** Other players would 10x the first game. Procgen and biomes are the mission; delaying them until “later” is how they die.

**Rejected:** Multiplayer from day one. Hand-painted diorama with no world system.

## 2026-10-27 — Biome species must be researched

**Decision:** Each biome gets `docs/research/biomes/<id>.md` with sources before art or spawn tables. Agents must not invent flora or fauna.

**Why:** The land should be accurate. Vinland is a real ecoregion. The walk inland is compressed; the plants are not random.

**Rejected:** Generic “forest trees” and “berries.”
