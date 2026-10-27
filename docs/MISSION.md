# Mission

**Title:** *Leif in the Wind*

**Why it exists:** Leif Erikson is stranded on the Vinland coast in the 11th century. Survival is the opening, not the point. The point is the pull **inland** — through boreal forest, river valleys, plains, and eventually southern water — to make a life on a continent that keeps opening.

**The feeling we are protecting:** You are small in a real place. Trails exist because deer walked them. Trees are the trees that grow there. Night is cold. South and west are rumors until you get there.

This is not RuneScape. The look is the forest screenshot in `art-inspo/screen-layout-pixels.jpg` (Stardew / Zelda top-down). The stock “VIKINGS” sheet is not the art direction.

**Players:** single-player. Each later Steam world comes from a seed.

## Pillars (every slice must serve these)

1. **A generated continent** — a seed, chunks, and land that can grow. Not a painted one-off level.
2. **Biomes that change the land** — researched flora and fauna. Walking far enough should feel like a different place.
3. **Survival that unlocks travel** — chop, forage, fire, later warmth, tools, rafts. These exist so you can keep going inland.
4. **The pull inland** — shore behind you, trail away from the water. The camp is not the destination.

## Continent ladder

Always true, even when only the first row is playable:

1. **Coastal North** — Vinland boreal coast (Newfoundland / Gulf of St. Lawrence ecoregion). Spruce, granite, peat, cold wind, deer trails, shore. Slice 0–1.
2. **Inland river valleys** — temperate deciduous forest, clay, arable soil, a river you cannot walk through. Raft or timber bridge. First biome change underfoot.
3. **Interior mainland** — mixed grassland, large game, mineral hills. Iron is a travel tool.
4. **Interior south** — bayou, cypress, swamp. Proof you crossed a continent.

Fantasy is **journey length** (a compressed continent). Fantasy is not fake trees on a real shore.

## Camera and craft (locked)

- High top-down with a slight RPG tilt
- 16×16 tiles, 480×270 integer-scaled
- Pixel art, nearest-neighbor, Y-sorted trees
- Godot 4, GDScript, Compatibility renderer

## What a slice is

A slice is a **vertical cut through this mission**, not a replacement for it. `docs/SLICE_0.md` describes the current cut. If slice docs and this file disagree, this file wins.
