# Journey spine (schematic world map)

Status: **spine locked in `docs/LOOP.md` (2026-11-12). Still not playable. Still not a spawn table.**

This is the continent as a sequence of walks, not a painted overworld. The playable cut stays `coastal_north` until `docs/PLAN.md` says otherwise. The corner map stays. A later phase adds one continent view of the same fog. This file is not that screen.

The landing sea stays south. Inland (decreasing `chunk_y`) is the journey, including the later bands the mission calls south and west. He does not win by walking into the surf. Ladder order follows the mission: coast, river valley, interior, bayou, later river country, western shore.

## How this helps Leif go inland

The shore is a landing, not a home. The trail already points north, off the water. This file says what “keep walking” means after that chunk: leave Newfoundland, use the rivers to go south, then a compressed crossing of the later United States toward the Pacific. Food, fire, and a crossing are how the walk continues. The camp is still not the destination.

## Compressed continent

Fantasy is **journey length**. The walk is shortened. The places are not invented. Species stay in `docs/research/biomes/` — if a plant is not in those files, it does not spawn.

| Step | Region in the game | Real analogue | Status | What changes underfoot |
|---|---|---|---|---|
| 0 | `coastal_north` | L’Anse aux Meadows / Great Northern Peninsula, Newfoundland | **Playable now** | Boreal coast: fir, spruce, peat, granite, caribou trail, bakeapple, blueberry |
| 1 | `river_valley` | Saint John River valley and inner Southwest Miramichi, New Brunswick | **Researched.** Spawn in `docs/PLAN.md` Phase C. Empty `.tres` until then | Hardwood floodplain, intervale silt over clay, a river you cannot ford. Carried raft |
| 2 | `inland_plains` | Rice Lake Plains, Oak Ridges Moraine, Ontario: tallgrass and black-oak savanna. Not the Madawaska highlands. | **Researched.** Spawn is Phase H, and that phase stops: no travel tool was named. Empty `.tres` until a later pass opens it on purpose | Grass, scattered oaks, eastern elk. Iron is not an 11th-century craft here |
| 3 | `bayou` | Atchafalaya Basin, south-central Louisiana: baldcypress and water tupelo. Not a northern swamp with cypress pasted on. | **Spawned** at `chunk_y` −12..−15. Pictures are boxes. The plains gap is not generated | Flooded forest, many channels, muscadine and pecan. No new animal in the first spawn |
| 4 | Later river country | One real corridor from the Maritimes into the later eastern rivers | **No file yet.** Phase K names it | The main stem is a barrier. Tributaries may be waded. No species until that file |
| 5 | Western shore | Compressed crossing toward the Pacific | **Long aim.** Phases M–N | The win is the first step onto that shore. No species list yet |

Do not add rows by inventing a desert, a jungle, or a town. A new row needs a research pass with sources, the same way `coastal_north` and `river_valley` were done.

## Travel tools the land asks for

These are implied by the ground, not a crafting tree.

| Need | Why | When |
|---|---|---|
| Walk, forage, chop, eat, fire | Night on the shore; 3 berries heal half a heart | Slice 0 (in now). A hunger meter is not |
| Carried raft, 12 wood | The Saint John / Miramichi main stem is not a brook | `docs/PLAN.md` Phase D. A bridge left on the map is not this crossing |
| Later boat | Southbound rivers, then larger water | After the first crossing exists, and only if that land’s research asks for one |
| A travel tool from a named mineral | Interior hills in the mission ladder | Phase G looked. The Rice Lake hills do not support an 11th-century iron tool. Phase H does not invent one |
| Corner minimap, then one continent view of the same fog | So the next band is a rumor before he can walk it | The corner map is in. The continent view is Phase F. Not a held item |

## River spine (southbound)

Wallace’s butternuts and riverbank grapes at L’Anse aux Meadows did not grow on that shore. They point to the Gulf of St. Lawrence / New Brunswick river country — the same inland step already researched as `river_valley`. That is the first water you cannot walk through.

After that, the compressed walk keeps using **rivers as the road**, not a fantasy canal:

1. **Leave the island** — the landing is Newfoundland. The next researched land is already mainland river country, not another spruce beach.
2. **Saint John (`Wəlastəkw`) and the Miramichi** — first named crossings. Brooks are not those rivers.
3. **Later south** — keep the same rule when those regions are researched: name a real corridor, then compress the miles. Do not spawn “the Mississippi” or “the Ohio” until a research file says so.
4. **West** — a later pass. Do not borrow California oaks or plains bison into an empty stub.

## What is not next

- Phase B is the band table. A playable `river_valley` chunk waits for Phase C in `docs/PLAN.md`.
- `inland_plains` is researched and stays empty. Phase H does not spawn it. `bayou` is spawned, and a walk from the valley does not reach it. No west-shore species until that research is on `main`.
- No PixelLab for maple, grape, or a map UI. Cloud leaves boxes and adds the `docs/ART.md` row.
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
