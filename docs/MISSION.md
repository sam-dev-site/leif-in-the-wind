# Mission

**Title:** *Leif in the Wind*

**Why it exists:** Leif Erikson is stranded on the Vinland coast in the 11th century. Survival is the opening, not the point. The point is to **be** on a continent that keeps opening — to walk inland through boreal forest, river valleys, plains, and eventually southern water, and also to stand still in those woods and feel them.

**The feeling we are protecting:** You are small in a real place. Trails exist because deer walked them. Trees are the trees that grow there. Night is cold. A fire is enough reason to sit. South and west are rumors until you get there.

This is not RuneScape. The look is the forest screenshot in `art-inspo/screen-layout-pixels.jpg` (Stardew / Zelda top-down). The stock “VIKINGS” sheet is not the art direction.

**Players:** single-player. Each later Steam world comes from a seed.

## What fun we are after (MDA)

We design from **aesthetics** (the feelings) back to **dynamics** (what play does) then **mechanics** (verbs and rules). Hunicke, LeBlanc, Zubek named eight kinds of fun. We are not chasing all eight.

**Now (every slice must serve at least one of these):**

1. **Sensation** — the woods as sense-pleasure. Pixel firs, moss underfoot, dusk, a warm pool of firelight. If it looks or sounds like a spreadsheet, it failed.
2. **Fantasy** — you are Leif on Vinland. Journey length is compressed; the plants are not. Fake trees on a real shore break this.
3. **Discovery** — uncharted land. A new seed, a trail that keeps going, a biome that changes underfoot. The continent is the toy. More of this same shore is not the next discovery. A few steps already show its whole vocabulary.
4. **Submission** — the game as a pastime. Walking without a quest marker. Sitting the night out. Chilling in the woods is valid play, not wasted time.

**Next, on this coast, before more land:**

5. **Challenge** — woodcutting and fire-making, and the leveling curve in `docs/IDEAS.md`. They appear here first, in the biome that suits them: trees and fallen wood to chop, cold that makes a fire matter. A new biome is where something new is learned. That waits until this place is worth staying in. Getting better at the work is not a grind loop dressed as survival.

**Later (named, not this slice):**

6. **Expression** — leave a mark: a house, a town, crafting. The camp may become a place you made. It is not a win condition now.

**Not for this game:** authored plot as the hook (**Narrative**), other players (**Fellowship**). Single-player. The story is the walk and the land.

Getting Leif to move is not the goal. Movement is one way to feel the place. A feature that only advances a checklist and does not make the woods worth being in does not serve this mission.

## Pillars (every slice must serve these)

1. **A generated continent** — a seed, chunks, and land that can grow. Not a painted one-off level.
2. **Biomes that change the land** — researched flora and fauna. Walking far enough should feel like a different place. That change waits. This coast is practiced first.
3. **Survival that lets you stay and go** — chop, forage, fire, later warmth, tools, rafts. These exist so you can linger after dark and so you can keep going inland.
4. **The pull inland, and the right to linger** — shore behind you, trail away from the water. The camp is a rest, not the destination and not a waste of time.

## Continent ladder

Always true, even when only the first row is playable:

1. **Coastal North** — Vinland boreal coast (Newfoundland / Gulf of St. Lawrence ecoregion). Spruce, granite, peat, cold wind, deer trails, shore. Slice 0–1.
2. **Inland river valleys** — temperate deciduous forest, clay, arable soil, a river you cannot walk through. Raft or timber bridge. First biome change underfoot.
3. **Interior mainland** — mixed grassland, large game, mineral hills. Iron is a travel tool.
4. **Interior south** — bayou, cypress, swamp. Proof you crossed a continent.
5. **South along the rivers** — leave the island, follow river country into the later eastern United States. Not playable. Species when those biomes are researched.
6. **West** — a compressed crossing toward the Pacific. The long aim, not the next slice.

Fantasy is **journey length** (a compressed continent). Fantasy is not fake trees on a real shore.

## Camera and craft (locked)

- High top-down with a slight RPG tilt
- 16×16 tiles, 480×270 integer-scaled
- Pixel art, nearest-neighbor, Y-sorted trees
- Godot 4, GDScript, Compatibility renderer

## What a slice is

A slice is a **vertical cut through this mission**, not a replacement for it. `docs/SLICE_0.md` describes the current cut. If slice docs and this file disagree, this file wins.

Slice work is judged by the aesthetics above, not by whether Leif’s coordinate changed.
