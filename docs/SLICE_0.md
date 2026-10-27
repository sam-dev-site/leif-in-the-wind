# Slice 0 — current cut

This is **not** the game. The game is [MISSION.md](MISSION.md). This file is the vertical cut we are building now.

## Playable content

One **seed-generated** `coastal_north` chunk.

- Shore on one edge (crash-landing)
- Researched boreal forest inland
- A **caribou** trail that points **away from the water** (the mission’s “deer trails” on this coast)

## Verbs

These are how Leif keeps walking inland after dark: berries in hand, a fire for light. The camp is not the destination. Hunger and freezing stay slice 1.

1. Walk in 8 directions (keyboard); double-tap the same key and hold to jog — **in now**
2. **Space** facing bakeapple or blueberry picks it (forage +1, bush gone) — **in now**
3. **Space** facing balsam fir or spruce chops it with the stone axe already in hand (wood +3, tree gone, stump left) — **in now**
4. **F** spends 3 wood to place and light a campfire on the tile in front of him — **in now**
5. Night falls on its own, then dawn. The campfire is the warm light. No freezing damage — **in now**

Press **R** in-game for a new seed (mission test: different woods). Wood and forage stay in hand. Fires were on the old ground.

HUD: hearts (shown, not spent this slice), wood count, forage count.

Species come from the `coastal_north` biome resource, which matches the slice 0 spawn list in the research doc (fir, spruce, bakeapple, blueberry). Cranberry and tamarack stay in that doc and out of this cut.

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
