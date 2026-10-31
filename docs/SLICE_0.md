# Slice 0 — current cut

This is **not** the game. The game is [MISSION.md](MISSION.md). This file is the vertical cut we are building now.

## Playable content

Play opens on a title. The coastal still fills the screen. A green box on top offers **New Game** and **Continue**. A cream **admin cog** in the title’s top right opens QC sliders (day/night, hearts, XP curve, foliage %, walk, run). Save writes a JSON file under Godot’s user folder; session values still apply to the next run if he skips Save. Buttons light only under the pointer. **New Game** fades that box, turns Leif so his back faces you, and he walks inland while the **seed-generated** `coastal_north` strip is built a slice at a time. Then you are on it. The landing is chunk (0,0). Walking inland is the same forest, already there. The sea stays south. **Continue** shows three boxes. An empty one says “No save file” and does nothing. A file shows the name he typed and the Costa Rica time, and it leaves the same way New Game does. He comes back where he saved: seed, place, facing, wood, forage, hearts, the map he uncovered, time of day, and the caribou. An old file without those keys still has one inland. Chopped trees grow back from the seed. A fire that was still burning comes back on the same tile, with the time it had left. The floppy in the top right writes the file. The first click asks for a name. Quitting without that click leaves the box as it was. If all three already have a file, New Game asks before it overwrites, then which box. The old file stays until the new run’s first floppy. A filled box has a small **x**. It asks before it deletes that file. **No** leaves it. **Yes** clears that box. Escape steps back from those boxes to the menu, and does nothing on the title itself once the admin panel is closed. Escape closes the admin panel when it is open. Escape closes the name box when it is open. Otherwise Escape in the woods asks **Quit to the main menu?** Yes returns to the title without closing the game. That is not a pause screen. The title is silent; the grove starts with the woods.

- Shore on one edge (crash-landing)
- Researched boreal forest inland
- A **caribou** trail that points **away from the water** (the mission’s “deer trails” on this biome). One tile wide, moss gaps, not a road. One woodland caribou walks it, grazes, and runs away if he jogs at it (4 tiles) or walks at it (2 tiles). Space does nothing. It does not vanish off the strip.
- Three **arctic hares** on the moss, 3–6 tiles off that trail in the same inland band as the caribou. They hop, sit, and run away if he jogs at them (4 tiles) or walks at them (2 tiles). Space does nothing. No hunt. ColorRect until PixelLab walk art.
- Ground is PixelLab Wang tiles (water, shore, moss/peat, trail), not flat color
- Granite is a rock object on the moss, not painted into the floor
- Light clutter: sphagnum and needles stay scenery. Fallen fir branches: Space clears them for **0.5 wood**
- Fallen fir/spruce logs: Space chops like a standing tree. Logs block their **full length**. Rocks and standing trees block their tile.
- Bed music: **The First Grove** loops on this biome (~3 minutes)

## Verbs

These are how Leif stays in the woods after dark: berries he can eat, a fire for light, warmth, and sleep. The camp is a rest, not the destination. A hunger bar stays later. Woodcutting, fire-making, and foraging are in (`docs/SKILLS.md`).

1. Walk in 8 directions (keyboard); double-tap the same key and hold to jog — **in now**
2. **Space** facing bakeapple or blueberry picks it (forage from Foraging yield, bush gone; XP on the pick) — **in now**
3. **Space** facing balsam fir or spruce chops it with the stone axe already in hand. Level 1 takes **3–4** Spaces and pays **0.5 wood**. A smaller ringed stump stays. Woodcutting XP is granted only on the fall — **in now**
3b. **Space** facing a fallen fir branch clears it (wood +0.5, no XP). Fallen logs train woodcutting like a standing tree — **in now**
4. **F** spends wood (7 at low fire-making, down toward 1 after level 30) for an attempt on the tile ahead. A miss still spends the wood. Catch chance climbs to 95% by level 30. A catch grants fire-making XP and burns **one night**, then goes out — **in now**
5. Night is **60 seconds** of cold (six hearts if you stand it). Dusk eases in; dawn eases back to day. Away from a fire, night spends **half a heart every 5 seconds**. Day and fire warmth do not heal — berries (**E**) are the only restore. The cold that would take the last half-heart is **death** — **in now**
6. **C** by a fire at dusk or night fades to black, then wakes at dawn as it gets light. Sleeping the night spends the fire. That tile is the death wake place — **in now**
6b. Death fades to black with a cream skull and crossed bones, holds ~0.8s, skips to dawn, halves wood and forage, sets hearts to **1**, and wakes at the last slept fire (or the landing if he never slept). Skills and the map stay. A named shore writes the floppy. Sleep stays a blank blink — **in now**
7. Tiny bottom-left map: a small circle around him, and the trail stays clear; **R** wipes it — **in now**
8. **E** spends forage (10 at low Foraging, down toward 2) to heal half a heart. A pick at level 1 still grants 1. Short hands and full hearts refuse and spend nothing. A bite never goes past max. No hunger bar — **in now**
9. One woodland caribou on the trail. Walk toward it spooks at 2 tiles; jog toward it at 4. Standing still you can watch it graze. It always runs away, faster than Leif, and stays in the woods — **in now**
10. Three arctic hares on the moss beside the trail. Walk toward one spooks at 2 tiles; jog toward it at 4. Standing still you can watch it sit. It always runs away, faster than Leif, and stays in the woods — **in now**

Press **R** in-game for a new seed (mission test: different woods). Wood, forage, pack extras, woodcutting, fire-making, and foraging stay. Fires and the last-sleep mark were on the old ground.

HUD: hearts (half-pips), wood count, forage count, and a line that says **E** eats. Skills mark, **pack** mark, then floppy across the top right. Skills opens Woodcutting, Fire-making, and Foraging. Pack opens a mouse area of extras (pitch, stick, torch) with count badges; Make torch at the bottom. Double-click a torch to equip (faded + **E**). **Space** on a burning fire lights an equipped torch (light only, one night, single use). Tiny bottom-left minimap: a small circle around him, and the trail stays clear; **R** wipes it.

Species come from the `coastal_north` biome resource, which matches the slice 0 spawn list in the research doc (fir, spruce, bakeapple, blueberry). Cranberry and tamarack stay in that doc and out of this cut. Pack extras: pitch from fir/spruce, stick from branches — see the research note.

## Mission tests (must all be true)

- Does the shore feel like a stranding, not a level select?
- Does the trail pull inland — and is sitting by a fire also valid play?
- Does a new seed produce a different coastal forest?
- Could a second biome resource drop in without rewriting the player?
- Do on-screen plants and animals match the research doc?
- Would you linger here, or is it only a checklist of verbs?

## Explicitly not in this cut

A hunger bar or starve clock, wolves, fishing pole / bones / more crafts, rafts, weather sim, other biomes as playable land, Steam page, a pause screen, a player options menu. Admin on the title is machine-wide QC, not that options menu. Longer burn and a bigger fire warmth radius stay later. PixelLab art for the death skull and pack icons waits on generations.

Those stay named in the mission and as empty biome stubs.

## Slice 1 (same world, not a new game)

Warmth, sleep, the corner fog map, smaller ringed stumps, foraging (yield and eat cost), the launch title, the three save files, woodcutting, fire-making, the title admin cog, Escape quit-to-menu, one caribou on the trail, three arctic hares on the moss, death (half pack, wake at the fire), and the rucksack + torch craft are in. A longer strip is not the next cut. A hunger meter, the river, pause, and a player options menu wait. Still `coastal_north`.
