# Journey spine (schematic world map)

Status: **draft — schematic only. Not playable. Not a spawn table.**

This is the continent as a sequence of walks, not a painted overworld and not a new biome pass. Slice 0 stays `coastal_north`. In-game orientation is a tiny fog-of-war minimap, not a map he holds. This file is the long-aim spine for later biomes.

## How this helps Leif go inland

The shore is a landing, not a home. The trail already points north, off the water. This file says what “keep walking” means after that chunk: leave Newfoundland, use the rivers to go south, then a compressed crossing of the later United States toward the Pacific. Food, fire, and a crossing are how the walk continues. The camp is still not the destination.

## Compressed continent

Fantasy is **journey length**. The walk is shortened. The places are not invented. Species stay in `docs/research/biomes/` — if a plant is not in those files, it does not spawn.

| Step | Region in the game | Real analogue | Status | What changes underfoot |
|---|---|---|---|---|
| 0 | `coastal_north` | L’Anse aux Meadows / Great Northern Peninsula, Newfoundland | **Playable now** | Boreal coast: fir, spruce, peat, granite, caribou trail, bakeapple, blueberry |
| 1 | `river_valley` | Saint John River valley and inner Southwest Miramichi, New Brunswick | **Researched only** (PR #2, owner-approved). Empty `.tres` | Hardwood floodplain, intervale silt over clay, a river you cannot ford. Raft or timber bridge |
| 2 | `inland_plains` | Interior mainland after the first valleys (mixed grassland / mineral hills) | **Stub later** | Distance, large game, iron as a travel tool. No species list yet |
| 3 | South along the rivers | River country from the Maritimes into the later eastern United States | **Stub later** | Same rule as step 1: the main stem is a barrier; tributaries may be waded. No species list yet |
| 4 | `bayou` | Interior south of a compressed continent | **Stub later** | Cypress / swamp as proof you crossed a lot of land, not as fake trees on the Vinland shore |
| 5 | West | Compressed crossing toward the Pacific | **Long aim** | Named so the walk has an end of the map. Not the next slice. No species list |

Do not add rows by inventing a desert, a jungle, or a town. A new row needs a research pass with sources, the same way `coastal_north` and `river_valley` were done.

## Travel tools the land asks for

These are implied by the ground, not a crafting tree.

| Need | Why | When |
|---|---|---|
| Walk, forage, chop, fire | Night and hunger on the shore | Slice 0 (in now, except hunger) |
| Raft or timber bridge | The Saint John / Miramichi main stem is not a brook | First time `river_valley` is playable |
| Later boat | Southbound rivers, then larger water | After the first crossing exists |
| Iron as a travel tool | Interior hills in the mission ladder | `inland_plains` research, not now |
| Tiny bottom-left minimap with fog of war | So he can see where he has walked on this coast | Next UI. Not a held item. This file stays the continent spine |

## River spine (southbound)

Wallace’s butternuts and riverbank grapes at L’Anse aux Meadows did not grow on that shore. They point to the Gulf of St. Lawrence / New Brunswick river country — the same inland step already researched as `river_valley`. That is the first water you cannot walk through.

After that, the compressed walk keeps using **rivers as the road**, not a fantasy canal:

1. **Leave the island** — the landing is Newfoundland. The next researched land is already mainland river country, not another spruce beach.
2. **Saint John (`Wəlastəkw`) and the Miramichi** — first named crossings. Brooks are not those rivers.
3. **Later south** — keep the same rule when those regions are researched: name a real corridor, then compress the miles. Do not spawn “the Mississippi” or “the Ohio” until a research file says so.
4. **West** — a later pass. Do not borrow California oaks or plains bison into an empty stub.

## What is not next

- No playable `river_valley` chunk
- No `inland_plains` or west-coast species lists
- No PixelLab for maple, grape, or a map UI
- No villages, meetings, or combat (the valley was already lived in; that is a later design pass)
- No baked overworld scene that would replace seed / chunk / biome-as-data

## Do not invent

- Species that are not in `docs/research/biomes/`
- Bakeapple, peat, granite, or tuckamore as the look of the river valley
- Coyote in the 11th-century Maritimes
- Self-sown saga wheat as a named plant
- A road-wide trail (the caribou path is one tile; later deer trails should stay game paths)

## Sources

Geographic spine only. Flora and fauna stay in the biome files.

1. Birgitta Linderoth Wallace, “The Norse in Newfoundland: L’Anse aux Meadows and Vinland,” *Newfoundland and Labrador Studies* — https://journals.lib.unb.ca/index.php/NFLDS/article/download/140/237 (butternut and wild grape as imports from farther south; northern limit about 47°N)
2. Birgitta Wallace, “The Norse in the North Atlantic: Old Sources, New Discoveries” (Parks Canada lecture, 2014) — http://parkscanadahistory.com/publications/meadows/wallace-2014.pdf (Hóp / Miramichi country; butternut absent from Newfoundland)
3. Canadian Encyclopedia, “L’Anse aux Meadows” (Wallace) — https://thecanadianencyclopedia.ca/en/article/lanse-aux-meadows
4. Ecological Stratification Working Group, Saint John River Valley ecoregion — http://www.ecozones.ca/english/region/120.html
5. New Brunswick, *Our Landscape Heritage*, chapter 13 — https://www2.gnb.ca/content/dam/gnb/Departments/nr-rn/pdf/en/ForestsCrownLands/ProtectedNaturalAreas/OurLandscapeHeritage/Chapter13-e.pdf (intervale, flood, hardwoods)
6. Micah A. Pawling, “Wəlastəkwey (Maliseet) Homeland,” *Acadiensis* — https://journals.lib.unb.ca/index.php/Acadiensis/article/download/25946/30150 (scale of the Saint John; it is not a ford)
7. This repo: `docs/MISSION.md` continent ladder; `docs/research/biomes/coastal_north.md`; PR #2 `river_valley.md`
