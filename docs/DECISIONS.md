# Decision log

Append only. Newest at the top. Date, decision, why, what we rejected.

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
