# Slice 0 — current cut

This is **not** the game. The game is [MISSION.md](MISSION.md). This file is the vertical cut we are building now.

## Playable content

Play opens on a title. The coastal still fills the screen. A green box on top offers **New Game** and **Continue**. Buttons light only under the pointer. **New Game** fades that box, turns Leif so his back faces you, and he walks inland while the **seed-generated** `coastal_north` strip is built a slice at a time. Then you are on it. The landing is chunk (0,0). Walking inland is the same forest, already there. The sea stays south. **Continue** shows three boxes that say “No save file.” Nothing is written or loaded. A file that exists leaves the same way New Game does. Escape steps back from those boxes to the menu, and does nothing on the title itself. Escape in the woods is reserved for pause and does nothing yet. The title is silent; the grove starts with the woods.

- Shore on one edge (crash-landing)
- Researched boreal forest inland
- A **caribou** trail that points **away from the water** (the mission’s “deer trails” on this coast). One tile wide, moss gaps, not a road.
- Ground is PixelLab Wang tiles (water, shore, moss/peat, trail), not flat color
- Granite is a rock object on the moss, not painted into the floor
- Light clutter: sphagnum and needles stay scenery. Fallen fir branches: Space clears them for **0.5 wood**
- Fallen fir/spruce logs: Space chops for **3 wood**, same as a standing tree. Logs block their **full length**. Rocks and standing trees block their tile.
- Bed music: **The First Grove** loops on this coast (~3 minutes)

## Verbs

These are how Leif stays in the woods after dark: berries he can eat, a fire for light, warmth, and sleep. The camp is a rest, not the destination. A hunger bar stays later. Skills stay later (`docs/SKILLS.md`).

1. Walk in 8 directions (keyboard); double-tap the same key and hold to jog — **in now**
2. **Space** facing bakeapple or blueberry picks it (forage +1, bush gone) — **in now**
3. **Space** facing balsam fir or spruce chops it with the stone axe already in hand (wood +3, tree gone, smaller ringed stump left) — **in now**
3b. **Space** facing a fallen fir branch clears it (wood +0.5). Fallen logs still give 3 — **in now**
4. **F** spends 3 wood to place and light a campfire on the tile in front of him. It burns **one night**, then goes out — **in now**
5. Night is **60 seconds** of cold (six hearts if you stand it). Dusk eases in; dawn eases back to day. Away from a fire, night spends **half a heart every 5 seconds**. Day or warmth heals **half a heart every 10 seconds**. The last half-heart stays — **in now**
6. **C** by a fire at dusk or night fades to black, then wakes at dawn as it gets light. Sleeping the night spends the fire — **in now**
7. Tiny bottom-left map: a small circle around him, and the trail stays clear; **R** wipes it — **in now**
8. **E** spends 3 forage to heal half a heart. A pick still grants 1. Fewer than 3, and full hearts, refuse and spend nothing. A bite never goes past max. No hunger bar — **in now**

Press **R** in-game for a new seed (mission test: different woods). Wood and forage stay in hand. Fires were on the old ground.

HUD: hearts (half-pips), wood count, forage count, and a line that says **E** eats. Tiny bottom-left minimap: a small circle around him, and the trail stays clear; **R** wipes it.

Species come from the `coastal_north` biome resource, which matches the slice 0 spawn list in the research doc (fir, spruce, bakeapple, blueberry). Cranberry and tamarack stay in that doc and out of this cut.

## Mission tests (must all be true)

- Does the shore feel like a stranding, not a level select?
- Does the trail pull inland — and is sitting by a fire also valid play?
- Does a new seed produce a different coastal forest?
- Could a second biome resource drop in without rewriting the player?
- Do on-screen plants and animals match the research doc?
- Would you linger here, or is it only a checklist of verbs?

## Explicitly not in this cut

A hunger bar or starve clock, death at 0 hearts, wolves, inventory screen, crafting, skill XP, rafts, weather sim, other biomes as playable land, Steam page, save files, loading a slot, a pause screen, an options menu.

Those stay named in the mission and as empty biome stubs.

## Slice 1 (same world, not a new game)

Warmth, sleep, the corner fog map, smaller ringed stumps, three berries for half a heart, and the launch title are in. The three Continue boxes are empty on purpose. Next, if Play wants it: wire save files to those boxes. A hunger meter, skills, and pause wait. Still `coastal_north`.
