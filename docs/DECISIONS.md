# Decision log

Append only. Newest at the top. Date, decision, why, what we rejected.

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
