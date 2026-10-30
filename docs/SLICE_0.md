# Slice 0 — current cut

This is **not** the game. The game is [MISSION.md](MISSION.md). This file is the vertical cut we are building now.

## Playable content

Play opens on a title. The coastal still fills the screen. A green box on top offers **New Game** and **Continue**. A cream **admin cog** in the title’s top right opens QC sliders (day/night, hearts, XP curve, foliage %, walk, run). Save writes a JSON file under Godot’s user folder; session values still apply to the next run if he skips Save. Buttons light only under the pointer. **New Game** fades that box, turns Leif so his back faces you, and he walks inland while the **seed-generated** `coastal_north` strip is built a slice at a time. Then you are on it. The landing is chunk (0,0). Walking inland is the same forest, already there. The sea stays south. **Continue** shows three boxes. An empty one says “No save file” and does nothing. A file shows the name he typed and the Costa Rica time, and it leaves the same way New Game does. He comes back where he saved: seed, place, facing, wood, forage, hearts, the map he uncovered, and time of day. Chopped trees grow back from the seed. A fire that was still burning comes back on the same tile, with the time it had left. The two bars in the top right write the file. The first click asks for a name. Quitting without that click leaves the box as it was. If all three already have a file, New Game asks before it overwrites, then which box. The old file stays until the new run’s first floppy. A filled box has a small **x**. It asks before it deletes that file. **No** leaves it. **Yes** clears that box. Escape steps back from those boxes to the menu, and does nothing on the title itself once the admin panel is closed. Escape closes the admin panel when it is open. Escape closes the name box when it is open. Otherwise Escape in the woods asks **Quit to the main menu?** Yes returns to the title without closing the game. That is not a pause screen. The title is silent; the grove starts with the woods.

- Shore on one edge (crash-landing)
- Researched boreal forest inland
- A **caribou** trail that points **away from the water** (the mission’s “deer trails” on this biome). One tile wide, moss gaps, not a road.
- Ground is PixelLab Wang tiles (water, shore, moss/peat, trail), not flat color
- Granite is a rock object on the moss, not painted into the floor
- Light clutter: sphagnum and needles stay scenery. Fallen fir branches: Space clears them for **0.5 wood**
- Fallen fir/spruce logs: Space chops like a standing tree. Logs block their **full length**. Rocks and standing trees block their tile.
- Bed music: **The First Grove** loops on this biome (~3 minutes)

## Verbs

These are how Leif stays in the woods after dark: berries he can eat, a fire for light, warmth, and sleep. The camp is a rest, not the destination. A hunger bar stays later. Woodcutting and fire-making are in (`docs/SKILLS.md`).

1. Walk in 8 directions (keyboard); double-tap the same key and hold to jog — **in now**
2. **Space** facing bakeapple or blueberry picks it (forage +1, bush gone) — **in now**
3. **Space** facing balsam fir or spruce chops it with the stone axe already in hand. Level 1 takes **3–4** Spaces and pays **0.5 wood**. A smaller ringed stump stays. Woodcutting XP is granted only on the fall — **in now**
3b. **Space** facing a fallen fir branch clears it (wood +0.5, no XP). Fallen logs train woodcutting like a standing tree — **in now**
4. **F** spends wood (7 at low fire-making, down toward 1 after level 30) for an attempt on the tile ahead. A miss still spends the wood. Catch chance climbs to 95% by level 30. A catch grants fire-making XP and burns **one night**, then goes out — **in now**
5. Night is **60 seconds** of cold (six hearts if you stand it). Dusk eases in; dawn eases back to day. Away from a fire, night spends **half a heart every 5 seconds**. Day or warmth heals **half a heart every 10 seconds**. The last half-heart stays — **in now**
6. **C** by a fire at dusk or night fades to black, then wakes at dawn as it gets light. Sleeping the night spends the fire — **in now**
7. Tiny bottom-left map: a small circle around him, and the trail stays clear; **R** wipes it — **in now**
8. **E** spends 3 forage to heal half a heart. A pick still grants 1. Fewer than 3, and full hearts, refuse and spend nothing. A bite never goes past max. No hunger bar — **in now**

Press **R** in-game for a new seed (mission test: different woods). Wood, forage, woodcutting, and fire-making stay. Fires were on the old ground.

HUD: hearts (half-pips), wood count, forage count, and a line that says **E** eats. A skills mark left of the two bars opens Woodcutting and Fire-making with their levels. Tiny bottom-left minimap: a small circle around him, and the trail stays clear; **R** wipes it.

Species come from the `coastal_north` biome resource, which matches the slice 0 spawn list in the research doc (fir, spruce, bakeapple, blueberry). Cranberry and tamarack stay in that doc and out of this cut.

## Mission tests (must all be true)

- Does the shore feel like a stranding, not a level select?
- Does the trail pull inland — and is sitting by a fire also valid play?
- Does a new seed produce a different coastal forest?
- Could a second biome resource drop in without rewriting the player?
- Do on-screen plants and animals match the research doc?
- Would you linger here, or is it only a checklist of verbs?

## Explicitly not in this cut

A hunger bar or starve clock, death at 0 hearts, wolves, inventory screen, crafting, rafts, weather sim, other biomes as playable land, Steam page, a pause screen, a player options menu. Admin on the title is machine-wide QC, not that options menu. Longer burn and a bigger fire warmth radius stay later.

Those stay named in the mission and as empty biome stubs.

## Slice 1 (same world, not a new game)

Warmth, sleep, the corner fog map, smaller ringed stumps, three berries for half a heart, the launch title, the three save files, woodcutting, fire-making, the title admin cog, and Escape quit-to-menu are in. A longer strip is not the next cut. A hunger meter, a caribou, the river, pause, and a player options menu wait. Still `coastal_north`.
