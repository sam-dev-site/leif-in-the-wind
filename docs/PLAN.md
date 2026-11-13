# Implementation plan

Status: **locked 2026-11-12.** The rules are `docs/LOOP.md`. This file is the order. One phase is one pull request. Do not skip ahead. Do not combine a research phase with a spawn phase. Do not combine two lands.

The open night Play (pitch, rime, the bed, the slower cold) stays its own branch until the owner signs it off. Later phases keep that coast behavior. They do not retune it.

## How an agent takes a phase

1. Read `docs/MISSION.md`, `docs/DECISIONS.md`, `docs/STATUS.md`, `docs/LOOP.md`, and this file. Read the biome research for any land the phase touches.
2. Take the first phase whose **Done when** is not already true on `main`.
3. Branch `cursor/<phase>-<suffix>`. Cloud never opens the Godot editor and never calls PixelLab.
4. Code and headless tests for that phase only. Species, weights, costs, and hints come from `docs/LOOP.md`. If a number is missing there, stop and add the question to `docs/IDEAS.md`. Do not invent it.
5. A picture that ships as a box gets a row in `docs/ART.md` in that same PR.
6. Append a short note to `docs/DECISIONS.md` only if the phase had to choose something `docs/LOOP.md` left open. Do not relitigate the lock.
7. Update `docs/STATUS.md`. A player-visible phase says **ready for Play**, not signed off. A docs-only or invisible phase says it is not a Play.
8. Wait for Actions. Gates 1–5 in `docs/REVIEW.md`. Gate 6 is the owner.

## Phase A — Lock

**This PR.** Docs only. No gameplay change.

**Done when:** `docs/LOOP.md` and `docs/PLAN.md` are on the branch, the knowledge check requires them, and `docs/IDEAS.md` points locked slices at the loop.

## Phase B — Band table

Invisible in Play. The coast strip still generates, and only the coast strip.

- `BiomeCatalog.biome_id_at` reads the `chunk_y` bands in `docs/LOOP.md`.
- `chunk_y` 0 through −3 stays `coastal_north`, including every tile of the current strip (`chunk_x` −1..1).
- `chunk_y` −4 through −7 returns `river_valley`.
- `chunk_y` −8 through −11 returns `inland_plains`.
- `chunk_y` −12 through −15 returns `bayou`.
- Farther inland returns no biome the world will build. Do not add fifth and sixth resources in this phase.
- `chunk_y > 0` stays the landing sea.
- World generation still stops at `STRIP_NORTH`. Walking the coast does not enter the valley.
- Empty spawn tables stay empty. The stub test keeps failing the build if a stub gains species.

**Tests:** (0, 0) is `coastal_north`. A tile in chunk_y −4 is `river_valley`. A tile in chunk_y −8 is `inland_plains`. A tile in chunk_y −12 is `bayou`. The strip builder still only builds chunk_y 0..−3.

**Done when:** those tests pass and a walk on the coast is the same woods. The band lookup and the strip guard are in. Treat this phase as done once that change is on `main`.

**Not a Play.**

## Phase C — River valley ground

The first player-visible land. He can walk to the bank. He cannot cross yet. He cannot fish yet.

- Extend generation through the valley band only (`chunk_y` −4..−7, `chunk_x` −1..1). The quiet edge moves to the north side of that band. Plains chunks still do not build.
- Fill `river_valley.tres` with the spawn list in `docs/LOOP.md` and nothing else. Ids are the species words (`sugar_maple`, `forage_butternut`, `riverbank_grape`, `fiddlehead`).
- Ground is flat color from the biome resource: silt, clay loam, river. Do not reuse the coast Wang sheets, peat, granite, or sphagnum.
- Trees, vines, and forage are ColorRects named by species. Each one is a row in `docs/ART.md`.
- The main stem, the brooks, the deer, and the trail are the rules in `docs/LOOP.md`.
- Chop, pick, and fire use the coast skills and the coast numbers. Valley trees pay wood. Valley forage pays the HUD forage count. No pitch. No sticks.
- The coast track does not play in the valley.
- Night cold is the coast night. No rime and no pitch glints on valley species.
- Saves from the coast still load. New chunks come from the seed. Continue puts him where he saved.

**Tests:** valley chunks spawn only the allowed species. A coast chunk still spawns only fir, spruce, bakeapple, blueberry. The stem blocks. A brook does not. The deer spooks like the caribou and Space does nothing. Seed stability for a valley chunk. The plains band is still not generated.

**Done when:** Actions is green. STATUS says **ready for Play**. The valley ground is in this branch. Pictures stay boxes until a named row in `docs/ART.md`.

## Phase D — Raft

- Pack craft **Make raft**, **12** wood, cap 1, equip as the one held tool.
- **Space** on a bank facing the main stem crosses as `docs/LOOP.md` says, including the 24-tile limit and the two hints.
- Brooks and the landing sea refuse.
- The raft remains after the crossing. The shore file stores it. **R** keeps it. Death’s extras tax can take it.
- No bridge node in the world.

**Tests:** craft spends 12 and refuses under that. Launch lands on the far bank. A 25-tile width refuses. A brook refuses. The sea refuses. Save round-trip.

**Done when:** Actions is green. STATUS says **ready for Play**. The raft is in this branch. The picture stays a square until the row in `docs/ART.md` is named.

## Phase E — Fishing

- New curve helper, formula in `docs/LOOP.md`. Coast skills do not call it.
- Hand-line recipe **1 stick + 1 pitch**, cap 1, one held tool.
- Cast, weights, chance, yield, XP, and pack **Eat** as in `docs/LOOP.md`.
- Species ids: `smelt`, `gaspereau`, `shad`, `eel`, `salmon`.
- Empty fishing icon: a row in `docs/ART.md`. Leaf burst and the line **Fishing is now 2.**
- The floppy stores `fishing_xp` and the fish stacks. Old files load as 0. **R** keeps the XP.

**Tests:** the four XP anchors (41, 6681, 3258626, 6517215). Coast woodcutting level 99 is still 341036. Catch weights sum to 100 and reject sturgeon. A miss spends nothing. Eat heals half a heart and does not change forage. **E** still spends forage. The sea and a brook refuse a cast. A facing prop still chops or picks.

**Done when:** Actions is green. STATUS says **ready for Play**. The hand-line is in this branch. The fishing icon stays empty until the row in `docs/ART.md` is named.

## Phase F — Hearts and the continent map

- Slept lands and earned maximum, rules in `docs/LOOP.md`.
- Single click on the minimap opens the six bands. Blank bands use the ladder names: Coastal North, River valley, Interior, Bayou, River country, The other sea. No species drawn in a band that has no research.
- Same fog memory. The clock keeps running.
- Admin slider behavior as in `docs/LOOP.md`.

**Tests:** first sleep in a land adds one heart and a second sleep there does not. Cap 9. Death sets hearts to 1 and leaves the maximum. Old save loads at 3. Admin value other than 3 replaces the maximum. The map and the corner share a revealed tile. **R** keeps the maximum and clears fog.

**Done when:** Actions is green. STATUS says **ready for Play**. Hearts from the first sleep in a land, and the continent map, are in this branch. Blank inland bands stay names only. Coast skill numbers are unchanged.

## Phase G — Plains research

Docs only. Rewrite `docs/research/biomes/inland_plains.md` from the template with sources.

The mission’s intent is mixed grassland, large game, and a mineral that becomes a travel tool. The file has to find a real corridor inland of the Saint John valley and name what actually lives there. If the sources do not support a workable mineral, say so, and do not invent ore. Elk and bison stay out unless a source in that file places them.

No `.tres` species, no art, no spawn, no PixelLab.

**Done when:** the research file has sources and a draft signature list, and the resources are still empty. Not a Play. This pass names the Rice Lake Plains and names no travel tool.

## Phase H — Plains band

Only after Phase G is on `main`.

The research file names no tool. **This phase stops.** Do not generate `chunk_y` −8..−11. Do not invent iron, a bloomery, or a chert knife. The gap is in `docs/IDEAS.md` under “Interior travel tool.” A later pass may research a different corridor. It does not spawn this one to fill the mission line.

When a tool has been named in that file, the spawn is: that band only, species from the file only, one craft that the walk needs the way the raft does, color boxes, and rows in `docs/ART.md`. Not a weapon ladder. Old skills apply only where the file lists a tree, a forage, or fuel.

**Done when:** it has not started. The empty resource is the proof. Not a Play.

## Phase I — Bayou research

Docs only, same gate as Phase G, for `docs/research/biomes/bayou.md`. Real interior-south swamp on the compressed walk. Cypress only if the sources place it. No Newfoundland species copied south to fill space.

**Done when:** the research file has sources and a draft signature list. Resources stay empty. Not a Play. This pass names the Atchafalaya Basin. Cypress stays in that file.

## Phase J — Bayou band

Only after Phase I is on `main`. Generate `chunk_y` −12..−15 from `docs/research/biomes/bayou.md` only. The water rule is the one in that file: bayou channels and tupelo sloughs are not waded, the cypress margin and the higher floodplain are the walk, and it is not one stem. Do not invent a tile depth, a flood calendar, or a second boat. Color boxes. `docs/ART.md` rows. No alligator in this phase.

**Done when:** Actions is green. STATUS says **ready for Play**. The bayou band is in this branch. The plains rows between it and the valley are still not generated, so a walk from the coast does not reach it yet.

## Phase K — Later river country, research

Docs only. Pick one real southbound corridor from the Maritimes into the later eastern rivers. Name it in the file. That name becomes the biome id. Add the resource only as an empty stub if the tests need the id to resolve. No species on it.

**Done when:** the research file has sources and a draft signature list. Not a Play. This pass names the Connecticut River. The id is `river_country`. No resource yet.

## Phase L — That band

Only after Phase K is on `main`. Generate `chunk_y` −16..−19 from `docs/research/biomes/river_country.md` only. That file supports old woodcutting and old foraging on cottonwood, sycamore, chestnut, shagbark hickory, and the chestnut nut. It does not support a new skill, a new boat, or a new catch. One stem he does not wade, and tributaries he can. Do not invent a tile width, a dam, or a tide. Do not invent a second Mississippi. Color boxes. `docs/ART.md` rows. No new animal.

**Done when:** Actions is green. STATUS says **ready for Play**. The Connecticut band is in this branch. The one-tile stem is a drawing. The plains rows are still not generated, so a walk from the coast does not reach it yet. He can walk into it from the bayou.

## Phase M — Western shore, research

Docs only. A real Pacific-edge analogue for a compressed crossing. The file says what the shore is. The win does not need a new skill.

**Done when:** the research file has sources and a draft signature list. Not a Play.

## Phase N — The win

Only after Phase M is on `main`.

- Generate the last band, `chunk_y` −20..−23, wide enough that `chunk_x <= -2` is walkable shore.
- The first time he stands on that shore, show **The other sea.** once. Store the flag on the shore file so it does not repeat. **R** keeps the flag if this run already won. A new run on a new shore has not won.
- The world does not end. He can walk back.

**Tests:** stepping onto the shore sets the flag and the line. A second step does not show it again. Death and sleep do not clear it. A coast tile does not set it.

**Done when:** Actions is green. STATUS says **ready for Play**.

## After the path

Expression (a house, a town), perks, hunger, hunting, and the rest of `docs/IDEAS.md` wait until the owner opens them. Do not start them because the win exists.
