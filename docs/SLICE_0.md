# Slice 0 — current cut

This is **not** the game. The game is [MISSION.md](MISSION.md). This file is the vertical cut we are building now.

## Playable content

One **seed-generated** `coastal_north` chunk.

- Shore on one edge (crash-landing)
- Researched boreal forest inland
- A **caribou** trail that points **away from the water** (the mission’s “deer trails” on this coast)

## Verbs

1. Walk in 8 directions (keyboard); double-tap the same key and hold to jog — **in now**
2. Pick forage named in `docs/research/biomes/coastal_north.md` — not yet
3. Chop a real tree species (stone axe already in hand; crafting is slice 1) — not yet
4. Place / light a campfire from wood — not yet
5. Night falls; the campfire is the warm light — not yet

Press **R** in-game for a new seed (mission test: different woods).

HUD: hearts (even if unused), wood count, forage count.

## Mission tests (must all be true)

- Does the shore feel like a stranding, not a level select?
- Does the trail pull inland?
- Does a new seed produce a different coastal forest?
- Could a second biome resource drop in without rewriting the player?
- Do on-screen plants and animals match the research doc?

## Explicitly not in this cut

Hunger, freezing damage, wolves, inventory screen, crafting, rafts, weather sim, other biomes as playable land, Steam page.

Those stay named in the mission and as empty biome stubs.

## Slice 1 (same world, not a new game)

Hunger, warmth, craft the axe, clear a path, maybe one researched predator, sleep. Still `coastal_north`. Still generated chunks.
